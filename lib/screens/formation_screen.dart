import 'package:flutter/material.dart';

class FormationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("포메이션 관리")),
      body: Center(
        child: Stack(
          children: [
            Image.asset('assets/football_field.png', fit: BoxFit.cover),
            Positioned(top: 50, left: 100, child: _buildPlayer("GK")),
            Positioned(top: 150, left: 50, child: _buildPlayer("DF1")),
            Positioned(top: 150, right: 50, child: _buildPlayer("DF2")),
            Positioned(top: 250, left: 100, child: _buildPlayer("MF1")),
            Positioned(top: 250, right: 100, child: _buildPlayer("MF2")),
            Positioned(top: 350, left: 150, child: _buildPlayer("FW")),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayer(String name) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
      child: Text(name, style: TextStyle(color: Colors.white)),
    );
  }
}
