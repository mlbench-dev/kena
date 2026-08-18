// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'env.dart';

// **************************************************************************
// EnviedGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// generated_from: .env
final class _Env {
  static const List<int> _enviedkeyplacesApiKey = <int>[
    3051371890,
    1696585126,
    2375240519,
    2256088862,
    1486054110,
    3570555093,
    2657342997,
    1585248739,
    512575439,
    3664048088,
    196587377,
    291285408,
    2695199540,
    1667379089,
    73197253,
  ];

  static const List<int> _envieddataplacesApiKey = <int>[
    3051371778,
    1696585162,
    2375240486,
    2256088957,
    1486054075,
    3570555069,
    2657343098,
    1585248655,
    512575403,
    3664048061,
    196587267,
    291285503,
    2695199583,
    1667379188,
    73197244,
  ];

  static final String placesApiKey = String.fromCharCodes(
    List<int>.generate(
      _envieddataplacesApiKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddataplacesApiKey[i] ^ _enviedkeyplacesApiKey[i]),
  );
}
