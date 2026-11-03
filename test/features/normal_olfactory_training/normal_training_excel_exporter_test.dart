import 'package:deepscent_cnu/features/normal_olfactory_training/data/export/normal_training_excel_exporter.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('일반 후각 훈련 전체 Excel에 필요한 네 시트와 열만 생성한다', () {
    final exporter = NormalTrainingExcelExporter();
    final workbook = exporter.buildWorkbook(
      sessions: [
        {
          'client_id': 'session-1',
          'participant_code': '1950-홍길동',
          'participant_name': '홍길동',
          'participant_birth_year': 1950,
          'participant_gender': '남성',
          'completed_at': '2026-11-03T10:30:00',
        },
      ],
      rounds: [
        {
          'session_client_id': 'session-1',
          'round_number': 1,
          'correct_option': '베이비파우더',
          'selected_option': '베이비파우더',
          'is_correct': 1,
          'time_taken': 4,
          'scent_strength': 2,
        },
      ],
      surveyResponses: [
        {
          'session_client_id': 'session-1',
          'question_key': 'education_level',
          'question_text': '교육 수준을 선택해 주세요.',
          'answer': '대학교 졸업',
        },
      ],
    );

    final bytes = workbook.save();
    expect(bytes, isNotNull);

    final decoded = Excel.decodeBytes(bytes!);
    expect(
      decoded.tables.keys,
      containsAll(['참여자', '훈련 세션', '문항별 응답', '설문 응답']),
    );

    expect(_textRow(decoded['참여자'].rows.first), [
      'participant_code',
      'participant_name',
      'birth_year',
      'gender',
    ]);
    expect(_textRow(decoded['훈련 세션'].rows.first), [
      'session_id',
      'participant_code',
      'completed_at',
      'timezone',
      'question_count',
      'correct_count',
      'accuracy_percent',
      'response_time_sum_sec',
    ]);
    expect(_textRow(decoded['문항별 응답'].rows.first), [
      'session_id',
      'participant_code',
      'completed_at',
      'round_number',
      'correct_option',
      'selected_option',
      'is_correct',
      'identification_response_time_sec',
      'scent_strength_code',
      'scent_strength_label',
      'option_1',
      'option_2',
      'option_3',
      'option_4',
      'was_skipped',
    ]);
    expect(_textRow(decoded['설문 응답'].rows.first), [
      'session_id',
      'participant_code',
      'question_key',
      'question_text',
      'answer',
    ]);
  });
}

List<String> _textRow(List<Data?> row) {
  return row.map((cell) => cell?.value?.toString() ?? '').toList();
}
