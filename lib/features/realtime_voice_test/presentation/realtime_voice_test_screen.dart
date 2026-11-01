import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

import '../service/realtime_voice_service.dart';

enum _TranscriptRole { user, assistant }

class _TranscriptMessage {
  final String id;
  final _TranscriptRole role;
  final String text;

  const _TranscriptMessage({
    required this.id,
    required this.role,
    required this.text,
  });

  _TranscriptMessage copyWith({String? text}) {
    return _TranscriptMessage(id: id, role: role, text: text ?? this.text);
  }
}

class RealtimeVoiceTestScreen extends StatefulWidget {
  final int sessionIndex;
  final String initialScent;

  const RealtimeVoiceTestScreen({
    super.key,
    this.sessionIndex = 1,
    this.initialScent = '커피',
  });

  @override
  State<RealtimeVoiceTestScreen> createState() =>
      _RealtimeVoiceTestScreenState();
}

class _RealtimeVoiceTestScreenState extends State<RealtimeVoiceTestScreen>
    with WidgetsBindingObserver {
  final RealtimeVoiceService _voiceService = RealtimeVoiceService();
  final ScrollController _transcriptScrollController = ScrollController();

  final List<String> _recentEvents = [];
  final List<_TranscriptMessage> _transcriptMessages = [];
  final Set<String> _transcriptEventIds = {};
  String _status = '대화 시작을 누르면 바로 연결됩니다.';
  String? _transcriptionError;
  bool _isConnecting = false;
  bool _isTalking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _stopConversation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _voiceService.stop();
    _transcriptScrollController.dispose();
    super.dispose();
  }

  Future<void> _startConversation() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isConnecting = true;
      _recentEvents.clear();
      _transcriptMessages.clear();
      _transcriptEventIds.clear();
      _transcriptionError = null;
      _status = '연결을 준비하고 있어요…';
    });

    try {
      await _voiceService.start(
        scent: widget.initialScent,
        onStatus: _setStatus,
        onEvent: _recordEvent,
      );
      if (!mounted) return;
      setState(() {
        _isTalking = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _status = _friendlyError(error);
        _isTalking = false;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _stopConversation() async {
    await _voiceService.stop();
    if (!mounted) return;
    setState(() {
      _isConnecting = false;
      _isTalking = false;
      _status = '대화를 종료했습니다.';
    });
  }

  Future<void> _closeScreen() async {
    await _voiceService.stop();
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _setStatus(String message) {
    if (!mounted) return;
    setState(() {
      _status = message;
    });
  }

  void _recordEvent(Map<String, dynamic> event) {
    if (!mounted) return;
    final type = event['type'];
    if (type is! String) return;

    var transcriptChanged = false;

    setState(() {
      _recentEvents.insert(0, type);
      if (_recentEvents.length > 8) {
        _recentEvents.removeLast();
      }

      transcriptChanged = _applyTranscriptEvent(event, type);

      if (type == 'conversation.item.input_audio_transcription.failed') {
        final error = event['error'];
        final message = error is Map<String, dynamic> ? error['message'] : null;
        _transcriptionError =
            message is String && message.isNotEmpty
                ? '내 말 음성 인식 실패: $message'
                : '내 말을 글로 변환하지 못했습니다. 다시 말씀해 주세요.';
      }
    });

    if (transcriptChanged) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_transcriptScrollController.hasClients) return;
        _transcriptScrollController.animateTo(
          _transcriptScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      });
    }
  }

  bool _applyTranscriptEvent(
    Map<String, dynamic> event,
    String type,
  ) {
    final eventId = event['event_id'];
    if (eventId is String && !_transcriptEventIds.add(eventId)) {
      return false;
    }

    final role = switch (type) {
      'conversation.item.input_audio_transcription.delta' =>
        _TranscriptRole.user,
      'conversation.item.input_audio_transcription.completed' =>
        _TranscriptRole.user,
      'response.output_audio_transcript.delta' => _TranscriptRole.assistant,
      'response.output_audio_transcript.done' => _TranscriptRole.assistant,
      _ => null,
    };
    if (role == null) return false;

    final isDelta = type.endsWith('.delta');
    final value = event[isDelta ? 'delta' : 'transcript'];
    if (value is! String || value.isEmpty) return false;

    final itemId = event['item_id'];
    final id = '${role.name}:${itemId ?? eventId ?? value.hashCode}';
    final existingIndex = _transcriptMessages.indexWhere(
      (message) => message.id == id,
    );

    if (existingIndex == -1) {
      _transcriptMessages.add(
        _TranscriptMessage(
          id: id,
          role: role,
          text: isDelta ? value : value.trim(),
        ),
      );
    } else {
      final existing = _transcriptMessages[existingIndex];
      _transcriptMessages[existingIndex] = existing.copyWith(
        text: isDelta ? existing.text + value : value.trim(),
      );
    }

    if (role == _TranscriptRole.user) {
      _transcriptionError = null;
    }
    return true;
  }

  String _friendlyError(Object error) {
    final text = error.toString().replaceFirst(
      RegExp(r'^\w+(?:Exception)?: '),
      '',
    );
    if (text.contains('Connection refused') ||
        text.contains('Failed host lookup') ||
        text.contains('timed out')) {
      return '실시간 음성 서버에 연결하지 못했습니다. 인터넷 연결을 확인해 주세요.';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F7F68);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: '[${widget.sessionIndex}회차] 실시간 향기 대화',
        onBackPressed: _closeScreen,
        logoutEnabled: false,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            top: 50,
            child: Image.asset(
              'assets/images/blurred_background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        '대화 내용은 DB에 저장되지 않습니다.',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF665F57),
                        ),
                      ),
                      const SizedBox(height: 22),
                      InputDecorator(
                        decoration: const InputDecoration(
                          labelText: '선택한 향기',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.local_florist),
                        ),
                        child: Text(widget.initialScent),
                      ),
                      const SizedBox(height: 22),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color:
                              _isTalking
                                  ? const Color(0xFFE2F0E8)
                                  : const Color(0xFFF5F3EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            if (_isConnecting)
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                ),
                              )
                            else
                              Icon(
                                _isTalking ? Icons.mic : Icons.mic_none,
                                color: _isTalking ? green : Colors.black54,
                              ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _status,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              onPressed:
                                  _isConnecting || _isTalking
                                      ? null
                                      : _startConversation,
                              style: FilledButton.styleFrom(
                                backgroundColor: green,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('대화 시작'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              onPressed:
                                  _isConnecting || _isTalking
                                      ? _stopConversation
                                      : null,
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: const Text('대화 종료'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildTranscriptPanel(green),
                const SizedBox(height: 16),
                ExpansionTile(
                  title: const Text('개발 이벤트'),
                  subtitle: const Text('최근 8개 이벤트만 화면에 표시하며 저장하지 않습니다.'),
                  children:
                      _recentEvents.isEmpty
                          ? const [ListTile(title: Text('아직 수신한 이벤트가 없습니다.'))]
                          : _recentEvents
                              .map(
                                (event) =>
                                    ListTile(dense: true, title: Text(event)),
                              )
                              .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptPanel(Color green) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '실시간 대화 내용',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            '음성 인식 확인용이며, 현재 화면에만 표시되고 DB에는 저장되지 않습니다.',
            style: TextStyle(fontSize: 13, color: Color(0xFF665F57)),
          ),
          if (_transcriptionError != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFE9E7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _transcriptionError!,
                style: const TextStyle(
                  color: Color(0xFF9C2F28),
                  fontSize: 13,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child:
                _transcriptMessages.isEmpty
                    ? const Center(
                      child: Text(
                        '대화를 시작하고 말씀하면\n나와 AI의 말이 여기에 표시됩니다.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.black54, height: 1.5),
                      ),
                    )
                    : ListView.separated(
                      controller: _transcriptScrollController,
                      itemCount: _transcriptMessages.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildTranscriptBubble(
                          _transcriptMessages[index],
                          green,
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranscriptBubble(_TranscriptMessage message, Color green) {
    final isUser = message.role == _TranscriptRole.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 290),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? green : const Color(0xFFF1EFEA),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isUser ? 18 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isUser ? '나' : 'AI',
                style: TextStyle(
                  color: isUser ? Colors.white70 : green,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF292520),
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
