import 'dart:async';
import 'dart:convert';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:http/http.dart' as http;

typedef RealtimeStatusCallback = void Function(String message);
typedef RealtimeEventCallback = void Function(Map<String, dynamic> event);

class RealtimeVoiceService {
  RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  MediaStream? _microphoneStream;

  bool get isActive => _peerConnection != null;

  Future<void> start({
    required String serverBaseUrl,
    required String scent,
    required RealtimeStatusCallback onStatus,
    required RealtimeEventCallback onEvent,
  }) async {
    await stop();

    final normalizedBaseUrl = serverBaseUrl.trim().replaceFirst(
      RegExp(r'/$'),
      '',
    );
    if (normalizedBaseUrl.isEmpty) {
      throw const FormatException('로컬 서버 주소를 입력해 주세요.');
    }

    onStatus('마이크 권한을 확인하고 있어요…');

    try {
      final peerConnection = await createPeerConnection({
        'sdpSemantics': 'unified-plan',
      });
      _peerConnection = peerConnection;

      peerConnection.onConnectionState = (state) {
        switch (state) {
          case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
            onStatus('연결되었습니다. 편하게 말씀해 주세요.');
          case RTCPeerConnectionState.RTCPeerConnectionStateDisconnected:
            onStatus('연결이 잠시 불안정합니다…');
          case RTCPeerConnectionState.RTCPeerConnectionStateFailed:
            onStatus('음성 연결에 실패했습니다.');
          case RTCPeerConnectionState.RTCPeerConnectionStateClosed:
            onStatus('대화가 종료되었습니다.');
          default:
            break;
        }
      };

      peerConnection.onTrack = (event) {
        if (event.track.kind == 'audio') {
          onStatus('AI 음성 연결이 준비되었습니다.');
        }
      };

      final microphoneStream = await navigator.mediaDevices.getUserMedia({
        'audio': {
          'echoCancellation': true,
          'noiseSuppression': true,
          'autoGainControl': true,
        },
        'video': false,
      });
      _microphoneStream = microphoneStream;

      for (final track in microphoneStream.getAudioTracks()) {
        await peerConnection.addTrack(track, microphoneStream);
      }

      final dataChannel = await peerConnection.createDataChannel(
        'oai-events',
        RTCDataChannelInit()..ordered = true,
      );
      _dataChannel = dataChannel;

      dataChannel.onDataChannelState = (state) {
        if (state == RTCDataChannelState.RTCDataChannelOpen) {
          onStatus('연결되었습니다. 편하게 말씀해 주세요.');
        }
      };
      dataChannel.onMessage = (message) {
        if (message.isBinary) return;

        try {
          final decoded = jsonDecode(message.text);
          if (decoded is! Map<String, dynamic>) return;
          onEvent(decoded);
          _updateStatusFromEvent(decoded, onStatus);
        } catch (_) {
          // 디버그 화면에서는 해석할 수 없는 이벤트를 조용히 무시합니다.
        }
      };

      onStatus('AI와 음성 채널을 연결하고 있어요…');
      final offer = await peerConnection.createOffer();
      await peerConnection.setLocalDescription(offer);
      await _waitForIceGathering(peerConnection);

      final localDescription = await peerConnection.getLocalDescription();
      final sdp = localDescription?.sdp;
      if (sdp == null || sdp.trim().isEmpty) {
        throw StateError('앱이 음성 연결 정보를 만들지 못했습니다.');
      }

      final response = await http
          .post(
            Uri.parse('$normalizedBaseUrl/api/session'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'sdp': sdp, 'scent': scent.trim()}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw StateError(_readServerError(response));
      }

      await peerConnection.setRemoteDescription(
        RTCSessionDescription(response.body, 'answer'),
      );
    } catch (_) {
      await stop();
      rethrow;
    }
  }

  Future<void> stop() async {
    final dataChannel = _dataChannel;
    final microphoneStream = _microphoneStream;
    final peerConnection = _peerConnection;

    _dataChannel = null;
    _microphoneStream = null;
    _peerConnection = null;

    await dataChannel?.close();

    if (microphoneStream != null) {
      for (final track in microphoneStream.getTracks()) {
        await track.stop();
      }
      await microphoneStream.dispose();
    }

    await peerConnection?.close();
    await peerConnection?.dispose();
  }

  Future<void> _waitForIceGathering(RTCPeerConnection connection) async {
    if (connection.iceGatheringState ==
        RTCIceGatheringState.RTCIceGatheringStateComplete) {
      return;
    }

    final completer = Completer<void>();
    connection.onIceGatheringState = (state) {
      if (state == RTCIceGatheringState.RTCIceGatheringStateComplete &&
          !completer.isCompleted) {
        completer.complete();
      }
    };

    await Future.any([
      completer.future,
      Future<void>.delayed(const Duration(seconds: 5)),
    ]);
  }

  void _updateStatusFromEvent(
    Map<String, dynamic> event,
    RealtimeStatusCallback onStatus,
  ) {
    switch (event['type']) {
      case 'input_audio_buffer.speech_started':
        onStatus('말씀을 듣고 있어요…');
      case 'input_audio_buffer.speech_stopped':
        onStatus('답변을 준비하고 있어요…');
      case 'response.created':
        onStatus('AI가 생각하고 있어요…');
      case 'output_audio_buffer.started':
        onStatus('AI가 말하고 있어요…');
      case 'output_audio_buffer.stopped':
      case 'response.done':
        onStatus('이어서 말씀해 주세요.');
      case 'error':
        final error = event['error'];
        final message = error is Map<String, dynamic> ? error['message'] : null;
        onStatus(message is String ? message : '실시간 대화 중 오류가 발생했습니다.');
    }
  }

  String _readServerError(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        final message = decoded['error'];
        if (message is String && message.isNotEmpty) {
          return '$message (HTTP ${response.statusCode})';
        }
      }
    } catch (_) {
      // JSON이 아니면 아래의 일반 오류 문구를 사용합니다.
    }
    return '실시간 세션 연결에 실패했습니다. (HTTP ${response.statusCode})';
  }
}
