import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Auth/login.dart';
import 'package:http/http.dart' as http;  

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool isPasswordVisible = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confrimPasswordController = TextEditingController();

  final baseUrl = Uri.parse("http://192.168.0.104:8000/api"); 

  final _formKey = GlobalKey<FormState>();
  final RegExp emailRegex = RegExp(
    r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');

  Future<void> _register() async{
    if(!_formKey.currentState!.validate()) return;
    if(confrimPasswordController.text != passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords dont match")));
      return;
    }

    final registerUrl = Uri.parse("$baseUrl/register");
    final response = await http.post(
      registerUrl, 
      headers:{
      "Content-Type" : "application/json"
      }, 
      body: jsonEncode({
        'name' : nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'password_confirmation': confrimPasswordController.text
      })
    );
    
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Registered Successfully")));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Login()),
      );
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Failed ${response.body}")));
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(245, 240, 233, 1),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
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
                      controller: nameController,
                      validator: (value){
                        if(value!.isEmpty){
                          return "Name cannot be empty";
                        }
                      },
                      decoration: InputDecoration(
                        label: Text("Name"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.account_circle_sharp, color: Color.fromRGBO(173, 159, 141, 1),)
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      validator: (value){
                        if(value == null || value.isEmpty) return "Email is required";
                        if(!emailRegex.hasMatch(value)) return "Enter correct email";
                      },
                      controller: emailController,
                      decoration: InputDecoration(
                        label: Text("Email"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.email, color: Color.fromRGBO(173, 159, 141, 1),)
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      validator: (value){
                        if(value == null || value.isEmpty) return "Enter password";
                      },
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text("Password"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(173, 159, 141, 1),),
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
                    SizedBox(height: 15,),
                    TextFormField(
                      validator: (value){
                        if(value == null || value.isEmpty) return "Confirm Password";
                      },
                      controller: confrimPasswordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        label: Text("Confirm Password"),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        prefixIcon: Icon(Icons.lock, color: Color.fromRGBO(173, 159, 141, 1),),
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
                child: TextButton(onPressed: _register, child: Text("Register", style: TextStyle(color: Colors.white),))
              ),
              SizedBox(height: 15,),
              Row(
                mainAxisAlignment:MainAxisAlignment.center,
                children: [
                  Text("Already have an account? "),
                  GestureDetector(
                    onTap: () => {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Login()),
                      ),
                    },
                    child:Text("Login", style: TextStyle(color: Color.fromRGBO(173, 159, 141, 1)),)
                  )
                ],)
            ],
          ),
        ),
      ),
    );
  }
}