import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FlightInfoWidget extends StatefulWidget {
  final int flightId;

  FlightInfoWidget({required this.flightId});

  @override
  _FlightInfoWidgetState createState() => _FlightInfoWidgetState();
}

class _FlightInfoWidgetState extends State<FlightInfoWidget> {
  Map<String, dynamic>? flightData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFlightInfo();
  }

  Future<void> fetchFlightInfo() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/flights/${widget.flightId}'));

    if (response.statusCode == 200) {
      setState(() {
        flightData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load flight data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : flightData != null
          ? FlightDetails(flightData!)
          : Text('Failed to load flight data'),
    );
  }
}

class FlightDetails extends StatelessWidget {
  final Map<String, dynamic> flightData;

  FlightDetails(this.flightData);

  @override
  Widget build(BuildContext context) {
    return Card(
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
              'Détails du vol',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB44D11)),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFFB44D11)),
                SizedBox(width: 5),
                Text(
                  'Prix: \$${flightData['price']}',
                  style: TextStyle(color: Color(0xFFB44D11)),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.flight_takeoff, color: Color(0xFFB44D11)),
                SizedBox(width: 5),
                Text(
                  'Aéroport de départ: ${flightData['airportStart']}',
                  style: TextStyle(color: Color(0xFFB44D11)),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.flight_land, color: Color(0xFFB44D11)),
                SizedBox(width: 5),
                Text(
                  'Aéroport d\'arrivée: ${flightData['airportEnd']}',
                  style: TextStyle(color: Color(0xFFB44D11)),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.airplanemode_active, color: Color(0xFFB44D11)),
                SizedBox(width: 5),
                Text(
                  'Compagnie aérienne: ${flightData['company']}',
                  style: TextStyle(color: Color(0xFFB44D11)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
