import 'dart:async';
import 'dart:convert';

import 'package:apod_app/widgets/custom_app_bar.dart';
import 'package:apod_app/widgets/background.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

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
      final response = await http
          .get(Uri.parse(
              '${Apod.baseUrl}/image/${today!.year}-${today!.month}-${today!.day}'))
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw TimeoutException('Tempo de conexão expirado.');
        },
      );
      ;

      if (response.statusCode == 200) {
        setState(() {
          image =
              Apod.fromJson(jsonDecode(response.body)); // Usando APOD.fromJson
        });
      } else {
        if (response.statusCode == 404) {
          setState(() {
            errorMessage = 'Imagem não encontrada para a data de hoje.';
          });
        } else {
          setState(() {
            errorMessage = 'Erro ao buscar imagens: ${response.statusCode}';
          });
        }
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Erro ao buscar imagens: $e';
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _fetchImages,
                  child: const Text(
                    'Obter imagem do dia',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(height: 20),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ],
              if (errorMessage != null) ...[
                const SizedBox(height: 20),
                Text('Erro: $errorMessage',
                    style: const TextStyle(color: Colors.red)),
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
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Voltar',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20.0,
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
