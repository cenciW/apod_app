import 'dart:convert';

import 'package:apod_app/model/apod.dart';
import 'package:apod_app/pages/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import '../service/api_service.dart';

class GetImageByAmount extends StatefulWidget {
  const GetImageByAmount({super.key});
  @override
  _GetImageByAmountState createState() => _GetImageByAmountState();
}

class _GetImageByAmountState extends State<GetImageByAmount> {
  final ApiService apiService = GetIt.I<ApiService>();
  List<Apod>? images;
  bool isLoading = false;
  String? errorMessage;
  int amount = 0;

  Future<void> _pickAmount() async {
    final TextEditingController controller = TextEditingController();

    final picked = await showDialog<int>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('Escolha a quantidade de imagens (máximo 30)'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Digite a quantidade de imagens',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Fecha sem retornar valor
                  },
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20.0,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    final int? picked = int.tryParse(controller.text);
                    if (picked != null && picked <= 30) {
                      Navigator.pop(context, picked); // Retorna o valor
                    } else {
                      // Mostrar mensagem de erro ou validação
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Digite um número válido (1-30)!')),
                      );
                    }
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (picked != null) {
      // Use a quantidade selecionada (picked)
      setState(() {
        amount = picked;
      });
      _fetchImages();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma quantidade selecionada')),
      );
    }
  }

  Future<void> _fetchImages() async {
    if (amount <= 0) {
      setState(() {
        errorMessage = 'Selecione uma quantidade válida de imagens.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      images = null;
      errorMessage = null;
    });

    final String url = "$Apod.baseUrl" "/random/$amount";

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
      appBar: const CustomAppBar(title: 'Imagens por quantidade'),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('android/icons/space_count.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: _pickAmount,
                child: const Text(
                  'Escolha a quantidade de imagens',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
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
                          side:
                              const BorderSide(color: Colors.blue, width: 0.9),
                        ),
                        elevation: 10,
                        shadowColor: Color(Colors.blue.value),
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
                                    return const Text(
                                        'Erro ao carregar imagem');
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
            ],
          ),
        ),
      ),
    );
  }
}
