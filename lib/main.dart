import 'package:apod_app/model/apod.dart';
import 'package:apod_app/pages/home_page.dart';
import 'package:apod_app/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() {
  final getIt = GetIt.instance;

  getIt.registerLazySingleton<ApiService>(() => ApiServiceImpl(Apod.baseUrl));

  // getIt.registerLazySingleton<ApiService>(
  //     () => ApiServiceImpl('http://10.21.4.147:5202/api'));

  runApp(MaterialApp(
    home: HomePage(),
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      hintColor: Colors.black,
    ),
  ));
}
