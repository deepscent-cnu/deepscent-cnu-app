import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class NormalTrainingLocalDatabase {
  NormalTrainingLocalDatabase._();

  static final NormalTrainingLocalDatabase instance =
      NormalTrainingLocalDatabase._();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'deepscent.db');

    _database = await openDatabase(
      path,
      version: 2,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createParticipantTable(db);

        await db.execute('''
          CREATE TABLE normal_training_session (
            client_id TEXT PRIMARY KEY,
            participant_code TEXT,
            total_time_taken INTEGER NOT NULL,
            completed_at TEXT NOT NULL,
            sync_status TEXT NOT NULL DEFAULT 'pending',
            retry_count INTEGER NOT NULL DEFAULT 0,
            last_error TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE normal_training_round (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            session_client_id TEXT NOT NULL,
            round_number INTEGER NOT NULL,
            correct_option TEXT NOT NULL,
            selected_option TEXT NOT NULL,
            is_correct INTEGER NOT NULL,
            time_taken INTEGER NOT NULL,
            scent_strength INTEGER NOT NULL,
            FOREIGN KEY(session_client_id)
              REFERENCES normal_training_session(client_id)
              ON DELETE CASCADE,
            UNIQUE(session_client_id, round_number)
          )
        ''');

        await _createSurveyResponseTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createParticipantTable(db);

          final columns = await db.rawQuery(
            'PRAGMA table_info(normal_training_session)',
          );
          final hasParticipantCode = columns.any(
            (column) => column['name'] == 'participant_code',
          );
          if (!hasParticipantCode) {
            await db.execute(
              'ALTER TABLE normal_training_session ADD COLUMN participant_code TEXT',
            );
          }

          await _createSurveyResponseTable(db);
        }
      },
    );

    return _database!;
  }

  Future<String> saveTraining({
    required String clientId,
    required String participantCode,
    required String participantName,
    required int participantBirthYear,
    required List<Map<String, String>> surveyResponses,
    required int totalTimeTaken,
    required List<Map<String, dynamic>> roundLogs,
  }) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.insert(
        'normal_training_participant',
        {
          'participant_code': participantCode,
          'name': participantName,
          'birth_year': participantBirthYear,
          'gender':
              surveyResponses
                  .where((response) => response['question_key'] == 'gender')
                  .map((response) => response['answer'])
                  .firstOrNull,
          'updated_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert('normal_training_session', {
        'client_id': clientId,
        'participant_code': participantCode,
        'total_time_taken': totalTimeTaken,
        'completed_at': DateTime.now().toIso8601String(),
        'sync_status': 'pending',
        'retry_count': 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      for (final response in surveyResponses) {
        await txn.insert('normal_training_survey_response', {
          'session_client_id': clientId,
          'question_key': response['question_key'],
          'question_text': response['question_text'],
          'answer': response['answer'],
        });
      }

      for (var index = 0; index < roundLogs.length; index++) {
        final log = roundLogs[index];

        await txn.insert('normal_training_round', {
          'session_client_id': clientId,
          'round_number': index + 1,
          'correct_option': log['correctOption'],
          'selected_option': log['selectedOption'],
          'is_correct': log['isCorrect'] == true ? 1 : 0,
          'time_taken': log['timeTaken'],
          'scent_strength': log['scentStrength'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });

    return clientId;
  }

  Future<void> markSynced(String clientId) async {
    final db = await database;

    await db.update(
      'normal_training_session',
      {'sync_status': 'synced', 'last_error': null},
      where: 'client_id = ?',
      whereArgs: [clientId],
    );
  }

  Future<void> markSyncFailed(String clientId, Object error) async {
    final db = await database;

    await db.rawUpdate(
      '''
      UPDATE normal_training_session
      SET sync_status = ?,
          retry_count = retry_count + 1,
          last_error = ?
      WHERE client_id = ?
      ''',
      ['failed', error.toString(), clientId],
    );
  }

  Future<List<Map<String, Object?>>> getTrainingSessions() async {
    final db = await database;
    return db.rawQuery('''
      SELECT session.*,
             participant.name AS participant_name,
             participant.birth_year AS participant_birth_year,
             participant.gender AS participant_gender
      FROM normal_training_session AS session
      LEFT JOIN normal_training_participant AS participant
        ON participant.participant_code = session.participant_code
      ORDER BY session.completed_at DESC
    ''');
  }

  Future<List<Map<String, Object?>>> getTrainingRounds(String clientId) async {
    final db = await database;
    return db.query(
      'normal_training_round',
      where: 'session_client_id = ?',
      whereArgs: [clientId],
      orderBy: 'round_number ASC',
    );
  }

  Future<List<Map<String, Object?>>> getSurveyResponses(String clientId) async {
    final db = await database;
    return db.query(
      'normal_training_survey_response',
      where: 'session_client_id = ?',
      whereArgs: [clientId],
      orderBy: 'id ASC',
    );
  }

  Future<void> _createParticipantTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS normal_training_participant (
        participant_code TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        birth_year INTEGER NOT NULL,
        gender TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createSurveyResponseTable(DatabaseExecutor db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS normal_training_survey_response (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        session_client_id TEXT NOT NULL,
        question_key TEXT NOT NULL,
        question_text TEXT NOT NULL,
        answer TEXT NOT NULL,
        FOREIGN KEY(session_client_id)
          REFERENCES normal_training_session(client_id)
          ON DELETE CASCADE,
        UNIQUE(session_client_id, question_key)
      )
    ''');
  }
}
