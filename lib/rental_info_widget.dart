import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RentalSearchPage extends StatefulWidget {
  @override
  _RentalSearchPageState createState() => _RentalSearchPageState();
}

class _RentalSearchPageState extends State<RentalSearchPage> {
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();

  void _searchRentals() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/rentals/filter'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'place': _placeController.text,
        'date_start': _dateStartController.text.isEmpty ? null : _dateStartController.text,
        'date_end': _dateEndController.text.isEmpty ? null : _dateEndController.text,
      }),
    );

    if (response.statusCode == 200) {
      List rentals = jsonDecode(response.body);
      // Handle the results here
      print('Rentals: $rentals');
    } else {
      print('Failed to load rentals');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recherche de Locations'),
        backgroundColor: Color(0xFFB44D11),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _placeController,
              decoration: InputDecoration(
                labelText: 'Lieu',
                hintText: 'Entrez le lieu',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dateStartController,
              decoration: InputDecoration(
                labelText: 'Date de départ',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _dateEndController,
              decoration: InputDecoration(
                labelText: 'Date d\'arrivée',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _searchRentals,
              child: Text('Rechercher'),
              style: ElevatedButton.styleFrom(
                primary: Color(0xFFB44D11),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RentalInfoWidget extends StatefulWidget {
  final int rentalId;

  RentalInfoWidget({required this.rentalId});

  @override
  _RentalInfoWidgetState createState() => _RentalInfoWidgetState();
}

class _RentalInfoWidgetState extends State<RentalInfoWidget> {
  Map<String, dynamic>? rentalData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRentalInfo();
  }

  Future<void> fetchRentalInfo() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:8000/api/rentals/${widget.rentalId}'));

    if (response.statusCode == 200) {
      setState(() {
        rentalData = json.decode(response.body);
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load rental data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: isLoading
          ? CircularProgressIndicator()
          : rentalData != null
          ? RentalDetails(rentalData!)
          : Text('Failed to load rental data'),
    );
  }
}

class RentalDetails extends StatelessWidget {
  final Map<String, dynamic> rentalData;

  RentalDetails(this.rentalData);

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
              'Détails de la location',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFB44D11)),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.place, color: Color(0xFFB44D11)),
                SizedBox(width: 5),
                Text(
                  'Lieu: ${rentalData['place']}',
                  style: TextStyle(color: Color(0xFFB44D11)),
                ),
              ],
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.attach_money, color: Color(0xFFB44D11)),
                SizedBox(width: 5),
                Text(
                  'Prix: \$${rentalData['price']}',
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
