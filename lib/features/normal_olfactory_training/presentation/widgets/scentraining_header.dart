import 'package:flutter/material.dart';

class ScenTrainingHeader extends StatelessWidget {
  final String trainingTitle;

  const ScenTrainingHeader({super.key, required this.trainingTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(color: Color(0xFF72B357)),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: -100,
            left: -40,
            child: Container(
              width: 300,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          Positioned(
            top: -30,
            right: -100,
            child: Container(
              width: 300,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(10),
                borderRadius: BorderRadius.circular(150),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 20,
            child: Text(
              '향기 후각 훈련 서비스',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 30,
            left: 20,
            child: Text(
              'SCENTRAINING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            top: 75,
            child: Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  color: Color(0xFFE3E3E3).withAlpha(150),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  trainingTitle,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
