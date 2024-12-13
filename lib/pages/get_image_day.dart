import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
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
  String baseUrl = 'http://10.0.2.2:5000/api/APOD';

  Future<void> _fetchImages() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(Uri.parse(
          '$baseUrl/image/${today!.year}-${today!.month}-${today!.day}'));

      if (response.statusCode == 200) {
        setState(() {
          image =
              Apod.fromJson(jsonDecode(response.body)); // Usando APOD.fromJson
        });
      } else {
        setState(() {
          errorMessage = 'Erro ao buscar imagens: ${response.statusCode}';
        });
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
      appBar: AppBar(
        //green color
        backgroundColor: Colors.green,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'android/icons/icons8-nasa-96.png',
              height: 48,
            ),
            const SizedBox(width: 8),
            const Text('Imagem do dia'),
          ],
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: _fetchImages,
              child: const Text('Obter imagem do dia'),
            ),
            if (isLoading) ...[
              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
            if (errorMessage != null) ...[
              const SizedBox(height: 20),
              Text('Erro: $errorMessage',
                  style: const TextStyle(color: Colors.red)),
            ],
            if (image != null) ...[
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                  side: BorderSide(color: Colors.green, width: 0.9),
                ),
                elevation: 10,
                shadowColor: Color(Colors.green.value),
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
                          image!.title.isNotEmpty ? image!.title : 'No title',
                          style: const TextStyle(fontWeight: FontWeight.bold),
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
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Voltar'),
            ),
          ],
        ),
      ),
    );
  }
}