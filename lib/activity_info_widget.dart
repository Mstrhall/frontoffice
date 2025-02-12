import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ActivityInfoWidget extends StatefulWidget {
  final int activityId;

  ActivityInfoWidget({required this.activityId});

  @override
  _ActivityInfoWidgetState createState() => _ActivityInfoWidgetState();
}

class _ActivityInfoWidgetState extends State<ActivityInfoWidget> {
  Map<String, dynamic>? activityData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchActivityInfo();
  }

  Future<void> fetchActivityInfo() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/activities/${widget.activityId}'));

    if (response.statusCode == 200) {
      setState(() {
        activityData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load activity data');
    }
  }

  String formatDuration(String duration) {
    final DateTime dateTime = DateTime.parse(duration);
    final String formattedTime = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return formattedTime;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: isLoading
          ? CircularProgressIndicator()
          : activityData != null
          ? ActivityDetails(activityData!, formatDuration)
          : Text('Failed to load activity data'),
    );
  }
}

class ActivityDetails extends StatelessWidget {
  final Map<String, dynamic> activityData;
  final String Function(String) formatDuration;

  ActivityDetails(this.activityData, this.formatDuration);

  @override
  Widget build(BuildContext context) {
    return Card(
      surfaceTintColor: Colors.white, // Set the background color to white
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${activityData['name']}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB44D11)), // Keep the original color
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.location_on, color: Color(0xFFB44D11)), // Keep the original color
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Lieu: ${activityData['place']}',
                    style: TextStyle(color: Color(0xFFB44D11)), // Keep the original color
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFFB44D11)), // Keep the original color
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Prix: \$${activityData['price']}',
                    style: TextStyle(color: Color(0xFFB44D11)), // Keep the original color
                  ),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.access_time, color: Color(0xFFB44D11)), // Keep the original color
                SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Durée: ${formatDuration(activityData['duration'])}',
                    style: TextStyle(color: Color(0xFFB44D11)), // Keep the original color
                  ),
                ),
              ],
            ),
            // Ajoutez d'autres champs selon les données disponibles
          ],
        ),
      ),
    );
  }
}
