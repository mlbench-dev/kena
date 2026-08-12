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
    1379561774,
    222273777,
    3923570022,
    4123244233,
    4737466,
    2518382321,
    874257818,
    2811985165,
    1200618292,
    3545341126,
    4097284946,
    3390591144,
    1643056995,
    3582129863,
    3817272698,
  ];

  static const List<int> _envieddataplacesApiKey = <int>[
    1379561822,
    222273693,
    3923569927,
    4123244202,
    4737503,
    2518382233,
    874257909,
    2811985249,
    1200618320,
    3545341091,
    4097284896,
    3390591223,
    1643056904,
    3582129826,
    3817272579,
  ];

  static final String placesApiKey = String.fromCharCodes(
    List<int>.generate(
      _envieddataplacesApiKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddataplacesApiKey[i] ^ _enviedkeyplacesApiKey[i]),
  );
}
