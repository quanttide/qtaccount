// P2 账号信息页测试：资料展示 / 编辑昵称 / 修改密码（注入内存替身 AccountApi，不发网络请求）。

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:qtaccount/screens/account_screen.dart';
import 'package:qtaccount/screens/change_password_screen.dart';
import 'package:qtaccount/services/account_api.dart';
import 'package:qtaccount/services/auth_service.dart';

/// 内存替身：直接返回/记录数据，不发网络请求。
class _FakeAccountApi extends AccountApi {
  _FakeAccountApi()
    : info = const UserInfo(
        sub: 'u1',
        username: 'alice',
        email: 'alice@example.com',
        phone: '13900139000',
        nickname: 'Alice',
      ),
      super(baseUrl: 'http://fake', token: 't');

  UserInfo info;
  String? updatedNickname;
  bool changePasswordCalled = false;

  @override
  Future<UserInfo> fetchUserInfo() async => info;

  @override
  Future<void> updateNickname(String nickname) async {
    updatedNickname = nickname;
    info = UserInfo(
      sub: info.sub,
      username: info.username,
      email: info.email,
      phone: info.phone,
      nickname: nickname,
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    changePasswordCalled = true;
  }
}

class _FakeAuth extends AuthService {
  @override
  Future<String?> storedToken() async => 'saved-token';
}

Widget _screenWith(_FakeAccountApi api) => MaterialApp(
  home: Scaffold(body: AccountScreen(auth: _FakeAuth(), api: api)),
);

void main() {
  testWidgets('账号信息页展示昵称/用户名/手机号/邮箱/角色', (WidgetTester tester) async {
    await tester.pumpWidget(_screenWith(_FakeAccountApi()));
    await tester.pumpAndSettle();

    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('alice'), findsOneWidget);
    expect(find.text('13900139000'), findsOneWidget);
    expect(find.text('alice@example.com'), findsOneWidget);
    expect(find.text('普通用户'), findsOneWidget); // 无角色
  });

  testWidgets('账号信息页展示管理员角色', (WidgetTester tester) async {
    final api = _FakeAccountApi();
    api.info = UserInfo(
      sub: api.info.sub,
      username: api.info.username,
      email: api.info.email,
      phone: api.info.phone,
      nickname: api.info.nickname,
      role: 'admin',
    );
    await tester.pumpWidget(_screenWith(api));
    await tester.pumpAndSettle();

    expect(find.text('admin'), findsOneWidget);
  });

  testWidgets('编辑昵称：保存后列表显示新昵称', (WidgetTester tester) async {
    final api = _FakeAccountApi();
    await tester.pumpWidget(_screenWith(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Alice'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '新昵称');
    await tester.tap(find.text('保存'));
    await tester.pumpAndSettle();

    expect(api.updatedNickname, '新昵称');
    expect(find.text('新昵称'), findsOneWidget);
    expect(find.text('昵称已更新'), findsOneWidget);
  });

  testWidgets('修改密码：进入改密码页提交成功返回', (WidgetTester tester) async {
    final api = _FakeAccountApi();
    await tester.pumpWidget(_screenWith(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('修改密码'));
    await tester.pumpAndSettle();
    expect(find.byType(ChangePasswordScreen), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'oldpass1');
    await tester.enterText(find.byType(TextField).at(1), 'newpass1');
    await tester.enterText(find.byType(TextField).at(2), 'newpass1');
    await tester.tap(find.text('确认修改'));
    await tester.pumpAndSettle();

    expect(api.changePasswordCalled, isTrue);
    expect(find.text('密码修改成功'), findsOneWidget);
    expect(find.byType(ChangePasswordScreen), findsNothing);
  });

  testWidgets('修改密码：两次新密码不一致时本地拦截', (WidgetTester tester) async {
    final api = _FakeAccountApi();
    await tester.pumpWidget(_screenWith(api));
    await tester.pumpAndSettle();

    await tester.tap(find.text('修改密码'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).at(0), 'oldpass1');
    await tester.enterText(find.byType(TextField).at(1), 'newpass1');
    await tester.enterText(find.byType(TextField).at(2), 'newpass2');
    await tester.tap(find.text('确认修改'));
    await tester.pumpAndSettle();

    expect(api.changePasswordCalled, isFalse);
    expect(find.text('两次输入的新密码不一致'), findsOneWidget);
  });
}
