import 'dart:async';

import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../service/realtime_voice_service.dart';

enum _TranscriptRole { user, assistant }

class _TranscriptMessage {
  final String id;
  final String itemId;
  final int sequenceNumber;
  final _TranscriptRole role;
  final String text;

  const _TranscriptMessage({
    required this.id,
    required this.itemId,
    required this.sequenceNumber,
    required this.role,
    required this.text,
  });

  _TranscriptMessage copyWith({String? text}) {
    return _TranscriptMessage(
      id: id,
      itemId: itemId,
      sequenceNumber: sequenceNumber,
      role: role,
      text: text ?? this.text,
    );
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
  final Uuid _uuid = const Uuid();

  final List<String> _recentEvents = [];
  final List<_TranscriptMessage> _transcriptMessages = [];
  final Set<String> _transcriptEventIds = {};
  final Map<String, int> _messageSequenceNumbers = {};
  String _status = '대화 시작을 누르면 바로 연결됩니다.';
  String _transcriptionStatus = '연결 전';
  String? _transcriptionError;
  String? _saveError;
  String? _clientSessionId;
  DateTime? _conversationStartedAt;
  DateTime? _conversationEndedAt;
  int _nextMessageSequence = 0;
  bool _isConnecting = false;
  bool _isTalking = false;
  bool _isSaving = false;
  bool _allowPop = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      unawaited(_pauseConversation());
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
      _messageSequenceNumbers.clear();
      _nextMessageSequence = 0;
      _clientSessionId = _uuid.v4();
      _conversationStartedAt = DateTime.now().toUtc();
      _conversationEndedAt = null;
      _transcriptionStatus = '설정 확인 중…';
      _transcriptionError = null;
      _saveError = null;
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
        if (_transcriptMessages.isEmpty) {
          _clientSessionId = null;
          _conversationStartedAt = null;
        }
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
    if (_isSaving || _clientSessionId == null) return;

    final wasTalking = _isTalking;
    setState(() {
      _isSaving = true;
      _saveError = null;
      _status = wasTalking ? '마지막 문장을 확인하고 있어요…' : '대화 내용을 저장하고 있어요…';
    });

    if (wasTalking) {
      await Future<void>.delayed(const Duration(milliseconds: 1500));
    }

    _conversationEndedAt ??= DateTime.now().toUtc();

    try {
      await _voiceService.stop();
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isTalking = false;
        _status = '대화 내용을 저장하고 있어요…';
      });

      final messages = [..._transcriptMessages]
        ..sort((a, b) => a.sequenceNumber.compareTo(b.sequenceNumber));
      await _voiceService.saveCompletedConversation(
        clientSessionId: _clientSessionId!,
        round: widget.sessionIndex,
        scent: widget.initialScent,
        startedAt: _conversationStartedAt!,
        endedAt: _conversationEndedAt!,
        messages:
            messages
                .where((message) => message.text.trim().isNotEmpty)
                .map(
                  (message) => RealtimeConversationMessagePayload(
                    itemId: message.itemId,
                    sequenceNumber: message.sequenceNumber,
                    role: message.role.name.toUpperCase(),
                    content: message.text.trim(),
                  ),
                )
                .toList(),
      );

      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _status = '대화 내용이 저장되었습니다.';
        _allowPop = true;
      });
      _popAfterNextFrame(true);
    } catch (error) {
      if (!mounted) return;
      final message = _friendlyError(error);
      setState(() {
        _isSaving = false;
        _saveError = message;
        _status = '저장하지 못했습니다. 대화 내용은 그대로 유지됩니다.';
      });
    }
  }

  Future<void> _closeScreen() async {
    if (_isSaving) return;
    if (_clientSessionId != null) {
      await _stopConversation();
      return;
    }
    await _voiceService.stop();
    if (!mounted) return;
    setState(() {
      _allowPop = true;
    });
    _popAfterNextFrame();
  }

  Future<void> _pauseConversation() async {
    if (!_voiceService.isActive) return;
    try {
      await _voiceService.stop();
      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isTalking = false;
        _status = '음성 연결이 중단되었습니다. 대화 종료를 눌러 저장해 주세요.';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = '음성 연결을 정리하지 못했습니다. 대화 종료를 다시 눌러 주세요.';
      });
    }
  }

  void _popAfterNextFrame([Object? result]) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
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

      _captureMessageOrder(event, type);
      transcriptChanged = _applyTranscriptEvent(event, type);
      _updateTranscriptionStatus(event, type);

      if (type == 'conversation.item.input_audio_transcription.failed') {
        final error = event['error'];
        final message = error is Map<String, dynamic> ? error['message'] : null;
        _transcriptionError =
            message is String && message.isNotEmpty
                ? '내 말 음성 인식 실패: $message'
                : '내 말을 글로 변환하지 못했습니다. 다시 말씀해 주세요.';
      }

      if (type == 'error') {
        final error = event['error'];
        final message = error is Map<String, dynamic> ? error['message'] : null;
        if (message is String &&
            message.toLowerCase().contains('transcription')) {
          _transcriptionError = '음성 인식 설정 오류: $message';
          _transcriptionStatus = '설정 오류';
        }
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

  void _captureMessageOrder(Map<String, dynamic> event, String type) {
    switch (type) {
      case 'input_audio_buffer.committed':
        final itemId = event['item_id'];
        if (itemId is String) _sequenceFor(_TranscriptRole.user, itemId);
      case 'conversation.item.added':
      case 'response.output_item.added':
        final item = event['item'];
        if (item is! Map<String, dynamic>) return;
        final itemId = item['id'];
        final role = switch (item['role']) {
          'user' => _TranscriptRole.user,
          'assistant' => _TranscriptRole.assistant,
          _ => null,
        };
        if (itemId is String && role != null) _sequenceFor(role, itemId);
    }
  }

  int _sequenceFor(_TranscriptRole role, String itemId) {
    final key = '${role.name}:$itemId';
    return _messageSequenceNumbers.putIfAbsent(
      key,
      () => _nextMessageSequence++,
    );
  }

  void _updateTranscriptionStatus(Map<String, dynamic> event, String type) {
    switch (type) {
      case 'session.created':
      case 'session.updated':
        final session = event['session'];
        final audio = session is Map<String, dynamic> ? session['audio'] : null;
        final input = audio is Map<String, dynamic> ? audio['input'] : null;
        final transcription =
            input is Map<String, dynamic> ? input['transcription'] : null;
        final model =
            transcription is Map<String, dynamic>
                ? transcription['model']
                : null;
        _transcriptionStatus =
            model is String && model.isNotEmpty ? '준비됨 ($model)' : '꺼져 있음';
      case 'input_audio_buffer.speech_started':
        _transcriptionStatus = '말씀 감지됨';
      case 'input_audio_buffer.speech_stopped':
      case 'input_audio_buffer.committed':
        _transcriptionStatus = '문장 변환 중…';
      case 'conversation.item.input_audio_transcription.delta':
        _transcriptionStatus = '문장 수신 중…';
      case 'conversation.item.input_audio_transcription.completed':
        _transcriptionStatus = '정상 작동';
      case 'conversation.item.input_audio_transcription.failed':
        _transcriptionStatus = '인식 실패';
    }
  }

  bool _applyTranscriptEvent(Map<String, dynamic> event, String type) {
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

    final eventId = event['event_id'];
    if (eventId is String && !_transcriptEventIds.add(eventId)) {
      return false;
    }

    final isDelta = type.endsWith('.delta');
    final value = event[isDelta ? 'delta' : 'transcript'];
    if (value is! String || value.isEmpty) return false;

    final rawItemId = event['item_id'];
    final itemId =
        rawItemId is String
            ? rawItemId
            : eventId is String
            ? eventId
            : '${role.name}-${value.hashCode}-$_nextMessageSequence';
    final id = '${role.name}:$itemId';
    final existingIndex = _transcriptMessages.indexWhere(
      (message) => message.id == id,
    );

    if (existingIndex == -1) {
      _transcriptMessages.add(
        _TranscriptMessage(
          id: id,
          itemId: itemId,
          sequenceNumber: _sequenceFor(role, itemId),
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
    final hasStartedConversation = _clientSessionId != null;

    return PopScope(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_closeScreen());
      },
      child: Scaffold(
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
                          '대화 종료 시 전체 대화가 서버에 한 번 저장됩니다.',
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
                              if (_isConnecting || _isSaving)
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
                                    _isConnecting ||
                                            _isTalking ||
                                            _isSaving ||
                                            hasStartedConversation
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
                                    !_isConnecting &&
                                            !_isSaving &&
                                            hasStartedConversation
                                        ? _stopConversation
                                        : null,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: Text(
                                  _isSaving
                                      ? '저장 중…'
                                      : _saveError != null
                                      ? '저장 재시도'
                                      : '대화 종료',
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (_saveError != null) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE9E7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  '저장에 실패했습니다. 아래 대화 내용은 지워지지 않았습니다.',
                                  style: TextStyle(
                                    color: Color(0xFF9C2F28),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _saveError!,
                                  style: const TextStyle(
                                    color: Color(0xFF9C2F28),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                OutlinedButton.icon(
                                  onPressed:
                                      _isSaving ? null : _stopConversation,
                                  icon: const Icon(Icons.refresh),
                                  label: const Text('저장 다시 시도'),
                                ),
                              ],
                            ),
                          ),
                        ],
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
            '대화를 종료하면 나와 AI의 메시지를 순서대로 서버에 저장합니다.',
            style: TextStyle(fontSize: 13, color: Color(0xFF665F57)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3EE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.hearing, size: 19, color: Color(0xFF4F7F68)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '내 말 인식: $_transcriptionStatus',
                    style: const TextStyle(
                      color: Color(0xFF355B49),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
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
                style: const TextStyle(color: Color(0xFF9C2F28), fontSize: 13),
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
