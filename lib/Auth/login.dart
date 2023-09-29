import 'package:flutter/material.dart';
import '../view/home.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../DBHelper/dbhelper.dart';
import '../models/transaksi.dart';
import 'register.dart';
import '../providers/user_provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isPasswordVisible = false;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormFieldState<String>> _usernameKey = GlobalKey();
  final GlobalKey<FormFieldState<String>> _passwordKey = GlobalKey();
  final UserProvider _userProvider = UserProvider();
  String NamaAplikasi = "Money Tracker";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selamat Datang'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset('assets/images/logo.png'),
              const SizedBox(height: 20.0),
              Text(
                NamaAplikasi,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextFormField(
                key: _usernameKey,
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
              ),
              const SizedBox(height: 20.0),
              TextFormField(
                key: _passwordKey,
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  // Navigasi ke halaman registrasi
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                child: const Text(
                  'Belum punya akun? Registrasi',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  final username = _usernameController.text;
                  final password = _passwordController.text;
                  final dbHelper = DBHelper();

                  await _userProvider.fetchUserByUsername(username);
                  if (_userProvider.user != null &&
                      _userProvider.user!.password == password) {
                    final userProvider =
                        Provider.of<UserProvider>(context, listen: false);
                    userProvider.fetchUserByUsername(username);
                    final transaksiList = await dbHelper.getTransaksiList();
                    _showSuccessAlert(context, username, transaksiList);
                  } else {
                    _showErrorAlert(context);
                    _usernameController.clear();
                    _passwordController.clear();
                  }
                },
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(double.infinity, 40.0),
                  ),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSuccessAlert(
      BuildContext context, String username, List<Transaksi> transaksiList) {
    QuickAlert.show(
      context: context,
      title: "Login berhasil",
      text: "Selamat datang, $username",
      type: QuickAlertType.success,
    ).then((_) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            transaksiList: transaksiList,
          ),
        ),
      );
    });
  }

  void _showErrorAlert(BuildContext context) {
    QuickAlert.show(
      context: context,
      title: "Login Gagal",
      text: "Username atau password salah.",
      type: QuickAlertType.error,
    );
  }
}
