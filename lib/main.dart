import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'recherche.dart';
import 'login.dart'; // Assurez-vous d'importer la page de login
import 'profile_page.dart'; // Assurez-vous d'importer la page de profil
import 'account.dart'; // Assurez-vous d'importer la page d'accueil

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Assurez-vous que les plugins sont initialisés avant d'exécuter l'application
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  MyApp({required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Almy',
      theme: ThemeData(
        primaryColor: Color(0xFFB44D11),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Forme irrégulière (nuage)
          Positioned(
            bottom: 0,
            left: -100,
            child: Container(
              width: MediaQuery.of(context).size.width + 200,
              height: MediaQuery.of(context).size.height * 0.7,
              child: CustomPaint(
                painter: CloudShapePainter(),
              ),
            ),
          ),
          // Texte dans la partie ocre
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.35,
            left: 0,
            right: 0,
            child: Container(
              color: Color(0xFFB44D11),
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Bonjour! prêt à voyager ?',
                    style: TextStyle(fontSize: 30, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          // Bouton en bas à droite
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 20.0, bottom: 100.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecherchePage()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                ),
                child: Text(
                  "C'est parti !",
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFB44D11),
                    fontFamily: 'Arial',
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

class CloudShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xFFB44D11);

    double offsetY = size.height * -0.50;

    Path path = Path()
      ..moveTo(0, size.height * (2 / 3) + offsetY)
      ..quadraticBezierTo(size.width / 4, size.height * (2 / 3) - 100 + offsetY, size.width / 2, size.height * (2 / 3) - 50 + offsetY)
      ..quadraticBezierTo(size.width * 3 / 4, size.height * (2 / 3) + offsetY, size.width, size.height * (2 / 3) - 150 + offsetY)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
