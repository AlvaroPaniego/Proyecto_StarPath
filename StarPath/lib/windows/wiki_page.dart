import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/planet.dart';

class WikiPage extends StatefulWidget {
  const WikiPage({Key? key}) : super(key: key);

  @override
  _AstronomyWikiPageState createState() => _AstronomyWikiPageState();
}

final Map<String, String> planetDescriptions = {
  'Mercurio':
      'Mercurio es el planeta más cercano al Sol y el más pequeño del sistema solar. Con un diámetro de aproximadamente 4,880 kilómetros y una masa que representa solo el 5.5% de la terrestre, es un planeta de extremos. Su densidad es alta debido a un núcleo metálico grande, lo que le da una gravedad que es aproximadamente el 38% de la de la Tierra.\n\n En cuanto a su órbita, Mercurio se encuentra a una distancia media de 57.9 millones de kilómetros del Sol. Completa una vuelta alrededor del Sol en solo 88 días terrestres, lo que significa que su año es muy corto comparado con el nuestro. Sin embargo, su rotación sobre su propio eje es lenta, tardando 59 días terrestres en completarse. Esta combinación de movimientos crea una situación donde un día solar (el tiempo que tarda en salir y ponerse el Sol en un punto específico del planeta) dura aproximadamente 176 días terrestres.\n Debido a su proximidad al Sol, Mercurio experimenta temperaturas extremas que pueden alcanzar hasta 430°C durante el día y descender a -180°C durante la noche. Su superficie está llena de cráteres y es similar a la de la Luna, mostrando un paisaje antiguo y poco alterado por la actividad geológica.\n\n Mercurio no tiene atmósfera significativa, solo una exosfera muy delgada compuesta principalmente de átomos liberados de su superficie por el viento solar y el impacto de micrometeoritos. Esta falta de atmósfera contribuye a las extremas variaciones de temperatura. Además, no tiene lunas ni anillos.\n\n A pesar de su proximidad al Sol, Mercurio ha sido visitado por algunas misiones espaciales, como Mariner 10 y la misión MESSENGER de la NASA, que han proporcionado mucha información sobre su composición, geología y ambiente.',
  'Venus':
      'Venus es el segundo planeta del sistema solar en orden de proximidad al Sol y es similar a la Tierra en tamaño y composición, lo que le vale el sobrenombre de "el gemelo de la Tierra". Sin embargo, las condiciones en su superficie son extremadamente diferentes y hostiles. Con un diámetro de aproximadamente 12,104 kilómetros y una masa que representa el 81.5% de la masa terrestre, Venus tiene una gravedad que es alrededor del 90% de la gravedad de la Tierra.\n\n En cuanto a su órbita, Venus se encuentra a una distancia media de 108.2 millones de kilómetros del Sol y completa una vuelta alrededor de él en unos 225 días terrestres. Su rotación es peculiar porque gira en sentido retrógrado, es decir, en dirección opuesta a la mayoría de los planetas, y tarda 243 días terrestres en completar una rotación sobre su eje, lo que significa que su día es más largo que su año.\n\n La atmósfera de Venus es densa y está compuesta principalmente de dióxido de carbono, con nubes espesas de ácido sulfúrico. Esta atmósfera produce un efecto invernadero extremo que eleva las temperaturas superficiales a unos 467°C, suficientes para derretir plomo. La presión atmosférica en la superficie es aproximadamente 92 veces la de la Tierra, similar a la presión que se encuentra a 900 metros bajo el agua en la Tierra.\n\n La superficie de Venus está marcada por vastas llanuras volcánicas y grandes complejos de volcanes. No tiene lunas ni anillos. Debido a las condiciones extremas, explorar Venus ha sido un desafío significativo. Las sondas espaciales que han visitado el planeta, como las soviéticas Venera y la estadounidense Magellan, han proporcionado mucha información sobre su composición y geología a pesar de las dificultades.',
  'Tierra':
      'La Tierra es el tercer planeta del sistema solar en orden de proximidad al Sol y el único conocido que alberga vida. Tiene un diámetro de aproximadamente 12,742 kilómetros y una masa que le confiere una gravedad que permite la existencia de una atmósfera estable y agua líquida en la superficie.\n\n La Tierra se encuentra a una distancia media de 149.6 millones de kilómetros del Sol, lo que se conoce como una unidad astronómica. Completa una vuelta alrededor del Sol en 365.25 días, lo que define un año terrestre. La rotación de la Tierra sobre su eje dura 24 horas, lo que determina la duración de un día.\n\n La atmósfera terrestre está compuesta principalmente de nitrógeno y oxígeno, con trazas de otros gases como el dióxido de carbono y el vapor de agua. Esta mezcla permite la respiración de una gran variedad de formas de vida y protege la superficie del planeta de la radiación solar dañina y de los meteoritos.\n\n La Tierra tiene una superficie variada que incluye océanos, continentes, montañas, desiertos y glaciares. Los océanos cubren aproximadamente el 71% de la superficie, lo que influye significativamente en el clima y las condiciones meteorológicas del planeta. Además, la Tierra posee un núcleo interno sólido, un núcleo externo líquido, un manto y una corteza, que interactúan en procesos geológicos como el movimiento de placas tectónicas. La Tierra tiene un único satélite natural, la Luna, que influye en las mareas y contribuye a estabilizar la inclinación axial del planeta, lo que a su vez afecta las estaciones. La biosfera de la Tierra es excepcionalmente diversa, con millones de especies de plantas, animales y microorganismos que interactúan en complejos ecosistemas.\n\n Gracias a su atmósfera, abundante agua y la energía solar, la Tierra ha desarrollado una biosfera rica y diversa, lo que la convierte en un planeta único en el sistema solar.',
  'Marte':
      'Marte es el cuarto planeta del sistema solar en orden de proximidad al Sol y es conocido como el "planeta rojo" debido a su distintivo color rojizo, causado por la oxidación del hierro en su superficie. Tiene un diámetro de aproximadamente 6,779 kilómetros, lo que lo hace cerca de la mitad del tamaño de la Tierra, y su masa es aproximadamente el 10.7% de la masa terrestre, con una gravedad que es alrededor del 38% de la gravedad de la Tierra.\n\n Marte se encuentra a una distancia media de unos 227.9 millones de kilómetros del Sol y completa una vuelta alrededor de él en aproximadamente 687 días terrestres, lo que define un año marciano. La rotación de Marte sobre su eje dura 24.6 horas, similar a la duración de un día en la Tierra.\n\n La atmósfera marciana es muy delgada y está compuesta principalmente de dióxido de carbono, con pequeñas cantidades de nitrógeno y argón. Debido a esta atmósfera tenue, las temperaturas en Marte pueden variar drásticamente, desde unos -125°C en las noches de invierno hasta unos 20°C en los días de verano en el ecuador. La atmósfera también contiene polvo fino que da lugar a tormentas de polvo que pueden cubrir el planeta entero.\n\n La superficie de Marte presenta una gran variedad de características geológicas, incluyendo el volcán más grande del sistema solar, Olympus Mons, y el cañón más profundo y extenso, Valles Marineris. Además, hay indicios de antiguos lechos de ríos, lagos y posibles océanos, lo que sugiere que Marte pudo haber tenido agua líquida en su pasado. Hoy en día, el agua se encuentra principalmente en forma de hielo en los casquetes polares y posiblemente en depósitos subterráneos.\n\n Marte tiene dos pequeñas lunas, Fobos y Deimos, que son probablemente asteroides capturados por la gravedad del planeta. Estas lunas son de forma irregular y tienen superficies llenas de cráteres.\n\n El interés en Marte ha llevado a numerosas misiones espaciales, tanto de orbitadores como de rovers, que han explorado su superficie y atmósfera. Misiones como las de los rovers Spirit, Opportunity, Curiosity y Perseverance han proporcionado valiosa información sobre la geología, clima y potencial habitabilidad del planeta, así como la búsqueda de signos de vida pasada o presente.\n\n Marte sigue siendo un foco principal para futuras misiones de exploración y potencial colonización debido a sus similitudes con la Tierra y la posibilidad de que haya albergado vida en el pasado.',
  'Júpiter':
      'Júpiter es el quinto planeta del sistema solar en orden de proximidad al Sol y es el más grande de todos los planetas. Tiene un diámetro de aproximadamente 139,820 kilómetros, lo que lo convierte en un gigante gaseoso, y su masa es 318 veces la de la Tierra, con una gravedad que es aproximadamente 2.5 veces la gravedad terrestre.\n\n Júpiter se encuentra a una distancia media de unos 778.5 millones de kilómetros del Sol y completa una vuelta alrededor de él en aproximadamente 11.86 años terrestres, lo que define un año joviano. La rotación de Júpiter sobre su eje es la más rápida de todos los planetas del sistema solar, durando solo 9.9 horas, lo que resulta en un día joviano muy corto.\n\n La atmósfera de Júpiter está compuesta principalmente de hidrógeno y helio, con trazas de otros gases como metano, amoníaco y vapor de agua. La atmósfera presenta bandas de nubes visibles y la Gran Mancha Roja, una tormenta gigantesca que ha estado activa durante al menos 400 años. Las tormentas y vientos en la atmósfera de Júpiter son extremadamente fuertes, alcanzando velocidades de hasta 600 kilómetros por hora.\n\n Júpiter tiene un sistema de anillos muy tenue y compuesto principalmente de partículas de polvo. Además, posee al menos 79 lunas, siendo las cuatro más grandes conocidas como las lunas galileanas: Ío, Europa, Ganímedes y Calisto. Cada una de estas lunas presenta características únicas, como los volcanes activos en Ío y el posible océano subterráneo en Europa.\n\n El interior de Júpiter no tiene una superficie sólida. Se cree que tiene un núcleo rocoso rodeado por una capa de hidrógeno metálico y una atmósfera profunda de hidrógeno y helio. La presión y la temperatura en el interior de Júpiter son extremadamente altas.\n\n Júpiter ha sido explorado por varias misiones espaciales, incluidas las sondas Pioneer, Voyager, Galileo y Juno, que han proporcionado una gran cantidad de información sobre su atmósfera, magnetosfera, sistema de anillos y lunas. La misión Juno, en particular, está actualmente en órbita alrededor de Júpiter y continúa enviando datos valiosos sobre el planeta.\n\n Júpiter sigue siendo un objeto de gran interés para la investigación astronómica debido a su enorme tamaño, complejidad atmosférica y la diversidad de sus lunas, que podrían ofrecer pistas sobre la formación del sistema solar y la posibilidad de vida en otros lugares.',
  'Saturno':
      'Saturno es el sexto planeta del sistema solar en orden de proximidad al Sol y es conocido por su impresionante sistema de anillos, que lo hace uno de los planetas más fácilmente reconocibles. Con un diámetro de aproximadamente 116,460 kilómetros, Saturno es el segundo planeta más grande del sistema solar después de Júpiter. Su masa es 95 veces la de la Tierra, aunque su densidad es tan baja que, si existiera un océano lo suficientemente grande, Saturno flotaría en él.\n\n Saturno se encuentra a una distancia media de unos 1,429 millones de kilómetros del Sol y completa una vuelta alrededor de él en aproximadamente 29.5 años terrestres, lo que define un año saturniano. La rotación de Saturno sobre su eje dura unas 10.7 horas, lo que resulta en un día saturniano muy corto.\n\n La atmósfera de Saturno está compuesta principalmente de hidrógeno y helio, con trazas de metano, amoníaco y otros gases. Las bandas de nubes visibles en su atmósfera y las tormentas ocasionales contribuyen a su apariencia distintiva. Una de las características más notables de Saturno es su sistema de anillos, compuesto principalmente de partículas de hielo y roca, que varían en tamaño desde pequeños granos hasta grandes fragmentos.\n\n Saturno tiene al menos 82 lunas confirmadas, siendo Titán la más grande y una de las más interesantes del sistema solar. Titán es más grande que el planeta Mercurio y tiene una atmósfera densa compuesta principalmente de nitrógeno. Otra luna notable es Encélado, que tiene géiseres que expulsan agua helada y sugerencias de un océano subterráneo, lo que lo convierte en un candidato potencial para la búsqueda de vida extraterrestre.\n\n El interior de Saturno no tiene una superficie sólida y se cree que tiene un núcleo rocoso rodeado por una capa de hidrógeno metálico y una atmósfera profunda de hidrógeno y helio. La presión y la temperatura en el interior de Saturno son extremadamente altas.\n\n Saturno ha sido explorado por varias misiones espaciales, incluidas las sondas Pioneer, Voyager y Cassini. La misión Cassini, en particular, orbitó Saturno durante 13 años y proporcionó una enorme cantidad de información sobre el planeta, sus anillos y sus lunas, especialmente sobre Titán y Encélado.\n\n Saturno sigue siendo un objeto de gran interés para la investigación astronómica debido a su sistema de anillos único, la diversidad de sus lunas y las pistas que puede ofrecer sobre la formación y evolución del sistema solar.',
  'Urano':
      'Urano es el séptimo planeta del sistema solar en orden de proximidad al Sol y es conocido por su tono azul verdoso, resultado de la presencia de metano en su atmósfera. Con un diámetro de aproximadamente 50,724 kilómetros, Urano es el tercer planeta más grande del sistema solar. Su masa es alrededor de 14.5 veces la de la Tierra, y su gravedad es ligeramente mayor que la terrestre.\n\n Urano se encuentra a una distancia media de unos 2,871 millones de kilómetros del Sol y completa una vuelta alrededor de él en aproximadamente 84 años terrestres, lo que define un año uraniano. La rotación de Urano es única porque gira de lado, con un eje de rotación inclinado casi 98 grados respecto a su órbita. Esto resulta en estaciones extremas y días y noches que duran aproximadamente 17.25 horas.\n\n La atmósfera de Urano está compuesta principalmente de hidrógeno y helio, con una cantidad significativa de metano que absorbe la luz roja y refleja la luz azul y verde, dándole su característico color. Las capas superiores de la atmósfera de Urano son frías, con temperaturas que descienden hasta -224°C, lo que lo convierte en el planeta más frío del sistema solar.\n\n Urano tiene un sistema de anillos tenues y oscuros, compuestos principalmente de partículas de hielo y polvo. Estos anillos son menos prominentes que los de Saturno pero aún son un rasgo distintivo del planeta. Urano también cuenta con 27 lunas conocidas, con nombres tomados de personajes de las obras de William Shakespeare y Alexander Pope. Las lunas más grandes son Titania, Oberón, Umbriel, Ariel y Miranda, cada una con características geológicas únicas.\n\n El interior de Urano no tiene una superficie sólida y se cree que está compuesto de un núcleo rocoso rodeado por un manto de agua, amoníaco y otros hielos, cubierto por una atmósfera de hidrógeno y helio. La estructura interna y la composición química de Urano son temas de interés científico continuo.\n\n Urano ha sido explorado por una única misión espacial, la sonda Voyager 2, que pasó cerca del planeta en 1986 y proporcionó gran parte de la información que conocemos hoy. Sin embargo, hay planes y propuestas para futuras misiones que podrían proporcionar más datos sobre este planeta enigmático.\n\n Urano sigue siendo un objeto de gran interés para la astronomía debido a sus características únicas, como su rotación inclinada, su sistema de anillos y la diversidad de sus lunas, que ofrecen pistas importantes sobre la formación y evolución de los planetas gigantes en el sistema solar.',
  'Neptuno':
      'Neptuno es el octavo y último planeta del sistema solar en orden de proximidad al Sol. Con un diámetro de aproximadamente 49,244 kilómetros, Neptuno es el cuarto planeta más grande del sistema solar. Tiene una masa aproximadamente 17 veces mayor que la de la Tierra, y su gravedad es un poco más fuerte que la terrestre.\n\n Neptuno se encuentra a una distancia media de unos 4,497 millones de kilómetros del Sol y completa una vuelta alrededor de él en aproximadamente 165 años terrestres, lo que define un año neptuniano. La rotación de Neptuno sobre su eje es rápida, durando unas 16.1 horas, lo que resulta en un día neptuniano relativamente corto.\n\n La atmósfera de Neptuno está compuesta principalmente de hidrógeno, helio y metano, lo que le confiere un color azul característico. Las nubes de metano en la atmósfera superior reflejan la luz solar y contribuyen a su apariencia distintiva. Neptuno es conocido por tener vientos extremadamente rápidos, con velocidades que pueden superar los 2,000 kilómetros por hora.\n\n Neptuno tiene un sistema de anillos tenue y oscuro, similar al de Urano, compuesto principalmente de partículas de hielo y polvo. Además, tiene al menos 14 lunas conocidas, siendo Tritón la más grande y notable. Tritón es único porque orbita en sentido contrario a la rotación del planeta y tiene una superficie geológicamente activa, con géiseres de nitrógeno y actividad criovolcánica.\n\n El interior de Neptuno se cree que está compuesto por un núcleo rocoso rodeado por un manto de agua, amoníaco y metano, cubierto por una atmósfera de hidrógeno, helio y metano. La estructura interna y la composición química de Neptuno son áreas de interés para la investigación científica.\n\n Neptuno fue visitado por una única misión espacial, la sonda Voyager 2, en 1989, que proporcionó una gran cantidad de información sobre el planeta y sus lunas. A pesar de esta única visita, hay propuestas para futuras misiones que podrían proporcionar más datos sobre este mundo distante y misterioso.\n\n Neptuno sigue siendo un objeto de gran interés para la astronomía debido a su lejanía, su atmósfera dinámica, su sistema de anillos y sus lunas únicas, que pueden proporcionar información importante sobre la formación y evolución de los planetas gigantes en el sistema solar.',
  'Plutón':
      'Plutón es un planeta enano y objeto transneptuniano ubicado en el cinturón de Kuiper, en los confines exteriores del sistema solar. Descubierto en 1930, Plutón fue considerado durante mucho tiempo el noveno planeta del sistema solar, pero en 2006 fue reclasificado como un planeta enano debido a su pequeño tamaño y su órbita excéntrica.\n\n Con un diámetro de aproximadamente 2,376 kilómetros, Plutón es mucho más pequeño que los planetas tradicionales. Su masa es aproximadamente 0.002 veces la de la Tierra, y su gravedad es muy baja. Plutón se encuentra a una distancia promedio de unos 5,900 millones de kilómetros del Sol y completa una vuelta alrededor de él en aproximadamente 248 años terrestres.\n\n La atmósfera de Plutón está compuesta principalmente de nitrógeno, con trazas de metano y monóxido de carbono. Durante gran parte de su órbita, Plutón está tan lejos del Sol que su atmósfera se congela y cae sobre su superficie en forma de hielo. Cuando está más cerca del Sol, el hielo se sublima y forma una atmósfera delgada.\n\n Plutón tiene al menos cinco lunas conocidas, siendo la más grande y conocida Caronte. Caronte es tan grande en comparación con Plutón que ambos cuerpos orbitan alrededor de un punto en el espacio que está fuera de la superficie de cada uno, en lugar de que Caronte orbitara directamente alrededor de Plutón.\n\n El interior de Plutón está compuesto por un núcleo rocoso rodeado por una capa de hielo de agua y amoníaco, cubierto por una atmósfera delgada de gases congelados. La estructura interna y la composición química de Plutón son áreas de interés para la investigación científica, y la sonda New Horizons de la NASA proporcionó datos valiosos sobre el planeta enano durante su sobrevuelo en 2015.\n\n Plutón sigue siendo un objeto de gran interés para la astronomía debido a su singularidad, su papel en la comprensión de la formación y evolución del sistema solar y su potencial para albergar misterios aún por descubrir.'
};

class _AstronomyWikiPageState extends State<WikiPage> {
  final List<Planet> _planets = [
    Planet(
      name: 'Mercurio',
      image: 'assets/images/Mercurio.png',
      description: planetDescriptions['Mercurio'] ?? '',
    ),
    Planet(
      name: 'Venus',
      image: 'assets/images/Venus.png',
      description: planetDescriptions['Venus'] ?? '',
    ),
    Planet(
      name: 'Tierra',
      image: 'assets/images/Tierra.png',
      description: planetDescriptions['Tierra'] ?? '',
    ),
    Planet(
      name: 'Marte',
      image: 'assets/images/Marte.png',
      description: planetDescriptions['Marte'] ?? '',
    ),
    Planet(
      name: 'Júpiter',
      image: 'assets/images/Júpiter.png',
      description: planetDescriptions['Júpiter'] ?? '',
    ),
    Planet(
      name: 'Saturno',
      image: 'assets/images/Saturno.png',
      description: planetDescriptions['Saturno'] ?? '',
    ),
    Planet(
      name: 'Urano',
      image: 'assets/images/Urano.png',
      description: planetDescriptions['Urano'] ?? '',
    ),
    Planet(
      name: 'Neptuno',
      image: 'assets/images/Neptuno.png',
      description: planetDescriptions['Neptuno'] ?? '',
    ),
    Planet(
      name: 'Plutón',
      image: 'assets/images/Plutón.png',
      description: planetDescriptions['Plutón'] ?? '',
    ),
  ];

  String searchText = '';
  String selectedPlanet = '';
  bool showList = true;

  @override
  Widget build(BuildContext context) {
    List<Planet> filteredPlanets = _planets
        .where((planet) =>
            planet.name.toLowerCase().startsWith(searchText.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: BACKGROUND,
      appBar: AppBar(
        backgroundColor: BUTTON_BAR_BACKGROUND,
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: Text(
          'Consultas astronómicas',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: KeyboardVisibilityBuilder(builder: (context, isKeyboardVisible) {
        return SingleChildScrollView(
          child: Column(
            children: [
              SafeArea(
                child: SizedBox(
                  height: MediaQuery.of(context).viewPadding.top,
                ),
              ),
              TextField(
                style: TextStyle(color: TEXT),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                    showList = true;
                    selectedPlanet = '';
                  });
                },
                decoration: const InputDecoration(
                  hintText: 'Escribe el nombre del planeta...',
                  hintStyle: TextStyle(color: TEXT),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              if (searchText.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Busca información de un planeta del Sistema Solar',
                      style: TextStyle(color: TEXT, fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              if (showList && searchText.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredPlanets.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(filteredPlanets[index].name,
                          style: TextStyle(color: TEXT)),
                      leading: Image.asset(
                        filteredPlanets[index].image,
                        height: 40,
                        width: 40,
                      ),
                      onTap: () {
                        setState(() {
                          selectedPlanet = filteredPlanets[index].name;
                          showList = false;
                        });
                      },
                    );
                  },
                ),
              if (selectedPlanet.isNotEmpty && !isKeyboardVisible) ...[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Text(
                          selectedPlanet,
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: TEXT),
                        ),
                        Image.asset(
                          _planets
                              .firstWhere(
                                  (planet) => planet.name == selectedPlanet)
                              .image,
                          height: 200,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _planets
                                .firstWhere(
                                    (planet) => planet.name == selectedPlanet)
                                .description,
                            style: const TextStyle(fontSize: 16, color: TEXT),
                            textAlign: TextAlign.justify,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            ],
          ),
        );
      }),
    );
  }
}
