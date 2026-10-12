import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:mindfully_evolve_app/screens/subscriptionmanagement/purchase_reporting.dart';
import 'package:mindfully_evolve_app/utils/api_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Google purchase and restore reporting uses the purchase token', () {
    for (final status in [PurchaseStatus.purchased, PurchaseStatus.restored]) {
      final purchase = PurchaseDetails(
        purchaseID: 'GPA.order-id',
        productID: 'annual',
        transactionDate: '1767225600000',
        verificationData: PurchaseVerificationData(
          localVerificationData: 'local-receipt',
          serverVerificationData: 'google-purchase-token',
          source: 'google_play',
        ),
        status: status,
      );
      expect(purchaseReportingFields(purchase), {
        'platform': 'android',
        'purchaseToken': 'google-purchase-token',
      });
      final apple = PurchaseDetails(
        productID: 'annual',
        verificationData: PurchaseVerificationData(
          localVerificationData: '',
          serverVerificationData: 'apple-receipt',
          source: 'app_store',
        ),
        transactionDate: null,
        status: status,
      );
      expect(purchaseReportingFields(apple), isEmpty);
    }
  });

  Future<void> send(http.Client client, {bool google = true}) =>
      ApiService.sendPurchase(
        productId: 'annual',
        purchaseId: 'GPA.order-id',
        amount: 0,
        purchaseDate: '1767225600000',
        planType: 'yearly',
        currencySymbol: 'USD',
        platform: google ? 'android' : null,
        purchaseToken: google ? 'google-purchase-token' : null,
        extraToken: 'signup-auth-token',
        client: client,
      );

  test('free purchase sends token and normalized date with signup authentication',
      () async {
    FlutterSecureStorage.setMockInitialValues({});
    final client = MockClient((request) async {
      expect(request.headers['Authorization'], 'Bearer signup-auth-token');
      final body = jsonDecode(request.body);
      expect(body['platform'], 'android');
      expect(body['purchaseToken'], 'google-purchase-token');
      expect(body['amount'], 0);
      expect(body['purchaseDate'], '2026-01-01T00:00:00.000Z');
      return http.Response('{}', 201);
    });
    addTearDown(client.close);
    await send(client);
  });

  test('Apple requests remain compatible without Google fields', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'signed-in'});
    final client = MockClient((request) async {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body.containsKey('purchaseToken'), isFalse);
      expect(body.containsKey('platform'), isFalse);
      return http.Response('{}', 201);
    });
    addTearDown(client.close);
    await send(client, google: false);
  });

  test('failed purchase saves never silently succeed', () async {
    FlutterSecureStorage.setMockInitialValues({'auth_token': 'signed-in'});
    for (final offline in [true, false]) {
      final client = MockClient((_) async {
        if (offline) throw const SocketException('offline');
        return http.Response('private server detail', 500);
      });
      addTearDown(client.close);
      await expectLater(send(client), throwsException);
    }
  });
}
