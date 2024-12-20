import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class ApiService {
  Future<dynamic> fetchImageByDate(String date);
  Future<List<dynamic>> fetchImagesInRange(String startDate, String endDate);
  Future<List<dynamic>> fetchRandomImages(int amount);
}

class ApiServiceImpl implements ApiService {
  final String baseUrl;

  ApiServiceImpl(this.baseUrl);

  @override
  Future<dynamic> fetchImageByDate(String date) async {
    final response = await http
        .get(Uri.parse('$baseUrl/image/$date'))
        .timeout(const Duration(seconds: 10), onTimeout: () {
      throw Exception('Requisição para expirou após 10s');
    });

    // print('Request URL: $baseUrl/image/$date');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Imagem não encontrada para a data $date');
    } else if (response.statusCode == 500) {
      throw Exception('Erro interno no servidor');
    } else if (response.statusCode == 400) {
      throw Exception('Data inválida');
    } else {
      throw Exception('Falha ao buscar imagem para a data $date');
    }
  }

  @override
  Future<List<dynamic>> fetchImagesInRange(
      String startDate, String endDate) async {
    final response = await http
        .get(Uri.parse('$baseUrl/images/$startDate/$endDate'))
        .timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Requisição para expirou após 10s');
      },
    );
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 404) {
      throw Exception('Imagens não encontradas para o intervalo de datas');
    } else if (response.statusCode == 500) {
      throw Exception('Erro interno no servidor');
    } else if (response.statusCode == 400) {
      throw Exception('Datas inválidas');
    } else {
      throw Exception('Falha ao buscar imagens para o intervalo de datas');
    }
  }

  @override
  Future<List<dynamic>> fetchRandomImages(int amount) async {
    final response =
        await http.get(Uri.parse('$baseUrl/random/$amount')).timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        throw Exception('Requisição para expirou após 10s');
      },
    );
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Quantidade inválida');
    } else if (response.statusCode == 404) {
      throw Exception('Imagens não encontradas');
    } else if (response.statusCode == 500) {
      throw Exception('Erro interno no servidor');
    } else {
      throw Exception('Falha ao buscar imagens aleatórias');
    }
  }
}
