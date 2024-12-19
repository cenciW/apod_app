import 'dart:async';
import 'package:apod_app/widgets/custom_app_bar.dart';
import 'package:apod_app/widgets/background.dart';
import 'package:apod_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../model/apod.dart';
import '../service/api_service.dart'; // Para formatar as datas

class GetImageDay extends StatefulWidget {
  const GetImageDay({super.key});

  @override
  GetImageDayState createState() => GetImageDayState();
}

class GetImageDayState extends State<GetImageDay> {
  final ApiService apiService = GetIt.I<ApiService>();
  DateTime? today = DateTime.now();
  Apod? image;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _fetchImages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final formattedDate = DateFormat('yyyy-MM-dd').format(today!);
      final jsonData = await apiService.fetchImageByDate(formattedDate);

      setState(() {
        // Converte o JSON para o objeto Apod
        image = Apod.fromJson(jsonData);
      });
    } catch (e) {
      setState(() {
        errorMessage = '$e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Imagem do dia'),
      body: Background(
        imagePath: 'android/icons/image.png',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                  child: CustomElevatedButton(
                    text: 'Buscar imagem do dia',
                    onPressed: _fetchImages,
                  )),
              if (isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 20),
                if (errorMessage!.isNotEmpty)
                  Card(
                    color: Colors.redAccent,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        errorMessage ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
              if (image != null) ...[
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: const BorderSide(color: Colors.blue, width: 0.9),
                      ),
                      elevation: 10,
                      shadowColor: Color(Colors.blue.value),
                      margin: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15.0),
                        child: Column(
                          children: [
                            if (image!.url.isNotEmpty)
                              Image.network(
                                image!.url,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                image!.title.isNotEmpty
                                    ? image!.title
                                    : 'No title',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                image!.explanation.isNotEmpty
                                    ? image!.explanation
                                    : 'Sem descrição',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
                child: CustomElevatedButton(
                  text: "Voltar",
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
