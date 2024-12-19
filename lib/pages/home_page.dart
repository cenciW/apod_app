import 'package:apod_app/widgets/custom_app_bar.dart';
import 'package:apod_app/pages/get_image_amount.dart';
import 'package:apod_app/pages/get_image_day.dart';
import 'package:apod_app/pages/get_image_two_dates.dart';
import 'package:apod_app/widgets/background.dart';
import 'package:apod_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'NASA App'),
      body: Background(
        imagePath: 'android/icons/space_home.gif',
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    width: double.infinity,
                    child: CustomElevatedButton(
                      text: 'Buscar imagem do dia',
                      // backgroundColor: Colors.blue,
                      // textColor: Colors.black,
                      // fontSize: 20.0,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => GetImageDay()),
                        );
                      },
                    )),
                const SizedBox(height: 16.0), // Add space between buttons
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: 'Buscar imagens entre datas',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetImageTwoDates()),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16.0), // Add space between buttons
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    text: 'Buscar uma quantidade de imagens',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GetImageByAmount()),
                      );
                    },
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
