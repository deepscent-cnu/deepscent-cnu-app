import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/local/normal_training_local_database.dart';
import 'package:flutter/material.dart';

class NormalTrainingLocalHistoryScreen extends StatefulWidget {
  const NormalTrainingLocalHistoryScreen({super.key});

  @override
  State<NormalTrainingLocalHistoryScreen> createState() =>
      _NormalTrainingLocalHistoryScreenState();
}

class _NormalTrainingLocalHistoryScreenState
    extends State<NormalTrainingLocalHistoryScreen> {
  final _localDatabase = NormalTrainingLocalDatabase.instance;
  late Future<List<Map<String, Object?>>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = _localDatabase.getTrainingSessions();
  }

  Future<void> _refresh() async {
    final future = _localDatabase.getTrainingSessions();
    setState(() {
      _sessionsFuture = future;
    });
    await future;
  }

  String _formatDate(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '-';

    final date = parsed.toLocal();
    String twoDigits(int number) => number.toString().padLeft(2, '0');

    return '${date.year}.${twoDigits(date.month)}.${twoDigits(date.day)} '
        '${twoDigits(date.hour)}:${twoDigits(date.minute)}:${twoDigits(date.second)}';
  }

  String _formatDuration(Object? value) {
    final seconds = (value as num?)?.toInt() ?? 0;
    return '${seconds ~/ 60}분 ${seconds % 60}초';
  }

  ({String label, Color color}) _syncStatus(Object? value) {
    switch (value?.toString()) {
      case 'synced':
        return (label: '서버 저장 완료', color: Colors.green);
      case 'failed':
        return (label: '서버 전송 실패', color: Colors.orange);
      default:
        return (label: '서버 전송 대기', color: Colors.blueGrey);
    }
  }

  String _strengthLabel(Object? value) {
    switch ((value as num?)?.toInt()) {
      case 1:
        return '약함';
      case 2:
        return '보통';
      case 3:
        return '강함';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: '로컬 저장 기록',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, Object?>>>(
          future: _sessionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _MessageList(
                message: '로컬 기록을 불러오지 못했습니다.\n${snapshot.error}',
                onRefresh: _refresh,
              );
            }

            final sessions = snapshot.data ?? const [];
            if (sessions.isEmpty) {
              return _MessageList(
                message: '이 휴대폰에 저장된 일반 후각 훈련 기록이 없습니다.',
                onRefresh: _refresh,
              );
            }

            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(screenWidth * 0.04),
                itemCount: sessions.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  return _buildSessionCard(context, sessions[index], index);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionCard(
    BuildContext context,
    Map<String, Object?> session,
    int index,
  ) {
    final clientId = session['client_id']?.toString() ?? '';
    final participantCode = session['participant_code']?.toString() ?? '';
    final participantName = session['participant_name']?.toString() ?? '';
    final status = _syncStatus(session['sync_status']);
    final retryCount = (session['retry_count'] as num?)?.toInt() ?? 0;

    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF335928),
          foregroundColor: Colors.white,
          child: Text('${index + 1}'),
        ),
        title: Text(
          participantCode.isEmpty
              ? '참여자 정보가 없는 기존 기록'
              : '$participantCode · $participantName',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('완료: ${_formatDate(session['completed_at'])}'),
              if (participantCode.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  '출생연도: ${session['participant_birth_year']} · '
                  '성별: ${session['participant_gender'] ?? '-'}',
                ),
              ],
              const SizedBox(height: 4),
              Text('총 소요시간: ${_formatDuration(session['total_time_taken'])}'),
              const SizedBox(height: 4),
              Text(
                '${status.label}${retryCount > 0 ? ' · 시도 $retryCount회' : ''}',
                style: TextStyle(
                  color: status.color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        children: [
          if (participantCode.isNotEmpty)
            FutureBuilder<List<Map<String, Object?>>>(
              future: _localDatabase.getSurveyResponses(clientId),
              builder: (context, snapshot) {
                final responses = snapshot.data ?? const [];
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  );
                }

                if (responses.isEmpty) return const SizedBox.shrink();

                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  color: const Color(0xFFF4F7F3),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '기본 설문 응답',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      for (final response in responses) ...[
                        Text(
                          response['question_text']?.toString() ?? '-',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 3),
                        Text('응답: ${response['answer'] ?? '-'}'),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                );
              },
            ),
          FutureBuilder<List<Map<String, Object?>>>(
            future: _localDatabase.getTrainingRounds(clientId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                );
              }

              final rounds = snapshot.data ?? const [];
              if (rounds.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('저장된 문항 기록이 없습니다.'),
                );
              }

              return Column(
                children: [
                  const Divider(height: 1),
                  for (final round in rounds) _buildRoundTile(round),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoundTile(Map<String, Object?> round) {
    final isCorrect = (round['is_correct'] as num?)?.toInt() == 1;
    final roundNumber = (round['round_number'] as num?)?.toInt() ?? 0;

    return ListTile(
      dense: true,
      leading: Icon(
        isCorrect ? Icons.check_circle : Icons.cancel,
        color: isCorrect ? Colors.green : Colors.red,
      ),
      title: Text(
        '$roundNumber번 · 선택: ${round['selected_option']}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '정답: ${round['correct_option']} · '
        '반응시간: ${round['time_taken']}초 · '
        '강도: ${_strengthLabel(round['scent_strength'])}',
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.message, required this.onRefresh});

  final String message;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(32),
        children: [
          const SizedBox(height: 120),
          const Icon(Icons.storage_outlined, size: 64, color: Colors.grey),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
