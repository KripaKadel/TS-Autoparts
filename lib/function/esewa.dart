import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:esewa_flutter_sdk/esewa_flutter_sdk.dart';
import 'package:esewa_flutter_sdk/esewa_config.dart';
import 'package:esewa_flutter_sdk/esewa_payment.dart';
import 'package:esewa_flutter_sdk/esewa_payment_success_result.dart';
import 'package:flutter/material.dart';

import 'package:ts_autoparts_app/constant/esewa.dart';

class Esewa {
  final BuildContext context;
  final String productName;
  final double amount;
  final Function() onSuccess;
  final Function() onFailure;
  final Function() onCancel;

  Esewa({
    required this.context,
    required this.productName,
    required this.amount,
    required this.onSuccess,
    required this.onFailure,
    required this.onCancel,
  });

  void pay() {
    try {
      EsewaFlutterSdk.initPayment(
        esewaConfig: EsewaConfig(
          environment: Environment.test,
          clientId: kEsewaClientId,
          secretId: kEsewaSecretKey,
        ),
        esewaPayment: EsewaPayment(
          productId: DateTime.now().millisecondsSinceEpoch.toString(),
          productName: productName,
          productPrice: amount.toStringAsFixed(2),
        ),
        onPaymentSuccess: (EsewaPaymentSuccessResult result) {
          debugPrint('SUCCESS: ${result.refId}');
          verify(result).then((_) => onSuccess());
        },
        onPaymentFailure: () {
          debugPrint('FAILURE');
          onFailure();
        },
        onPaymentCancellation: () {
          debugPrint('CANCEL');
          onCancel();
        },
      );
    } catch (e) {
      debugPrint('EXCEPTION: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment error: $e')),
      );
    }
  }

  Future<void> verify(EsewaPaymentSuccessResult result) async {
    try {
      Dio dio = Dio();
      String basic =
          'Basic ${base64.encode(utf8.encode('$kEsewaClientId:$kEsewaSecretKey'))}';
      Response response = await dio.get(
        'https://rc-epay.esewa.com.np/api/epay/transaction/status/',
        queryParameters: {
          'product_code': result.productId,
          'total_amount': amount.toStringAsFixed(2),
          'transaction_uuid': result.refId,
        },
        options: Options(
          headers: {
            'Authorization': basic,
          },
        ),
      );
      debugPrint('Verification response: ${response.data}');
    } catch (e) {
      debugPrint('Verification error: $e');
    }
  }
}