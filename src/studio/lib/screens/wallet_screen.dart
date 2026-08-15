// 钱包页：余额 + 交易流水（只读，不做在线充值）。
// 骨架占位，P3 实装余额与流水展示。

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('钱包（建设中）'));
  }
}
