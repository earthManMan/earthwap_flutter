import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:firebase_login/presentation/home/homeViewModel.dart';
import 'package:firebase_login/presentation/login/loginViewModel.dart';
import 'package:firebase_login/presentation/mypage/mypageViewModel.dart';
import 'package:firebase_login/presentation/sell/sellViewModel.dart';
import 'package:firebase_login/presentation/world/worldViewModel.dart';
import 'package:firebase_login/presentation/chat/chatViewModel.dart';
import 'package:firebase_login/presentation/register/registerViewModel.dart';
import 'package:firebase_login/presentation/password/passwordViewModel.dart';
import 'package:firebase_login/domain/login/userService.dart';
import 'package:firebase_login/domain/home/itemService.dart';
import 'package:firebase_login/domain/world/contentService.dart';
import 'package:firebase_login/domain/chat/matchService.dart';
import 'package:firebase_login/domain/world/TrashPickupService.dart';
import 'package:firebase_login/domain/alarm/alarmService.dart';

Future<List<SingleChildWidget>> getProviders() async {
  final userService = UserService.instance;
  final itemService = ItemService.instance;
  final contentService = ContentService.instance;
  final matchService = MatchService.instance;
  final pickupService = TrashPickupService.instance;
  final alarmService = AlarmService.instance;

  return [
    ChangeNotifierProvider(
        create: (_) => LoginViewModel.initialize(userService)),
    ChangeNotifierProvider(
      create: (_) => HomeViewModel.initialize(
        userService,
        itemService,
        alarmService,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => MypageViewModel.initialize(
        userService,
        itemService,
        contentService,
        pickupService,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => WorldViewModel.initialize(userService),
    ),
    ChangeNotifierProvider(
      create: (_) => SellViewModel.initialize(userService),
    ),
    ChangeNotifierProvider(
      create: (_) => ChatViewModel.initialize(
        userService,
        matchService,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => RegisterViewModel.initialize(),
    ),
    ChangeNotifierProvider(
      create: (_) => PasswordViewModel.initialize(),
    ),
  ];
}
