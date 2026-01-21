import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Auth/login.dart';
import 'package:hand_haus_mobile/Auth/register.dart';
import 'package:hand_haus_mobile/Views/home_page.dart';
import 'package:hand_haus_mobile/Views/item.dart';
import 'package:hand_haus_mobile/Views/order.dart';
import 'package:hand_haus_mobile/Views/orders.dart';
import 'package:hand_haus_mobile/Views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class User extends StatefulWidget {
  const User({super.key});

  @override
  State<User> createState() => _UserState();
}

class _UserState extends State<User> {
  final baseUrl = Uri.parse("http://192.168.0.109:8000/api"); 

  String? _role;
  Future<Map>? users;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confrimPasswordController = TextEditingController();

  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  String role = '';
  void loadRole() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role')??'';
    });
  }

  Future<Map> fetchData() async{
    final fetchUrl = Uri.parse("$baseUrl/getUser");
    final token = await getToken();
    final data = await http.get(
      fetchUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      },
      
    );

    final responseData = jsonDecode(data.body);
    if(responseData['statusCode'] == 200){
      print("Users fetched Successfully");
    }else{
      throw Exception("Failed to fetch users");
    }

    return responseData;
  }

  Future<void> _register() async{
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
        'password_confirmation': confrimPasswordController.text,
        'role_id': _role,
      })
    );
    
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User Registered Successfully")));
      refreshData();
      Navigator.of(context).pop();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Registration Failed ${response.body}")));
    }

  }

  Future<void> updateUser(user_id) async{
    if(confrimPasswordController.text != passwordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Passwords dont match")));
      return;
    }

    final registerUrl = Uri.parse("$baseUrl/updateUser/$user_id");
    final response = await http.post(
      registerUrl, 
      headers:{
      "Content-Type" : "application/json"
      }, 
      body: jsonEncode({
        'name' : nameController.text,
        'email': emailController.text,
        'password': passwordController.text,
        'password_confirmation': confrimPasswordController.text,
        'role_id': _role,
      })
    );
    
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User updated Successfully")));
      refreshData();
      Navigator.of(context).pop();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Updating User Failed ${response.body}")));
    }

  }

  Future<void> deleteUser(int user_id) async{
    final deleteUrl = Uri.parse("$baseUrl/deleteUser/$user_id");
    final token = await getToken();
    final response = await http.delete(
      deleteUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      }, 
    );
    
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("User deleted successfully")));
      refreshData();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete user")));
    }

  }

  Future<void> logout() async{
    final logoutUrl = Uri.parse("$baseUrl/logout"); 
    final response = await http.post(
      logoutUrl,
      headers: {
        "Accept": "application/json",
        "Authorization": "Bearer ${await getToken()}"
      },
     );
     Map data = jsonDecode(response.body);
     if(data['statusCode'] == 200){
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove("name");
        await prefs.remove("token");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Logged out Succefully")
          )
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context)=> Login())
        );
      }
    
  }

  void refreshData(){
    setState(() {
    users = fetchData();
    loadRole();
    });
  }

  void initState(){
    super.initState();
    users = fetchData();
    loadRole();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 243, 236, 1),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown,
        selectedFontSize: 13,
        backgroundColor: Color.fromRGBO(248, 243, 236, 1),
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => HomePage())
                );
              }, 
              icon: Icon(Icons.home_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
            ),
            label: "Home"
          ),
          if(role == 'Customer')
            BottomNavigationBarItem(
              icon: IconButton(
                onPressed: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Order())
                  );
                },
                icon: Icon(Icons.shopping_bag_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
              ), 
              label: "Cart"
            ),
          if(role == 'Staff'|| role == 'Administrator')
            BottomNavigationBarItem(
              icon: IconButton(
                onPressed: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Item())
                  );
                },
                icon: Icon(Icons.toys, color: Color.fromRGBO(173, 159, 141, 1),)
              ), 
              label: "Items"
            ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Profile())
                );
              },
              icon: Icon(Icons.account_circle_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
            ), 
            label: "Profile"
          ),
        ]
      ),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(248, 243, 236, 1),
        title: Text("Users"),
      ),
      drawer: Drawer(
        backgroundColor: Color.fromRGBO(248, 243, 236, 1),
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            SizedBox(height: 40,),
            ListTile(
              title: Text("Items"),
              leading: Icon(Icons.toys),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Item())
                );
              },
            ),
            if(role == 'Staff'|| role == 'Administrator')
              ListTile(
                title: Text("Orders"),
                leading: Icon(Icons.shopping_bag_outlined),
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => Orders())
                  );
                },
              ),
            if(role == 'Administrator')
              ListTile(
                title: Text("Users"),
                leading: Icon(Icons.shopping_bag_outlined),
                onTap: (){
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (context) => User())
                  );
                },
              ),
            ListTile(
              title: Text("Profile"),
              leading: Icon(Icons.account_circle_outlined),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Profile())
                );
              },
            ),
            SizedBox(height: 25,),
            ElevatedButton(
              onPressed: logout, 
              child: Text("Logout", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(173, 159, 141, 1),
              ),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          if(role == 'Staff'||role == 'Administrator')
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: (){
                  showDialog(
                    context: context, 
                    builder: (BuildContext context){
                      return SimpleDialog(
                        title: Text("Add User"),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: nameController,
                              decoration: InputDecoration(
                                label: Text("Name"),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: emailController,
                              decoration: InputDecoration(
                                label: Text("Email"),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: passwordController,
                              decoration: InputDecoration(
                                label: Text("Password"),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              controller: confrimPasswordController,
                              decoration: InputDecoration(
                                label: Text("Confirm Password"),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                              ),
                            ),
                          ),
                          RadioGroup<String>(
                            groupValue: _role,
                            onChanged: (String? value) {
                              setState(() {
                                _role = value;
                              });
                            },
                            child: Column(
                              children: <Widget>[
                                ListTile(
                                  title: Text("Customer"),
                                  leading: Radio<String>(
                                    value: '3',
                                  ),
                                ),
                                ListTile(
                                  title: Text("Staff"),
                                  leading: Radio<String>(
                                    value: '2',
                                  ),
                                )
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: (){
                                    Navigator.of(context).pop();
                                  }, 
                                  child: Text("Cancel")
                                ),
                              ),
                              SizedBox(width: 50,),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ElevatedButton(
                                  onPressed: (){
                                    _register();
                                  }, 
                                  child: Text("Add User")
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    }
                  );
                }, 
                child: Text("Add User")
              ),
            ),
          FutureBuilder<Map>(future: users, builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(248, 243, 236, 1)));
            }
            if(!snapshot.hasData){
              print(snapshot);
              return Text("No User found");
            }
            final response = snapshot.data!;
            final List dataList = response["User"] ?? [];
            if(dataList.isEmpty) return Text("No data");

            return Expanded(
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index){
                  final item = dataList[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.all(10),
                        child: SizedBox(
                          width: 300,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                Text(
                                  item['name'], 
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  item['email'],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Column(
                                    children: [
                                      if(role == 'Customer')
                                        ElevatedButton(
                                          onPressed: (){
                                            Register();
                                          }, 
                                          child: Text("Add to Cart")
                                        ),
                                      if(role == 'Staff'||role == 'Administrator')
                                        ElevatedButton(
                                          onPressed: (){
                                            showDialog(
                                              context: context, 
                                              builder: (BuildContext context){
                                                return SimpleDialog(
                                                  title: Text("Edit Item"),
                                                  children: [ 
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        controller: nameController,
                                                        decoration: InputDecoration(
                                                          label: Text("Name"),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                          prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        controller: emailController,
                                                        decoration: InputDecoration(
                                                          label: Text("Email"),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                          prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        controller: passwordController,
                                                        decoration: InputDecoration(
                                                          label: Text("Password"),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                          prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        controller: confrimPasswordController,
                                                        decoration: InputDecoration(
                                                          label: Text("Confirm password"),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                          prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                                                        ),
                                                      ),
                                                    ),
                                                    RadioGroup<String>(
                                                      groupValue: _role,
                                                      onChanged: (String? value) {
                                                        setState(() {
                                                          _role = value;
                                                        });
                                                      },
                                                      child: Column(
                                                        children: <Widget>[
                                                          ListTile(
                                                            title: Text("Customer"),
                                                            leading: Radio<String>(
                                                              value: '3',
                                                            ),
                                                          ),
                                                          ListTile(
                                                            title: Text("Staff"),
                                                            leading: Radio<String>(
                                                              value: '2',
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: ElevatedButton(
                                                            onPressed: (){
                                                              Navigator.of(context).pop();
                                                            }, 
                                                            child: Text("Cancel")
                                                          ),
                                                        ),
                                                        SizedBox(width: 50,),
                                                        Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: ElevatedButton(
                                                            onPressed: (){
                                                              updateUser(item['id']);
                                                            }, 
                                                            child: Text("Update Item")
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                );
                                              }
                                            );
                                          }, 
                                          child: Text("Edit")
                                        ),
                                      if(role == 'Administrator')
                                        ElevatedButton(
                                          onPressed: (){
                                            deleteUser(item['id']);
                                          }, 
                                          child: Text("Delete User", style: TextStyle(color: Colors.red),)
                                        ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      ),
                    ],
                  );
                },
              ),
            );
          })
        ]
      )
    );
  }
}