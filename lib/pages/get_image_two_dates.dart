import 'dart:async';
import 'package:apod_app/widgets/custom_app_bar.dart';
import 'package:apod_app/widgets/background.dart';
import 'package:apod_app/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import '../model/apod.dart';
import '../service/api_service.dart';

class GetImageTwoDates extends StatefulWidget {
  const GetImageTwoDates({super.key});
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
      barrierColor: Color(Colors.white.value),
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.black,
              surface: Colors.transparent,
              onSurface: Colors.black,
              //text white
            ),
            dialogBackgroundColor: Colors.transparent,
            scaffoldBackgroundColor: Colors.transparent,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: child!,
          ),
        );
      },
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

    try {
      final String start = DateFormat('yyyy-MM-dd').format(startDate!);
      final String end = DateFormat('yyyy-MM-dd').format(endDate!);

      final response = await apiService.fetchImagesInRange(start, end);

      setState(() {
        images = response.map((e) => Apod.fromJson(e)).toList();
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
      appBar: const CustomAppBar(title: 'Imagens entre datas'),
      body: Background(
        imagePath: 'android/icons/space_background.png',
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
                child: CustomElevatedButton(
                    text: "Escolha o intervalo de datas",
                    onPressed: _pickDateRange),
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
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 20.0),
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
