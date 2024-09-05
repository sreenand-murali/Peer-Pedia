import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/user_model.dart';

class UserNotifier extends StateNotifier<UserModel>{
  UserNotifier(): super(UserModel(firstName: "", lastName: "", username: "", dpLink: ""));

  void setUser(UserModel user){
    state = user;
  }
}

final userProvider = StateNotifierProvider<UserNotifier, UserModel>((ref) => UserNotifier());