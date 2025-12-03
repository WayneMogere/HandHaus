import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Auth/login.dart';
import 'package:hand_haus_mobile/Views/category.dart';
import 'package:hand_haus_mobile/Views/home_page.dart';
import 'package:hand_haus_mobile/Views/item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final baseUrl = Uri.parse("http://192.168.0.104:8000/api");

  Future<Map>? userData;

  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map> fetchData() async{
    final token = await getToken();
    final fetchUrl = Uri.parse("$baseUrl/getProfile"); 
    final data = await http.get(
      fetchUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      },
      
    );

    final responseData = jsonDecode(data.body);
    if(responseData['statusCode'] == 200){
      print("Profile fetched Successfully");
      return responseData['User'];
    }else{
      throw Exception("Failed to fetch User");
    }
  }
  void initState(){
    super.initState();
    userData = fetchData();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 243, 236, 1),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(248, 243, 236, 1),
        // backgroundColor: Color.fromRGBO(173, 159, 141, 1),
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => HomePage())
                );
              }, 
              icon: Icon(Icons.home_outlined, color: Color.fromRGBO(173, 159, 141, 1))
            ),
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Item())
                );
              },
              icon: Icon(Icons.shopping_bag_outlined, color: Color.fromRGBO(173, 159, 141, 1))
            ), 
            label: "Cart"
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Profile())
                );
              },
              icon: Icon(Icons.account_circle_outlined, color: Colors.brown)
            ), 
            label: "Profile"
          ),
        ]
      ),
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(248, 243, 236, 1), 
        // title: Text("Welcome $name"),
        // elevation: 5,
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
            ListTile(
              title: Text("Categories"),
              leading: Icon(Icons.category_outlined),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Category())
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
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            FutureBuilder<Map>(
              future: userData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final user = snapshot.data!;
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextField(
                          decoration: InputDecoration(labelText: 'Name'),
                          controller: TextEditingController(text: user['name']),
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Email'),
                          controller: TextEditingController(text: user['email']),
                        ),
                        ElevatedButton(
                          onPressed: logout, 
                          child: Text("Logout", style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(173, 159, 141, 1),
                          ),
                        )
                      ],
                      
                    ),
                  );
                } else {
                  return Center(child: Text('No data found'));
                }
              },
            )
          ],
        ),
      )
    );
  }
}