import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'activity_info_widget.dart';  // Import the ActivityInfoWidget

class ProgramPage extends StatefulWidget {
  final int themeIndex;

  ProgramPage({required this.themeIndex});

  @override
  _ProgramPageState createState() => _ProgramPageState();
}

class _ProgramPageState extends State<ProgramPage> {
  late Future<Map<String, dynamic>> programFuture;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    programFuture = fetchPrograms();
  }

  Future<Map<String, dynamic>> fetchPrograms() async {
    int programId;
    switch (widget.themeIndex) {
      case 1:
        programId = 8;
        break;
      case 2:
        programId = 9;
        break;
      case 3:
        programId = 10;
        break;
      case 4:
        programId = 5;
        break;
      case 5:
        programId = 6;
        break;
      case 6:
        programId = 7;
        break;
      default:
        throw Exception('Invalid theme index');
    }

    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/contextprogram/$programId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load programs');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Détails du Programme',
          style: TextStyle(color: Colors.white), // Text color white
        ),
        backgroundColor: Color(0xFFB44D11),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(15.0), // Rounded bottom borders
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: programFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur de chargement des détails du programme'));
          } else {
            final program = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0), // Rounded borders
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 5,
                        blurRadius: 7,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFB44D11), // Background color for the top row
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(15.0),
                              topRight: Radius.circular(15.0),
                            ),
                          ),
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Text(
                                    program['place'],
                                    style: TextStyle(
                                      fontSize: 24, // Increase the font size
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white, // Text color white
                                    ),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.orange : Colors.white, // Icon color white
                                  size: 30,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isLiked = !isLiked;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.location_on, color: Color(0xFFB44D11)),
                            SizedBox(width: 10),
                            Text(program['place'], style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, color: Color(0xFFB44D11)),
                            SizedBox(width: 10),
                            Text(' ${program['dateStart']}', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, color: Color(0xFFB44D11)),
                            SizedBox(width: 10),
                            Text('${program['dateEnd']}', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.people, color: Color(0xFFB44D11)),
                            SizedBox(width: 10),
                            Text('${program['numberPerson']}', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.center_focus_strong, color: Color(0xFFB44D11)),
                            SizedBox(width: 10),
                            Text('${program['focus']}', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        Text(
                          'Activités:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (program.containsKey('activity'))
                          ...program['activity'].map<Widget>((activityId) {
                            return ActivityInfoWidget(activityId: activityId);
                          }).toList(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
