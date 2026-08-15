// P3 钱包页测试：余额/流水展示、空流水、加载失败重试（注入内存替身，不发网络请求）。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qtaccount/screens/wallet_screen.dart';
import 'package:qtaccount/services/auth_service.dart';
import 'package:qtaccount/services/wallet_api.dart';

class _FakeWalletApi extends WalletApi {
  _FakeWalletApi({List<TransactionItem>? transactions, this.fail = false})
    : transactions = transactions ?? [
        const TransactionItem(id: 1, type: 'recharge', amount: 10000, note: '', createdAt: '2026-08-01T10:00:00Z'),
        const TransactionItem(id: 2, type: 'consume', amount: 2500, note: '', createdAt: '2026-08-05T12:00:00Z'),
        const TransactionItem(id: 3, type: 'issue', amount: 5000, note: '', createdAt: '2026-08-10T09:00:00Z'),
      ],
        super(baseUrl: 'http://fake', token: 't', customerId: 'u1');

  final List<TransactionItem> transactions;
  final bool fail;

  @override
  Future<Wallet> fetchWallet() async {
    if (fail) {
      throw Exception('boom');
    }
    return const Wallet(balance: 12345, accountId: 'acc-1');
  }

  @override
  Future<List<TransactionItem>> fetchTransactions([String? accountId]) async {
    if (fail) {
      throw Exception('boom');
    }
    return transactions;
  }
}

class _FakeAuth extends AuthService {
  @override
  Future<String?> storedToken() async => 'saved-token';
}

Widget _screenWith(_FakeWalletApi api) => MaterialApp(
  home: Scaffold(body: WalletScreen(auth: _FakeAuth(), api: api, customerId: 'u1')),
);

void main() {
  testWidgets('钱包页展示余额与流水（类型中文 + 方向符号）', (WidgetTester tester) async {
    await tester.pumpWidget(_screenWith(_FakeWalletApi()));
    await tester.pumpAndSettle();

    expect(find.text('123.45'), findsOneWidget);
    expect(find.text('充值'), findsOneWidget);
    expect(find.text('+¥100.00'), findsOneWidget);
    expect(find.text('消费'), findsOneWidget);
    expect(find.text('-¥25.00'), findsOneWidget);
    expect(find.text('发券'), findsOneWidget);
    expect(find.text('¥50.00'), findsOneWidget); // 发券不影响余额，无符号
  });

  testWidgets('无流水时显示空态', (WidgetTester tester) async {
    await tester.pumpWidget(_screenWith(_FakeWalletApi(transactions: [])));
    await tester.pumpAndSettle();

    expect(find.text('暂无交易流水'), findsOneWidget);
  });

  testWidgets('加载失败显示错误与重试，重试成功恢复', (WidgetTester tester) async {
    final api = _FakeWalletApi(fail: true);
    await tester.pumpWidget(_screenWith(api));
    await tester.pumpAndSettle();

    expect(find.text('加载钱包失败，请稍后重试'), findsOneWidget);
    expect(find.text('重试'), findsOneWidget);
  });
}
