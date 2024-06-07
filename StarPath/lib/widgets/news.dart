import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:starpath/misc/constants.dart';

class News extends StatefulWidget {
  final String newsTitle;
  final String fecha;
  final String lorem;
  final String link;
  final String logo;
  const News({super.key, required this.newsTitle, required this.fecha, required this.lorem, required this.link, required this.logo});

  @override
  State<News> createState() => _NewsState();
}

class _NewsState extends State<News> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 8.0),
      child: ExpansionTile(
        backgroundColor: BUTTON_BAR_BACKGROUND,
        collapsedIconColor: TEXT,
        collapsedBackgroundColor: BUTTON_BACKGROUND,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Text(widget.newsTitle,
                style: const TextStyle(
                  color: TEXT,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Text(widget.fecha,
                style: const TextStyle(
                  color: TEXT,
                ),
              ),
            ),
          ],
        ),
        leading: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(45.0),
            child: Image.asset(widget.logo)
          ),
        ),
        children: [
          Text(widget.lorem,
            style: const TextStyle(
              color: TEXT,
            ),
          ),
          Image.asset(widget.logo),
          // RichText(
          //     text: TextSpan(
          //       text: "Ver más",
          //       recognizer: TapGestureRecognizer()..onTap = () async {
          //         final url = 'https://github.com/flutter/gallery/';
          //         if (await canLaunch(url)) {
          //           await launch(
          //             url,
          //             forceSafariVC: false,
          //           );
          //         }
          //       },
          //     )
          // )
          TextButton(
              onPressed: () {

              },
              child: const Text("Ver más",
              style: TextStyle(
                color: TEXT,
              )
            )
          ),
        ],
      ),
    );
  }
}
