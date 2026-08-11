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
    696309952,
    2664008663,
    3904558327,
    1001263244,
    604462882,
    3000726802,
    3974767325,
    192200237,
    829920424,
    2305804955,
    1389253923,
    24610161,
    2715599277,
    1881745302,
    4139954929,
  ];

  static const List<int> _envieddataplacesApiKey = <int>[
    696309936,
    2664008635,
    3904558230,
    1001263343,
    604462919,
    3000726906,
    3974767282,
    192200257,
    829920460,
    2305805054,
    1389253969,
    24610094,
    2715599302,
    1881745395,
    4139954824,
  ];

  static final String placesApiKey = String.fromCharCodes(
    List<int>.generate(
      _envieddataplacesApiKey.length,
      (int i) => i,
      growable: false,
    ).map((int i) => _envieddataplacesApiKey[i] ^ _enviedkeyplacesApiKey[i]),
  );
}
