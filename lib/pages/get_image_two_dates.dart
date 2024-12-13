import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import '../model/apod.dart';
import '../service/api_service.dart';

class GetImageTwoDates extends StatefulWidget {
  const GetImageTwoDates({Key? key}) : super(key: key);
  @override
  _GetImageTwoDatesState createState() => _GetImageTwoDatesState();
}

class _GetImageTwoDatesState extends State<GetImageTwoDates> {
  final ApiService apiService = GetIt.I<ApiService>();
  DateTime? startDate;
  DateTime? endDate;
  List<Apod>? images;
  bool isLoading = false;
  String? errorMessage;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        startDate = picked.start;
        endDate = picked.end;
        images = null;
        errorMessage = null;
      });
      _fetchImages();
    }
  }

  Future<void> _fetchImages() async {
    if (startDate == null || endDate == null) {
      setState(() {
        errorMessage = 'Selecione um intervalo de datas válido.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      images = null;
      errorMessage = null;
    });

    final String start = DateFormat('yyyy-MM-dd').format(startDate!);
    final String end = DateFormat('yyyy-MM-dd').format(endDate!);

    final String url = "http://10.0.2.2:5000/api/APOD/images/$start/$end";

    try {
      final http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final String responseBody = response.body;

        if (responseBody.isNotEmpty && responseBody != "null") {
          try {
            final List data = json.decode(responseBody);
            setState(() {
              images = data.map((e) => Apod.fromJson(e)).toList();
            });
          } catch (e) {
            setState(() {
              errorMessage = 'Erro ao processar dados da API: $e';
            });
          }
        } else {
          setState(() {
            errorMessage = 'Resposta vazia ou inválida da API.';
          });
        }
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
            const Text('Imagens entre datas'),
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
              onPressed: _pickDateRange,
              child: const Text('Escolher intervalo de datas'),
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
            if (images != null && images!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: images!.length,
                  itemBuilder: (context, index) {
                    final image = images![index];
                    return Card(
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
                            if (image.url.isNotEmpty &&
                                Uri.tryParse(image.url)?.hasAbsolutePath ==
                                    true)
                              Image.network(
                                image.url,
                                height: 200,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Text('Erro ao carregar imagem');
                                },
                              ),
                            if (image.url.isEmpty ||
                                Uri.tryParse(image.url)?.hasAbsolutePath !=
                                    true)
                              const Text('Imagem inválida ou não disponível'),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                image.title.isNotEmpty
                                    ? image.title
                                    : 'Sem título',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                image.explanation.isNotEmpty
                                    ? image.explanation
                                    : 'Sem descrição',
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
