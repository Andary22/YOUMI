// AppProvider: auth session, current user, and global app state.
import 'package:flutter/foundation.dart';
import 'package:youmi_dev/models/mock_data.dart';
import 'package:youmi_dev/models/user.dart';

class AppProvider extends ChangeNotifier {
  AppUser _currentUser = MockData.users.first;

  AppUser get currentUser => _currentUser;

  void setCurrentUser(AppUser user) {
    _currentUser = user;
    notifyListeners();
  }
}
