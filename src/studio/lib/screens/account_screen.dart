// 账号信息页：查看昵称/手机号/邮箱 + 编辑昵称 + 修改密码。
// 骨架占位，P2 实装数据展示与编辑。

import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key, required this.auth});

  final AuthService auth;

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('账号信息（建设中）'));
  }
}
