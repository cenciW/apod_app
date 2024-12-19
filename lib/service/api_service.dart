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
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/image/$date'))
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception(
            'Requisição para $baseUrl/image/$date expirou após 10s');
      });

      // print('Request URL: $baseUrl/image/$date');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
            'Falha ao buscar imagem do dia: $date, codigo: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erro ao chamar a API: $e');
    }
  }

  @override
  Future<List<dynamic>> fetchImagesInRange(
      String startDate, String endDate) async {
    final response =
        await http.get(Uri.parse('$baseUrl/images/$startDate/$endDate'));
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao buscar imagens entre $startDate e $endDate');
    }
  }

  @override
  Future<List<dynamic>> fetchRandomImages(int amount) async {
    final response = await http.get(Uri.parse('$baseUrl/random/$amount'));
    if (response.statusCode == 200) {
      return List<dynamic>.from(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao buscar $amount imagens aleatórias');
    }
  }
}
