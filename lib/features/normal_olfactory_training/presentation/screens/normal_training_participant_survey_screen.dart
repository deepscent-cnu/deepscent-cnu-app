import 'package:deepscent_cnu/common/widgets/button_basic.dart';
import 'package:deepscent_cnu/common/widgets/custom_app_bar.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/data/models/normal_training_survey.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/controllers/normal_olfactory_training_controller.dart';
import 'package:deepscent_cnu/features/normal_olfactory_training/presentation/screens/normal_olfactory_training_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NormalTrainingParticipantSurveyScreen extends StatefulWidget {
  const NormalTrainingParticipantSurveyScreen({super.key});

  @override
  State<NormalTrainingParticipantSurveyScreen> createState() =>
      _NormalTrainingParticipantSurveyScreenState();
}

class _NormalTrainingParticipantSurveyScreenState
    extends State<NormalTrainingParticipantSurveyScreen> {
  final _controller = Get.find<NormalOlfactoryTrainingController>();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _birthYearController = TextEditingController();
  final _occupationController = TextEditingController();
  final Map<String, String> _responses = {};

  bool _isProfileStep = true;
  int _questionIndex = 0;

  String get _participantCode {
    final year = _birthYearController.text.trim();
    final name = _nameController.text.trim().replaceAll(RegExp(r'\s+'), '');
    if (year.isEmpty || name.isEmpty) return '';
    return '$year-$name';
  }

  List<NormalTrainingSurveyQuestion> get _activeQuestions {
    return normalTrainingSurveyQuestions
        .where(
          (question) =>
              question.key != 'occupation_detail' ||
              _responses['occupation_status'] == '있음',
        )
        .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _birthYearController.dispose();
    _occupationController.dispose();
    super.dispose();
  }

  void _startSurvey() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _isProfileStep = false;
    });
  }

  void _goBack() {
    if (_isProfileStep) {
      Navigator.pop(context);
      return;
    }

    if (_questionIndex == 0) {
      setState(() {
        _isProfileStep = true;
      });
      return;
    }

    setState(() {
      _questionIndex -= 1;
    });
  }

  void _goNext() {
    final questions = _activeQuestions;
    final question = questions[_questionIndex];
    final answer = _responses[question.key]?.trim();
    if (answer == null || answer.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            question.options.isEmpty ? '직업을 입력해주세요.' : '답변을 선택해주세요.',
          ),
        ),
      );
      return;
    }

    if (_questionIndex < questions.length - 1) {
      setState(() {
        _questionIndex += 1;
      });
      return;
    }

    _controller.setParticipant(
      participantCode: _participantCode,
      participantName: _nameController.text.trim(),
      birthYear: int.parse(_birthYearController.text.trim()),
      surveyResponses: Map<String, String>.from(_responses),
    );
    Get.off(() => const NormalOlfactoryTrainingScreen());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: CustomAppBar(
        mode: CustomAppBarMode.sub,
        title: _isProfileStep ? '참여자 등록' : '기본 설문',
        onBackPressed: _goBack,
      ),
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/blurred_background.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.5),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.06),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child:
                            _isProfileStep
                                ? _buildProfileStep(screenWidth)
                                : _buildSurveyStep(screenWidth),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStep(double screenWidth) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '참여자 정보를 입력해주세요.',
            style: TextStyle(
              fontSize: screenWidth * 0.07,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '출생연도와 이름을 조합하여 참여자 코드를 만듭니다.',
            style: TextStyle(fontSize: screenWidth * 0.045),
          ),
          const SizedBox(height: 28),
          _buildTextField(
            controller: _nameController,
            label: '이름',
            hint: '예: 홍길동',
            onChanged: (_) => setState(() {}),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '이름을 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: _birthYearController,
            label: '출생연도',
            hint: '예: 1960',
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (_) => setState(() {}),
            validator: (value) {
              final year = int.tryParse(value ?? '');
              final currentYear = DateTime.now().year;
              if (year == null || value?.length != 4) {
                return '출생연도 4자리를 입력해주세요.';
              }
              if (year < 1900 || year > currentYear) {
                return '올바른 출생연도를 입력해주세요.';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFB7C8B2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '참여자 코드',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _participantCode.isEmpty
                      ? '출생연도와 이름을 입력해주세요.'
                      : _participantCode,
                  style: TextStyle(
                    fontSize: screenWidth * 0.055,
                    color: const Color(0xFF335928),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          ButtonBasic(
            content: '기본 설문 시작',
            icon: const Icon(Icons.arrow_forward),
            fontSize: screenWidth * 0.05,
            function: _startSurvey,
          ),
        ],
      ),
    );
  }

  Widget _buildSurveyStep(double screenWidth) {
    final questions = _activeQuestions;
    final question = questions[_questionIndex];
    final selectedAnswer = _responses[question.key];
    final hasAnswer = selectedAnswer?.trim().isNotEmpty ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '${_questionIndex + 1} / ${questions.length}',
          style: TextStyle(
            fontSize: screenWidth * 0.045,
            color: const Color(0xFF335928),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: (_questionIndex + 1) / questions.length,
          minHeight: 8,
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF4F7F68),
          backgroundColor: Colors.white,
        ),
        const SizedBox(height: 36),
        Text(
          question.question,
          style: TextStyle(
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 32),
        if (question.options.isEmpty)
          _buildTextField(
            controller: _occupationController,
            label: '직업',
            hint: '예: 회사원, 자영업, 교사',
            onChanged: (value) {
              setState(() {
                _responses[question.key] = value.trim();
              });
            },
            validator: (_) => null,
          )
        else
          for (final option in question.options) ...[
            _buildOptionButton(
              option: option,
              isSelected: selectedAnswer == option,
              screenWidth: screenWidth,
              onPressed: () {
                setState(() {
                  _responses[question.key] = option;
                  if (question.key == 'occupation_status' && option == '없음') {
                    _responses.remove('occupation_detail');
                    _occupationController.clear();
                  }
                });
              },
            ),
            const SizedBox(height: 14),
          ],
        const Spacer(),
        ButtonBasic(
          content: _questionIndex == questions.length - 1 ? '훈련 시작하기' : '다음',
          icon: const Icon(Icons.arrow_forward),
          fontSize: screenWidth * 0.05,
          function: hasAnswer ? _goNext : null,
        ),
      ],
    );
  }

  Widget _buildOptionButton({
    required String option,
    required bool isSelected,
    required double screenWidth,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 68,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: isSelected ? 3 : 0,
          backgroundColor: isSelected ? const Color(0xFF4F7F68) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black87,
          side: BorderSide(
            color: isSelected ? const Color(0xFF4F7F68) : Colors.grey.shade300,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.check_circle : Icons.circle_outlined),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                option,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: screenWidth * 0.052,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      validator: validator,
      style: const TextStyle(fontSize: 20),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
      ),
    );
  }
}
