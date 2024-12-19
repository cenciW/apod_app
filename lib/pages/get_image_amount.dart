import 'dart:async';
import 'package:apod_app/model/apod.dart';
import 'package:apod_app/widgets/custom_app_bar.dart';
import 'package:apod_app/widgets/background.dart';
import 'package:apod_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

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

    try {
      final response = await apiService.fetchRandomImages(amount);

      if (response.isNotEmpty && response != "null") {
        setState(() {
          images = List<Apod>.from(
            response.map((model) => Apod.fromJson(model)),
          );
        });
      } else {
        setState(() {
          errorMessage = 'Nenhuma imagem encontrada.';
        });
      }
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
      appBar: const CustomAppBar(title: 'Imagens por quantidade'),
      body: Background(
        imagePath: 'android/icons/space_count.png',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: CustomElevatedButton(
                  text: "Escolha a quantidade de imagens (1-30)",
                  onPressed: _pickAmount,
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
