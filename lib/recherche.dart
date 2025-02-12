import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'account.dart';
import 'program_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFB44D11),
        scaffoldBackgroundColor: Color(0xFFB44D11),
      ),
      home: RecherchePage(),
    );
  }
}

class RecherchePage extends StatefulWidget {
  @override
  _RecherchePageState createState() => _RecherchePageState();
}

class _RecherchePageState extends State<RecherchePage> {
  int _selectedIndex = 0;
  int themeId = 0;
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _destinationendController = TextEditingController();
  final TextEditingController _dateStartController = TextEditingController();
  final TextEditingController _dateEndController = TextEditingController();
  final TextEditingController _peopleController = TextEditingController();

  bool _showFilters = false;

  List<dynamic> rentalResults = [];
  List<dynamic> activityResults = [];
  List<dynamic> flightResults = [];

  @override
  void dispose() {
    _scrollController.dispose();
    _destinationController.dispose();
    _destinationendController.dispose();
    _dateStartController.dispose();
    _dateEndController.dispose();
    _peopleController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RecherchePage()));
      return;
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _fetchRentalResults() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/rentals/filter'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'place': _destinationController.text,
        'date_start': _dateStartController.text.isEmpty ? null : _dateStartController.text,
        'date_end': _dateEndController.text.isEmpty ? null : _dateEndController.text,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        rentalResults = List<dynamic>.from(jsonDecode(response.body));
      });
    } else {
      setState(() {
        rentalResults = [];
      });
    }
  }

  Future<void> _fetchActivityResults() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/activities/filter'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'place': _destinationController.text,
        'period': '',  // You can add logic to set the period if needed
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        activityResults = List<dynamic>.from(jsonDecode(response.body));
      });
    } else {
      setState(() {
        activityResults = [];
      });
    }
  }

  Future<void> _fetchFlightResults() async {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/flights/filter'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'airport_start': _destinationController.text,
        'airport_end': _destinationendController.text, // Replace with your logic to get the start airport
        'date_start': _dateStartController.text.isEmpty ? null : _dateStartController.text,
        'date_end': _dateEndController.text.isEmpty ? null : _dateEndController.text,
      }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      setState(() {
        flightResults = jsonResponse is List
            ? List<dynamic>.from(jsonResponse)
            : jsonResponse['flights'] != null && jsonResponse['flights'] is List
            ? List<dynamic>.from(jsonResponse['flights'])
            : [];
      });
    } else {
      setState(() {
        flightResults = [];
      });
    }
  }

  void _onFieldChanged() {
    _fetchRentalResults();
    _fetchActivityResults();
    _fetchFlightResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          padding: EdgeInsets.only(top: 60.0),
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 60),
            painter: CustomShapePainter(),
          ),
        ),
        backgroundColor: Color(0xFFB44D11),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(_showFilters ? 300.0 : 70.0),
          child: Container(
            padding: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.0),
                topRight: Radius.circular(32.0),
                bottomRight: Radius.circular(32.0),
                bottomLeft: Radius.circular(32.0),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _destinationController,
                  onTap: () {
                    setState(() {
                      _showFilters = !_showFilters;
                    });
                  },
                  onChanged: (_) => _onFieldChanged(),
                  decoration: InputDecoration(
                    hintText: 'Quelle est votre destination ?',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
                if (_showFilters)
                  Column(
                    children: [
                      TextField(
                        controller: _destinationendController,
                        onChanged: (_) => _onFieldChanged(),
                        decoration: InputDecoration(
                          hintText: 'Ville de retour',
                          prefixIcon: Icon(Icons.location_city),
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: _dateStartController,
                        onChanged: (_) => _onFieldChanged(),
                        decoration: InputDecoration(
                          hintText: 'Date de départ',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: _dateEndController,
                        onChanged: (_) => _onFieldChanged(),
                        decoration: InputDecoration(
                          hintText: 'Date de retour',
                          prefixIcon: Icon(Icons.calendar_today),
                          border: InputBorder.none,
                        ),
                      ),
                      TextField(
                        controller: _peopleController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _onFieldChanged(),
                        decoration: InputDecoration(
                          hintText: 'Nombre de personnes',
                          prefixIcon: Icon(Icons.people),
                          border: InputBorder.none,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            Image.asset(
              'assets/mascote.png',
              width: 200,
              height: 200,
            ),
            Spacer(),
            Spacer(),
          ],
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                CustomPaint(
                  size: Size(MediaQuery.of(context).size.width, MediaQuery.of(context).size.height * 0.55),
                  painter: CustomShapePainter(),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.04,
                  left: 16.0,
                  child: Text(
                    'Suggestion',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.0,
                    ),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.10,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 200,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: List.generate(6, (index) => _buildCategoryCard(index)),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Nos Programmes',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFB44D11),
                ),
              ),
            ),
            // Display results below the wave
            if (rentalResults.isNotEmpty || activityResults.isNotEmpty || flightResults.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  color: Color(0xFFFFF4E1), // Light ocre background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (rentalResults.isNotEmpty)
                          _buildResultsSection('Locations', rentalResults),
                        if (activityResults.isNotEmpty)
                          _buildResultsSection('Activités', activityResults),
                        if (flightResults.isNotEmpty)
                          _buildResultsSection('Vols', flightResults),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: BottomNavigationBar(
            items: <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Accueil',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.airplanemode_active),
                label: 'Voyage',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Compte',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Color(0xFFB44D11),
            onTap: (int index) {
              if (index == 2) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
                return;
              }
              if (index == 1) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProgramPage(themeIndex: 4)));
                return;
              }
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(String title, List<dynamic> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFB44D11)),
        ),
        ...results.map((result) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 4,
            child: Container(
              width: double.infinity, // Full width
              height: 150, // Fixed height
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (result.containsKey('name'))
                    Text(
                      result['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB44D11),
                      ),
                    ),
                  if (result.containsKey('place'))
                    Row(
                      children: [
                        Icon(Icons.place, color: Color(0xFFB44D11)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${result['place'] ?? ''}',
                            style: TextStyle(color: Color(0xFFB44D11)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (result.containsKey('price'))
                    Row(
                      children: [
                        Icon(Icons.attach_money, color: Color(0xFFB44D11)),
                        SizedBox(width: 8),
                        Text(' \$${result['price'] ?? ''}', style: TextStyle(color: Color(0xFFB44D11))),
                      ],
                    ),
                  if (result.containsKey('period'))
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Color(0xFFB44D11)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${result['period'] ?? ''}',
                            style: TextStyle(color: Color(0xFFB44D11)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (result.containsKey('airportStart'))
                    Row(
                      children: [
                        Icon(Icons.flight_takeoff, color: Color(0xFFB44D11)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${result['airportStart'] ?? ''} à ${result['airportEnd'] ?? ''}',
                            style: TextStyle(color: Color(0xFFB44D11)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (result.containsKey('dateStart'))
                    Row(
                      children: [
                        Icon(Icons.date_range, color: Color(0xFFB44D11)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${result['dateStart'] ?? ''}',
                            style: TextStyle(color: Color(0xFFB44D11)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (result.containsKey('dateEnd'))
                    Row(
                      children: [
                        Icon(Icons.date_range, color: Color(0xFFB44D11)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${result['dateEnd'] ?? ''}',
                            style: TextStyle(color: Color(0xFFB44D11)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildCategoryCard(int index) {
    String categoryText;
    int themeIndex;
    switch (index) {
      case 0:
        categoryText = 'Un weekend découverte ?';
        themeIndex = 1;
        break;
      case 1:
        categoryText = "Partir à l'aventure";
        themeIndex = 2;
        break;
      case 2:
        categoryText = 'Les pieds dans l\'eau';
        themeIndex = 6;
        break;
      case 3:
        categoryText = 'Un peu de culture';
        themeIndex = 3;
        break;
      case 4:
        categoryText = 'Entre terre et mer';
        themeIndex = 4;
        break;
      case 5:
        categoryText = 'On Grimpe ?';
        themeIndex = 5;
        break;
      default:
        categoryText = 'Catégorie $index';
        themeIndex = 0;

        break;
    }
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.0),
      width: 300,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProgramPage(themeIndex: themeIndex)
              ),
            );
          },
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.0),
                child: Image.asset(
                  'assets/$index.jpeg',
                  width: 300,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(8.0),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      children: [
                        Text(
                          categoryText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xFFB44D11);
    Path path = Path();

    path.moveTo(0, size.height * 0.75);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.6, size.width * 0.5, size.height * 0.65);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.7, size.width, size.height * 0.65);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
