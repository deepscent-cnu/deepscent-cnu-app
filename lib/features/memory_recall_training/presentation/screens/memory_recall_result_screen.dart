import 'dart:async';
import 'dart:io';
import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/features/memory_recall_training/data/memory_recall_training_api.dart';
import 'package:deepscent_cnu/features/training_list/presentation/screens/olfactory_training_list.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/memory_recall_training/presentation/screens/memory_recall_session_select_screen.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class MemoryRecallResultScreen extends StatefulWidget {
  final int sessionIndex;
  final String selectedScent;
  final Map<String, dynamic> roundData;

  const MemoryRecallResultScreen({
    super.key,
    required this.sessionIndex,
    required this.selectedScent,
    required this.roundData,
  });

  @override
  State<MemoryRecallResultScreen> createState() => _MemoryRecallResultScreenState();
}

class _MemoryRecallResultScreenState extends State<MemoryRecallResultScreen> {
  /// 오늘 느낀 점 입력 필드를 제어하기 위한 컨트롤러
  final TextEditingController _feelingController = TextEditingController();

  // === 음성 녹음/STT 상태 ===
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  String? _filePath;
  late final Stopwatch _stopwatch;
  Timer? _timer;
  bool _isTranscribing = false; // STT 로딩 상태

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();

    // 서버에 이미 feeling이 있으면 입력창에 미리 채워주기(한 번만)
    final feelingFromApi = (widget.roundData['feeling'] ?? '') as String;
    if (feelingFromApi.isNotEmpty && _feelingController.text.isEmpty) {
      _feelingController.text = feelingFromApi;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatch.stop();
    _safeStopRecording();
    _recorder.dispose();
    _feelingController.dispose();
    super.dispose();
  }

  Future<void> _safeStopRecording() async {
    if (_isRecording) {
      try {
        await _recorder.stop();
      } catch (_) {}
      _isRecording = false;
    }
  }

  String _formattedTime() {
    final seconds = _stopwatch.elapsed.inSeconds;
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  Future<void> _toggleRecording() async {
    // 이미 녹음 후 텍스트가 입력된 경우, 재녹음 여부 확인
    if (!_isRecording && _feelingController.text.trim().isNotEmpty && !_isTranscribing) {
      final shouldReRecord = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('재녹음 하시겠습니까?'),
          content: const Text('입력된 내용을 삭제하고 다시 녹음하시겠습니까?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('취소')),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('확인')),
          ],
        ),
      );
      if (shouldReRecord != true) return;
      _feelingController.clear();
    }

    if (!_isRecording) {
      // 녹음 시작
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('마이크 권한이 필요합니다. 설정에서 허용해 주세요.')),
        );
        return;
      }

      final dir = await getApplicationDocumentsDirectory();
      _filePath = '${dir.path}/feeling_record.wav';

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.wav,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: _filePath!,
      );

      setState(() {
        _isRecording = true;
        _stopwatch
          ..reset()
          ..start();
      });
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    } else {
      // 녹음 종료 → STT
      await _recorder.stop();
      _stopwatch.stop();
      _timer?.cancel();
      setState(() => _isRecording = false);

      if (_filePath != null && File(_filePath!).existsSync()) {
        setState(() => _isTranscribing = true);
        try {
          final stt = await MemoryRecallTrainingApi.sendAudioToSTT(File(_filePath!));
          if (stt != null && stt.trim().isNotEmpty) {
            _feelingController.text = stt.trim();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('음성을 인식하지 못했어요. 다시 시도해 주세요.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('음성 인식 중 오류가 발생했어요: $e')),
          );
        } finally {
          if (mounted) setState(() => _isTranscribing = false);
        }
      }
    }
  }

  /// 느낀점 저장
  Future<void> _saveFeelingIfNeeded() async {
    final feeling = _feelingController.text.trim();
    if (feeling.isNotEmpty) {
      final success = await MemoryRecallTrainingApi.saveFeeling(
        widget.roundData['id'] ?? -1,
        feeling,
      );
      if (success) {
        debugPrint('느낀점 저장 성공');
      } else {
        debugPrint('느낀점 저장 실패');
      }
    }
  }

  /// 훈련 목록 보기
  Future<void> _goToTrainingList(BuildContext context) async {
    await _saveFeelingIfNeeded();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OlfactoryTrainingListScreen()),
      (route) => false,
    );
  }

  /// 훈련 기록 보기
  Future<void> _goToTrainingLog(BuildContext context) async {
    await _saveFeelingIfNeeded();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MemoryRecallSessionSelectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // roundData에서 안전하게 꺼내 쓰기
    final String scentFromApi = (widget.roundData['scent'] ?? '') as String;
    final String summaryFromApi = (widget.roundData['summary'] ?? '') as String;
    final String createdAt = (widget.roundData['createdAt'] ?? '') as String;

    return PopScope(
      canPop: false, // 기본 pop 동작 차단
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _goToTrainingList(context);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          mode: CustomAppBarMode.sub,
          title: "기억 회상 훈련 결과",
          onBackPressed: () => _goToTrainingList(context),
        ),
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // 포커스 해제 → 키보드 닫힘
          },
          child: SafeArea(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/blurred_background_2.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.035),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(top: screenWidth * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 타이틀
                              Text(
                                '${widget.sessionIndex}회차 훈련이 끝났어요!',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.015),
                              if (createdAt.isNotEmpty)
                                Text(
                                  '진행 시각: $createdAt',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.04,
                                    color: Colors.black54,
                                  ),
                                ),
                              SizedBox(height: screenWidth * 0.06),

                              //오늘의 향기 (서버값 우선, 없으면 선택값)
                              Text(
                                '${widget.sessionIndex}회차의 향기: ${scentFromApi.isNotEmpty ? scentFromApi : widget.selectedScent}',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF335928),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.07),
                              Text(
                                '${widget.sessionIndex}회차의 회상:',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF335928),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Text(
                                summaryFromApi.isNotEmpty
                                    ? summaryFromApi
                                    : '요약이 아직 없습니다.',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.05,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 32),

                              // 오늘의 느낀 점 (입력/수정 가능 + 음성 입력)
                              Text(
                                '${widget.sessionIndex}회차 훈련 후 느낀 점:',
                                style: TextStyle(
                                  fontSize: screenWidth * 0.07,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF335928),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.015),

                              // 입력창 + 마이크 영역 (안내 문구 제거, 마이크 중앙 정렬)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x33000000),
                                      blurRadius: 12,
                                      offset: Offset(0, 6),
                                    ),
                                  ],
                                ),
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.025,
                                  vertical: screenWidth * 0.01,
                                ),
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: _feelingController,
                                      maxLines: 4,
                                      decoration: const InputDecoration(
                                        hintText: '오늘 훈련을 통해 느낀 점을 적어주세요. (선택사항)',
                                        border: InputBorder.none,
                                      ),
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const Divider(height: 16, thickness: 1, color: Color(0xFFE0E0E0)),
                                    Center(
                                      child: GestureDetector(
                                        onTap: _isTranscribing ? null : _toggleRecording,
                                        child: CircleAvatar(
                                          radius: screenWidth * 0.07,
                                          backgroundColor: _isRecording ? Colors.red : const Color(0xFF2E7D32),
                                          child: Icon(
                                            _isRecording ? Icons.stop : Icons.mic,
                                            color: Colors.white,
                                            size: screenWidth * 0.07,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    if (_isTranscribing)
                                      const Text('음성을 인식하는 중입니다...', style: TextStyle(fontWeight: FontWeight.w600))
                                    else if (_isRecording)
                                      Text('녹음중 · ${_formattedTime()}', style: const TextStyle(fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),

                              SizedBox(height: screenWidth * 0.1),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.07,
                                  vertical: screenWidth * 0.035,
                                ),
                                child: ButtonBasic(
                                  content: '훈련 기록 보기',
                                  fontSize: screenWidth * 0.07,
                                  icon: Icon(
                                    Icons.edit_document,
                                    size: screenWidth * 0.07,
                                  ),
                                  function: () => _goToTrainingLog(context),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.01),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.07,
                                  vertical: screenWidth * 0.035,
                                ),
                                child: ButtonBasic(
                                  content: '훈련 목록 보기',
                                  icon: Icon(
                                    Icons.list,
                                    size: screenWidth * 0.075,
                                  ),
                                  fontSize: screenWidth * 0.07,
                                  function: () => _goToTrainingList(context),
                                ),
                              ),
                              SizedBox(height: screenWidth * 0.05),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
