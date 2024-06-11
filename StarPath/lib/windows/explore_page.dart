import 'dart:math';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:starpath/misc/constants.dart';
import 'package:starpath/model/user.dart';
import 'package:starpath/model/user_data.dart';
import 'package:starpath/widgets/back_arrow.dart';
import 'package:starpath/widgets/news.dart';
import 'package:starpath/widgets/upper_app_bar.dart';
import 'package:starpath/widgets/user_info_carousel.dart';
import 'package:starpath/windows/main_page.dart';
import 'package:supabase/supabase.dart';
class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Future<List<UserData>> futureUser = Future.value([]);
  @override
  Widget build(BuildContext context) {
    User user = context.watch<UserProvider>().user!;
    futureUser = getRandomUsers(user.id);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: BACKGROUND,
        body: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).viewPadding.top,
            ),
            UpperAppBar(content: [
              BackArrow(route: MaterialPageRoute(builder: (context) => const MainPage(),)),
              const Text('Explorar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
              const SizedBox(width: 50,)
            ]),
            Expanded(
              flex: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: FutureBuilder(
                    future: futureUser,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return CarouselSlider(
                            items: userInfo(snapshot.data!),
                            options: CarouselOptions(
                                animateToClosest: true,
                                disableCenter: true,
                            )
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
            ),
            //Habra que cambiar el ListView por un ListView.builder para que las publicaciones se añadan dinamicamente
            Expanded(
                flex: 7,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(
                      children: const [
                        News(
                          fecha: '6/6/24',
                          logo: 'assets/images/elpais.png',
                          link: 'https://elpais.com/ciencia/2024-06-06/cuarto-lanzamiento-de-la-starship-de-elon-musk.html',
                          lorem: 'Por primera vez, SpaceX ha cumplido todos los objetivos que se había planteado para un vuelo de prueba de su Starship. Aunque los tres ensayos anteriores la compañía aeroespacial de Elon Musk ya los había calificado de éxitos, pues el cohete siempre había despegado y se recopilaron valiosos datos de vuelo, todas esas misiones habían acabado con el propulsor y la nave explotando. Esta vez, ambos elementos de la gigantesca lanzadera espacial cumplieron con la trayectoria prevista y acabaron amerizando en el océano, aunque con ciertos problemas. Estos logros de hoy son avances cruciales en el desarrollo de Starship, que está destinada a convertirse en la nave en la que la primera mujer aterrice en la Luna. El éxito de hoy acerca a la NASA y a SpaceX a lograr ese sueño en los próximos años.',
                          newsTitle: 'El megacohete ‘Starship’ completa por primera vez un vuelo sin explotar',
                          imageNew: 'assets/images/starship.png',
                        ),
                        News(
                          newsTitle: 'La NASA cambiará cómo apunta el telescopio espacial Hubble',
                          lorem: 'La NASA está trabajando para hacer que el veterano telescopio espacial Hubble funcione con un solo giroscopio, tras completar una serie de pruebas y considerar cuidadosamente las opciones. El telescopio ha interrumpido sus operaciones cientìficas tras entrar en modo seguro el 24 de mayo, debido a nuevos problemas de orientación.',
                          link: 'https://www.europapress.es/ciencia/misiones-espaciales/noticia-nasa-cambiara-apunta-telescopio-espacial-hubble-20240605113850.html',
                          logo: 'assets/images/ep.png',
                          fecha: '5/6/24',
                          imageNew: 'assets/images/hubble.png',
                        ),
                        News(
                          fecha: '4/6/24',
                          logo: 'assets/images/cnn.png',
                          link: 'https://cnnespanol.cnn.com/video/china-publica-las-primeras-imagenes-de-la-cara-oculta-de-la-luna/',
                          lorem: 'Estas imágenes nos revelan nuevos y fascinantes secretos de una cara oculta de la Luna, pero cada vez menos oculta a nuestra curiosidad. La Administración Nacional del espacio de China publicó este martes cuatro instantáneas del lado menos conocido de nuestro satélite natural captadas por la sonda Chang\'e-6. Tres imágenes fueron tomadas por el robot durante su aterrizaje y la cuarta es una vista panorámica de ese lugar.',
                          newsTitle: 'China publica las primeras imágenes de la cara oculta de la Luna',
                          imageNew: 'assets/images/luna_china.png',
                        )
                      ],
                ))),
          ],
        )
    );
  }

  List<Widget> userInfo(List<UserData> info) {
    List<Widget> userInfo = [];
    for (var user in info) {
      userInfo.add(UserInfoCarousel(user: user));
    }
    return userInfo;
  }

}
Future<List<UserData>> getRandomUsers(String idUser) async{
  List<UserData> userList = [];
  Random r = Random();
  int maxUsers = 6;
  // var query = 'select distinct public.user.username from followers, public.user'
  //     ' where  public.user.id_user not in (select followers.id_user_secundario from'
  //     ' followers where followers.id_user_principal = \'$idUser\')';
  var res = await supabase.rpc('getunfollowedusers', params: {'idloggeduser' : idUser});
  // var res = await supabase
  //     .from("user")
  //     .select("*");
  print(res.length);
  for (int i = 0; i < maxUsers; i++) {
    int randomUser = r.nextInt(res.length);
    userList.add(UserData(res[randomUser]['id_user'], res[randomUser]['username'], res[randomUser]['profile_picture'], '0', res[randomUser]['privacy']));
    res.removeAt(randomUser);
  }
  return userList;
}
