import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login.dart';
import 'profile_page.dart'; // Assurez-vous d'importer la page de profil
import 'recherche.dart'; // Importer la page de recherche

class AccountPage extends StatelessWidget {
  Future<void> _navigateToProfile(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ProfilePage()),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('email');
    await prefs.remove('password');
    await prefs.remove('userId');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
          (Route<dynamic> route) => false,
    );
  }

  Future<String> _getUserName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('email') ?? 'Utilisateur';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mon compte'),
        centerTitle: true,
        backgroundColor: Color(0xFF307039), // Même couleur que la forme
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            color: Colors.white, // Couleur de l'icône de déconnexion
          ),
        ],
        titleTextStyle: TextStyle(
          color: Colors.white, // Couleur du texte de l'AppBar
          fontSize: 20.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.4,
            child: CustomPaint(
              painter: CloudShapePainter(),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FutureBuilder<String>(
                      future: _getUserName(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Erreur de chargement du nom', textAlign: TextAlign.center);
                        } else {
                          return Text(
                            snapshot.data ?? 'Utilisateur',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          );
                        }
                      },
                    ),
                    Image.asset(
                      'assets/mascotte_V2_1.gif',

                      width: 1000,// Ajustez la hauteur de l'image si nécessaire
                    ),
                    SizedBox(height: 10),

                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildGridButton(context, Icons.favorite, 'Mes likes', () {}),
                  _buildGridButton(context, Icons.home, 'Accueil', () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RecherchePage()));
                  }),
                  _buildGridButton(context, Icons.notifications, 'Notifications', () {}),
                  _buildGridButton(context, Icons.person, 'Profil', () {
                    _navigateToProfile(context);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridButton(BuildContext context, IconData icon, String label, Function onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 4),
            blurRadius: 6.0,
          ),
        ],
        border: Border.all(
          color: Colors.black12,
          width: 2.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20.0),
          onTap: () => onPressed(), // Assurez-vous d'utiliser une fonction anonyme pour appeler onPressed
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 40, color: Colors.black87),
                SizedBox(height: 8.0),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CloudShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..color = Color(0xFF307039);

    Path path = Path()
      ..moveTo(0, size.height * 0.7)
      ..quadraticBezierTo(size.width / 4, size.height * 0.9, size.width / 2, size.height * 0.8)
      ..quadraticBezierTo(size.width * 3 / 4, size.height * 0.7, size.width, size.height * 0.8)
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
