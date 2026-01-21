import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Auth/register.dart';
import 'package:hand_haus_mobile/Views/home_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool isPasswordVisible = true;

  Future<void> storeUserName(String name) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', name);
  }
  Future<void> storeRole(String role) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', role);
  }
  Future<void> storeUserId(int id) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('id', id);
  }
  Future<void> storeToken(String token) async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final baseUrl = Uri.parse("http://192.168.0.109:8000/api");

  final _formKey = GlobalKey<FormState>();
  final RegExp emailRegex = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  Future<void> _login() async{
    if(!_formKey.currentState!.validate()) return;

    final loginUrl = Uri.parse("$baseUrl/login");
    final response = await http.post(
      loginUrl, 
      headers:{
      "Content-Type" : "application/json"
      }, 
      body: jsonEncode({
        'email': emailController.text,
        'password': passwordController.text,
      })
    );

    final Map<String, dynamic> data = jsonDecode(response.body);

    if(response.statusCode == 200){
      storeToken(data['token']);
      storeUserName(data['user'] ['name']);
      storeUserId(data['user'] ['id']);
      storeRole(data['user']['role']['name']);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Successful")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );

    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login Failed ${response.body}")));
    }

  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 240, 233, 1),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 100,
              backgroundImage: AssetImage('images/handhaus_logo.png'),
            ),
            SizedBox(height: 10,),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: emailController,
                    validator: (value){
                      if(value == null || value.isEmpty) return "Email is required";
                      if(!emailRegex.hasMatch(value)) return "Enter correct email";
                    },
                    decoration: InputDecoration(
                      label: Text("Email"),
                      // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.email, color: Color.fromRGBO(173, 159, 141, 1))
                    ),
                  ),
                  SizedBox(height: 10,),
                  TextFormField(
                    validator: (value){
                      if(value == null || value.isEmpty) return "Enter password";
                    },
                    controller: passwordController,
                    obscureText: isPasswordVisible,
                    decoration: InputDecoration(
                      label: Text("Password"),
                      // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(173, 159, 141, 1)),
                      suffixIcon: IconButton(
                        icon:Icon(Icons.remove_red_eye, color: Color.fromRGBO(173, 159, 141, 1)),
                        onPressed: (){
                          setState((){
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      )
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 5,),
            Container(
              alignment: Alignment(0, 0),
              decoration: BoxDecoration(
                color: Color.fromRGBO(173, 159, 141, 1),
                borderRadius: BorderRadius.circular(15)
              ),
              child: TextButton(onPressed: _login, child: Text("Login", style: TextStyle(color: Colors.white),))
            ),
            SizedBox(height: 15,),
            Row(
              mainAxisAlignment:MainAxisAlignment.center,
              children: [
                Text("Don't have an account? "),
                GestureDetector(
                  onTap: () => {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Register()),
                    ),
                  },
                  child:Text("Register", style: TextStyle(color: Color.fromRGBO(173, 159, 141, 1)),)
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}