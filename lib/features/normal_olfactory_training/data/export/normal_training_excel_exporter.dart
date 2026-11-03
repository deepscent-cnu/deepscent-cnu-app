import 'dart:io';

import 'package:deepscent_cnu/features/normal_olfactory_training/data/local/normal_training_local_database.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/question_bank.dart';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class NormalTrainingExcelExporter {
  NormalTrainingExcelExporter({NormalTrainingLocalDatabase? localDatabase})
    : _localDatabase = localDatabase ?? NormalTrainingLocalDatabase.instance;

  final NormalTrainingLocalDatabase _localDatabase;

  Future<File> exportAll() async {
    final sessions = await _localDatabase.getTrainingSessions();
    if (sessions.isEmpty) {
      throw StateError('내보낼 일반 후각 훈련 기록이 없습니다.');
    }

    final rounds = await _localDatabase.getAllTrainingRounds();
    final surveyResponses = await _localDatabase.getAllSurveyResponses();
    final workbook = buildWorkbook(
      sessions: sessions,
      rounds: rounds,
      surveyResponses: surveyResponses,
    );
    final bytes = workbook.save();
    if (bytes == null) {
      throw StateError('Excel 파일을 생성하지 못했습니다.');
    }

    final now = DateTime.now();
    final fileName = 'deepscent_normal_training_${_timestamp(now)}.xlsx';
    final directory = await getTemporaryDirectory();
    final file = File(path.join(directory.path, fileName));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Excel buildWorkbook({
    required List<Map<String, Object?>> sessions,
    required List<Map<String, Object?>> rounds,
    required List<Map<String, Object?>> surveyResponses,
  }) {
    final workbook = Excel.createExcel();
    workbook.rename('Sheet1', '참여자');

    final sessionsById = <String, Map<String, Object?>>{
      for (final session in sessions)
        session['client_id']?.toString() ?? '': session,
    }..remove('');

    _writeParticipantsSheet(workbook['참여자'], sessions);
    _writeSessionsSheet(workbook['훈련 세션'], sessions, rounds);
    _writeRoundsSheet(workbook['문항별 응답'], rounds, sessionsById);
    _writeSurveySheet(workbook['설문 응답'], surveyResponses, sessionsById);
    workbook.setDefaultSheet('참여자');
    return workbook;
  }

  void _writeParticipantsSheet(
    Sheet sheet,
    List<Map<String, Object?>> sessions,
  ) {
    const headers = [
      'participant_code',
      'participant_name',
      'birth_year',
      'gender',
    ];
    _appendHeader(sheet, headers);

    final participants = <String, Map<String, Object?>>{};
    for (final session in sessions) {
      final participantCode = session['participant_code']?.toString() ?? '';
      if (participantCode.isEmpty) continue;
      participants.putIfAbsent(participantCode, () => session);
    }

    for (final entry in participants.entries) {
      final participant = entry.value;
      sheet.appendRow([
        TextCellValue(entry.key),
        _textCell(participant['participant_name']),
        _intCell(participant['participant_birth_year']),
        _textCell(participant['participant_gender']),
      ]);
    }

    _setColumnWidths(sheet, [24, 18, 12, 12]);
  }

  void _writeSessionsSheet(
    Sheet sheet,
    List<Map<String, Object?>> sessions,
    List<Map<String, Object?>> rounds,
  ) {
    const headers = [
      'session_id',
      'participant_code',
      'completed_at',
      'timezone',
      'question_count',
      'correct_count',
      'accuracy_percent',
      'response_time_sum_sec',
    ];
    _appendHeader(sheet, headers);

    final roundsBySession = <String, List<Map<String, Object?>>>{};
    for (final round in rounds) {
      final sessionId = round['session_client_id']?.toString() ?? '';
      if (sessionId.isEmpty) continue;
      roundsBySession.putIfAbsent(sessionId, () => []).add(round);
    }

    for (final session in sessions) {
      final sessionId = session['client_id']?.toString() ?? '';
      final sessionRounds = roundsBySession[sessionId] ?? const [];
      final correctCount = sessionRounds.where(_isCorrect).length;
      final questionCount = sessionRounds.length;
      final accuracy = questionCount == 0 ? 0.0 : correctCount / questionCount;
      final responseTimeSum = sessionRounds.fold<int>(
        0,
        (sum, round) => sum + _asInt(round['time_taken']),
      );

      sheet.appendRow([
        TextCellValue(sessionId),
        _textCell(session['participant_code']),
        _dateTimeCell(session['completed_at']),
        TextCellValue('Asia/Seoul'),
        IntCellValue(questionCount),
        IntCellValue(correctCount),
        DoubleCellValue(accuracy),
        IntCellValue(responseTimeSum),
      ]);

      final rowIndex = sheet.maxRows - 1;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .cellStyle = _dateStyle;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
          .cellStyle = _percentStyle;
    }

    _setColumnWidths(sheet, [38, 24, 22, 14, 15, 14, 18, 24]);
  }

  void _writeRoundsSheet(
    Sheet sheet,
    List<Map<String, Object?>> rounds,
    Map<String, Map<String, Object?>> sessionsById,
  ) {
    const headers = [
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
    ];
    _appendHeader(sheet, headers);

    for (final round in rounds) {
      final sessionId = round['session_client_id']?.toString() ?? '';
      final session = sessionsById[sessionId];
      final roundNumber = _asInt(round['round_number']);
      final selectedOption = round['selected_option']?.toString() ?? '';
      final strengthCode = _asInt(round['scent_strength']);
      final options = _optionsForRound(roundNumber);

      sheet.appendRow([
        TextCellValue(sessionId),
        _textCell(session?['participant_code']),
        _dateTimeCell(session?['completed_at']),
        IntCellValue(roundNumber),
        _textCell(round['correct_option']),
        TextCellValue(selectedOption),
        BoolCellValue(_isCorrect(round)),
        IntCellValue(_asInt(round['time_taken'])),
        IntCellValue(strengthCode),
        TextCellValue(_strengthLabel(strengthCode)),
        for (final option in options) TextCellValue(option),
        BoolCellValue(selectedOption.trim().isEmpty),
      ]);

      final rowIndex = sheet.maxRows - 1;
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
          .cellStyle = _dateStyle;
    }

    _setColumnWidths(sheet, [
      38,
      24,
      22,
      14,
      18,
      18,
      12,
      31,
      20,
      22,
      16,
      16,
      16,
      16,
      14,
    ]);
  }

  void _writeSurveySheet(
    Sheet sheet,
    List<Map<String, Object?>> surveyResponses,
    Map<String, Map<String, Object?>> sessionsById,
  ) {
    const headers = [
      'session_id',
      'participant_code',
      'question_key',
      'question_text',
      'answer',
    ];
    _appendHeader(sheet, headers);

    for (final response in surveyResponses) {
      final sessionId = response['session_client_id']?.toString() ?? '';
      final session = sessionsById[sessionId];
      sheet.appendRow([
        TextCellValue(sessionId),
        _textCell(session?['participant_code']),
        _textCell(response['question_key']),
        _textCell(response['question_text']),
        _textCell(response['answer']),
      ]);
    }

    _setColumnWidths(sheet, [38, 24, 24, 44, 30]);
  }

  void _appendHeader(Sheet sheet, List<String> headers) {
    sheet.appendRow(headers.map(TextCellValue.new).toList());
    for (var columnIndex = 0; columnIndex < headers.length; columnIndex++) {
      sheet
          .cell(
            CellIndex.indexByColumnRow(columnIndex: columnIndex, rowIndex: 0),
          )
          .cellStyle = _headerStyle;
    }
  }

  List<String> _optionsForRound(int roundNumber) {
    for (final question in normalTrainingQuestionBank) {
      if (question.id == roundNumber) return question.options;
    }
    return const ['', '', '', ''];
  }

  void _setColumnWidths(Sheet sheet, List<double> widths) {
    for (var index = 0; index < widths.length; index++) {
      sheet.setColumnWidth(index, widths[index]);
    }
  }

  bool _isCorrect(Map<String, Object?> round) =>
      _asInt(round['is_correct']) == 1;

  int _asInt(Object? value) => (value as num?)?.toInt() ?? 0;

  CellValue _textCell(Object? value) => TextCellValue(value?.toString() ?? '');

  CellValue _intCell(Object? value) => IntCellValue(_asInt(value));

  CellValue _dateTimeCell(Object? value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return TextCellValue('');
    final local = parsed.toLocal();
    return DateTimeCellValue(
      year: local.year,
      month: local.month,
      day: local.day,
      hour: local.hour,
      minute: local.minute,
      second: local.second,
      millisecond: local.millisecond,
    );
  }

  String _strengthLabel(int value) {
    switch (value) {
      case 1:
        return '약함';
      case 2:
        return '보통';
      case 3:
        return '강함';
      default:
        return '미응답';
    }
  }

  static String _timestamp(DateTime value) {
    String twoDigits(int number) => number.toString().padLeft(2, '0');
    return '${value.year}'
        '${twoDigits(value.month)}'
        '${twoDigits(value.day)}_'
        '${twoDigits(value.hour)}'
        '${twoDigits(value.minute)}'
        '${twoDigits(value.second)}';
  }

  CellStyle get _headerStyle => CellStyle(
    bold: true,
    fontColorHex: ExcelColor.white,
    backgroundColorHex: ExcelColor.fromHexString('#335928'),
    horizontalAlign: HorizontalAlign.Center,
    verticalAlign: VerticalAlign.Center,
  );

  CellStyle get _dateStyle => CellStyle(
    numberFormat: CustomDateTimeNumFormat(formatCode: 'yyyy-mm-dd hh:mm:ss'),
  );

  CellStyle get _percentStyle =>
      CellStyle(numberFormat: CustomNumericNumFormat(formatCode: '0.0%'));
}
