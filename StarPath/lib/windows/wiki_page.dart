import 'package:flutter/material.dart';

class WikiPage extends StatefulWidget {
  const WikiPage({Key? key}) : super(key: key);

  @override
  _AstronomyWikiPageState createState() => _AstronomyWikiPageState();
}

class _AstronomyWikiPageState extends State<WikiPage> {
  final List<String> planetNames = [
    'Mercurio',
    'Venus',
    'Tierra',
    'Marte',
    'Jupiter',
    'Saturno',
    'Urano',
    'Neptuno',
    'Plutón'
  ];

  final Map<String, String> planetDescriptions = {
    'Mercurio':
        'Mercurio es el planeta más cercano al Sol y el más pequeño del Sistema Solar.',
    'Venus':
        'Venus es el segundo planeta desde el Sol y tiene una atmósfera densa y tóxica.',
    'Tierra':
        'La Tierra es nuestro hogar, el tercer planeta desde el Sol y el único conocido con vida.',
    'Marte':
        'Marte, el cuarto planeta desde el Sol, es conocido como el planeta rojo.',
    'Júpiter':
        'Júpiter es el planeta más grande del Sistema Solar y el quinto desde el Sol.',
    'Saturno':
        'Saturno es el sexto planeta desde el Sol y es famoso por sus impresionantes anillos.',
    'Urano':
        'Urano, el séptimo planeta desde el Sol, tiene una inclinación extrema y anillos finos.',
    'Neptuno':
        'Neptuno es el octavo planeta desde el Sol y tiene vientos extremadamente fuertes.',
    'Plutón':
        'Plutón, un planeta enano, fue el noveno planeta del Sistema Solar hasta su reclasificación.'
  };

  String searchText = '';
  String selectedPlanet = '';
  String texto = '';

  @override
  Widget build(BuildContext context) {
    List<String> filteredPlanets = planetNames
        .where((planet) =>
            planet.toLowerCase().startsWith(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Astronomy Wiki'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: InputDecoration(
                hintText:
                    'Busca información de un planeta del Sistema Solar...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            searchText.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Introduce las primeras letras de un planeta...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: filteredPlanets.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredPlanets[index]),
                        onTap: () {
                          setState(() {
                            selectedPlanet = filteredPlanets[index];
                            texto = planetDescriptions[selectedPlanet] ?? '';
                          });
                        },
                      );
                    },
                  ),
            if (selectedPlanet.isNotEmpty) ...[
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      selectedPlanet,
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Image.asset(
                      'assets/images/$selectedPlanet.png',
                      height: 150,
                      width: 150,
                    ),
                    SizedBox(height: 10),
                    Text(texto),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
