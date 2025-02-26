import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget{
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text("축구 좀 하자고"),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text("팀 이름", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              children: [
                _buildFeatureButton(context, Icons.people, "팀 관리", '/team_management'),
                _buildFeatureButton(context, Icons.sports_soccer, "포메이션", '/formation'),
                _buildFeatureButton(context, Icons.event, "경기 일정", '/schedule'),
                _buildFeatureButton(context, Icons.bar_chart, "선수 통계", '/stats'),
              ],
            ),
          )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "홈"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "팀 관리"),
          BottomNavigationBarItem(icon: Icon(Icons.sports_soccer), label: "포메이션"),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: "일정"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "설정"),
        ],
        onTap: (index) {
          switch (index) {
            case 1:
              Navigator.pushNamed(context, '/team_management');
              break;
            case 2:
              Navigator.pushNamed(context, '/formation');
              break;
            case 3:
              Navigator.pushNamed(context, '/schedule');
              break;
            case 4:
              Navigator.pushNamed(context, '/settings');
              break;
          }
        }
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context, IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.green),
            SizedBox(height: 10),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}