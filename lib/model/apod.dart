class Apod {
  final String title;
  final String explanation;
  final String url;

  Apod({required this.title, required this.explanation, required this.url});

  static String baseUrl = 'http://10.0.2.2:5000/api/APOD';

  factory Apod.fromJson(Map<String, dynamic> json) {
    return Apod(
      title:
          json['title'] ?? 'Sem título', // Valor padrão caso 'title' seja null
      explanation: json['explanation'] ??
          'Sem descrição', // Valor padrão caso 'explanation' seja null
      url: json['url'] ?? '', // Valor padrão caso 'url' seja null
    );
  }
}
