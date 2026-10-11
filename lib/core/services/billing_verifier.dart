import 'dart:convert';

import 'package:asn1lib/asn1lib.dart';
import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';

/// Play Console → Monetization → Licensing public key for ExpenseMate.
/// Public data — safe to ship in the APK. Used to RSA-SHA1 verify the
/// signature Play attaches to every purchase.
const String _kPlayPublicKey =
    'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyshunVRB4CkZOkDuipOcKimYCRwILB4y'
    'XlpIe2zVHDolWTWhXpGXO4GIjYcWyo/g6t31ekjwT6uTjCq0POG5HOrz/scSqmDLLTPkLql5QOge'
    'ZQTyV+soXIp/UZPzb7e7ruq2NA+n6W/HVtYn2eFRwaZaqXTJphKZl3Z2GU9mXdgma7dq2E54iEzp'
    'mMzJhDbFcqvE48s7BdZOhzDPesYvLaurIKSzhrtUIvYx12GBU10YW7XOWkjZApmC0J4haI3RqMtW'
    '16RiN6NKsMtvRYpSRHvFj5d11Bf6QYFG22CfitQl6Dr9xB7Q7bTJZkw2Eig5IHgV8T206R8QJMQQ'
    'k9n/rwIDAQAB';

RSAPublicKey? _cachedKey;

RSAPublicKey _publicKey() {
  final cached = _cachedKey;
  if (cached != null) return cached;
  final der = base64.decode(_kPlayPublicKey);
  final topLevel = ASN1Parser(der).nextObject() as ASN1Sequence;
  final bitString = topLevel.elements[1] as ASN1BitString;
  final rsaSeq = ASN1Parser(bitString.contentBytes()).nextObject() as ASN1Sequence;
  final modulus = (rsaSeq.elements[0] as ASN1Integer).valueAsBigInteger;
  final exponent = (rsaSeq.elements[1] as ASN1Integer).valueAsBigInteger;
  final key = RSAPublicKey(modulus, exponent);
  _cachedKey = key;
  return key;
}

/// Verifies the RSA-SHA1 (PKCS#1 v1.5) signature that Play attaches to a
/// purchase. `originalJson` is the source string Play signed;
/// `signature` is the Base64-encoded signature.
///
/// Returns `false` for any failure (bad signature, malformed input,
/// parse error). Callers decide whether to enforce.
bool verifyPurchaseSignature(String originalJson, String signature) {
  try {
    final signer = RSASigner(SHA1Digest(), '06052b0e03021a')
      ..init(false, PublicKeyParameter<RSAPublicKey>(_publicKey()));
    final data = Uint8List.fromList(utf8.encode(originalJson));
    final sig = RSASignature(base64.decode(signature));
    return signer.verifySignature(data, sig);
  } catch (e) {
    debugPrint('billing_verifier: verify threw: $e');
    return false;
  }
}
