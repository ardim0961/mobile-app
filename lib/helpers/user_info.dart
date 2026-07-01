import 'package:shared_preferences/shared_preferences.dart';

class UserInfo {
  static String? nama;
  static String? email;
  static String? password;
  static String? profilePicPath;

  static const String defaultEmail = 'admin@gmail.com';
  static const String defaultPassword = '123456';
  static const String defaultNama = 'Admin Piket';

  static const String keyNama = 'user_nama';
  static const String keyEmail = 'user_email';
  static const String keyPassword = 'user_password';
  static const String keyPic = 'user_pic';
  static const String keyIsLogin = 'is_login';

  static Future<void> setUser(String name, String mail, String pass) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(keyNama, name);
    await pref.setString(keyEmail, mail);
    await pref.setString(keyPassword, pass);
    
    nama = name;
    email = mail;
    password = pass;
  }

  static Future<void> setLoginStatus(bool status) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(keyIsLogin, status);
  }

  static Future<bool> getLoginStatus() async {
    final pref = await SharedPreferences.getInstance();
    return pref.getBool(keyIsLogin) ?? false;
  }

  static Future<void> loadUserData() async {
    final pref = await SharedPreferences.getInstance();
    nama = pref.getString(keyNama);
    email = pref.getString(keyEmail);
    password = pref.getString(keyPassword);
    profilePicPath = pref.getString(keyPic);
  }

  static Future<void> updateNama(String newNama) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(keyNama, newNama);
    nama = newNama;
  }

  static Future<void> updateEmail(String newEmail) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(keyEmail, newEmail);
    email = newEmail;
  }

  static Future<void> updatePassword(String newPassword) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString(keyPassword, newPassword);
    password = newPassword;
  }

  static Future<void> updateProfilePic(String? path) async {
    final pref = await SharedPreferences.getInstance();
    if (path == null) {
      await pref.remove(keyPic);
    } else {
      await pref.setString(keyPic, path);
    }
    profilePicPath = path;
  }

  static bool login(String mail, String pass) {
    if (email == null && mail == defaultEmail && pass == defaultPassword) {
      return true;
    }
    return (email ?? defaultEmail) == mail && (password ?? defaultPassword) == pass;
  }

  static String getNama() => nama ?? defaultNama;
  static String getEmail() => email ?? defaultEmail;
  static String getPassword() => password ?? defaultPassword;
  static String? getProfilePic() => profilePicPath;

  static Future<void> logout() async {
    final pref = await SharedPreferences.getInstance();
    await pref.setBool(keyIsLogin, false);
    // Membersihkan data di memori aplikasi
    nama = null;
    email = null;
    password = null;
    profilePicPath = null;
  }

  static Future<void> deleteAccount() async {
    final pref = await SharedPreferences.getInstance();
    await pref.clear(); // Menghapus semua data
    nama = null;
    email = null;
    password = null;
    profilePicPath = null;
  }
}
