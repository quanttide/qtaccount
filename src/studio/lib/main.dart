// 量潮账号中心入口：AuthGate 依据本地 JWT 决定登录页/主界面。
// API 基址经 --dart-define 注入（生产 = 网关 api.quanttide.com，本地联调 = localhost）。

import 'package:flutter/material.dart';

import 'screens/account_screen.dart';
import 'screens/login_screen.dart';
import 'screens/wallet_screen.dart';
import 'services/auth_service.dart';

void main() {
  runApp(MainApp(auth: AuthService()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, required this.auth});

  final AuthService auth;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '量潮账号中心',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: AuthGate(auth: auth),
    );
  }
}

/// 登录闸门：本地有 token 进主界面，否则进登录页；登出回登录页。
class AuthGate extends StatefulWidget {
  const AuthGate({super.key, required this.auth});

  final AuthService auth;

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool? _hasToken;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final token = await widget.auth.storedToken();
    if (mounted) {
      setState(() => _hasToken = token != null && token.isNotEmpty);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_hasToken == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_hasToken == true) {
      return MainShell(auth: widget.auth, onLogout: _logout);
    }
    return LoginScreen(auth: widget.auth, onSuccess: _login);
  }

  void _login() => setState(() => _hasToken = true);

  void _logout() => setState(() => _hasToken = false);
}

/// 主界面：底部导航双 tab（账号 / 钱包）。
class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.auth, required this.onLogout});

  final AuthService auth;
  final VoidCallback onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      AccountScreen(auth: widget.auth),
      WalletScreen(auth: widget.auth),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(_index == 0 ? '账号信息' : '钱包'),
        actions: [
          IconButton(
            tooltip: '退出登录',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await widget.auth.logout();
              widget.onLogout();
            },
          ),
        ],
      ),
      body: pages[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '账号',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: '钱包',
          ),
        ],
      ),
    );
  }
}
