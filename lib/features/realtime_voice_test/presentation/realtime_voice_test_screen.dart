import 'package:deepscent_cnu/secrets.dart';
import 'package:flutter/material.dart';

import '../service/realtime_voice_service.dart';

class RealtimeVoiceTestScreen extends StatefulWidget {
  const RealtimeVoiceTestScreen({super.key});

  @override
  State<RealtimeVoiceTestScreen> createState() =>
      _RealtimeVoiceTestScreenState();
}

class _RealtimeVoiceTestScreenState extends State<RealtimeVoiceTestScreen>
    with WidgetsBindingObserver {
  final RealtimeVoiceService _voiceService = RealtimeVoiceService();
  final TextEditingController _scentController = TextEditingController(
    text: '커피',
  );
  late final TextEditingController _serverController;

  final List<String> _recentEvents = [];
  String _status = '서버를 실행한 뒤 대화 시작을 눌러 주세요.';
  bool _isConnecting = false;
  bool _isTalking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _serverController = TextEditingController(text: _defaultServerUrl());
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
    _scentController.dispose();
    _serverController.dispose();
    super.dispose();
  }

  String _defaultServerUrl() {
    return realtimeVoiceBaseUrl;
  }

  Future<void> _startConversation() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isConnecting = true;
      _recentEvents.clear();
      _status = '연결을 준비하고 있어요…';
    });

    try {
      await _voiceService.start(
        serverBaseUrl: _serverController.text,
        scent: _scentController.text,
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

    setState(() {
      _recentEvents.insert(0, type);
      if (_recentEvents.length > 8) {
        _recentEvents.removeLast();
      }
    });
  }

  String _friendlyError(Object error) {
    final text = error.toString().replaceFirst(
      RegExp(r'^\w+(?:Exception)?: '),
      '',
    );
    if (text.contains('Connection refused') ||
        text.contains('Failed host lookup') ||
        text.contains('timed out')) {
      return '로컬 음성 서버에 연결하지 못했습니다. 서버 실행과 주소를 확인해 주세요.';
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF4F7F68);

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3EFE8),
        elevation: 0,
        title: const Text('실시간 향기 대화 테스트'),
      ),
      body: SafeArea(
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
                    'DB 저장 없이 음성 연결만 확인합니다.',
                    style: TextStyle(fontSize: 15, color: Color(0xFF665F57)),
                  ),
                  const SizedBox(height: 22),
                  TextField(
                    controller: _scentController,
                    enabled: !_isConnecting && !_isTalking,
                    decoration: const InputDecoration(
                      labelText: '지금 맡고 있는 향기',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _serverController,
                    enabled: !_isConnecting && !_isTalking,
                    keyboardType: TextInputType.url,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      labelText: '로컬 음성 서버 주소',
                      border: OutlineInputBorder(),
                    ),
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
                            child: CircularProgressIndicator(strokeWidth: 2.5),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
    );
  }
}
