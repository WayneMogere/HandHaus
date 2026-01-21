import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Auth/login.dart';
import 'package:hand_haus_mobile/Views/home_page.dart';
import 'package:hand_haus_mobile/Views/item.dart';
import 'package:hand_haus_mobile/Views/order.dart';
import 'package:hand_haus_mobile/Views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Orders extends StatefulWidget {
  const Orders({super.key});

  @override
  State<Orders> createState() => _OrdersState();
}

class _OrdersState extends State<Orders> {
  final baseUrl = Uri.parse("http://192.168.0.109:8000/api"); 

  Future<Map>? orders;

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
    final fetchUrl = Uri.parse("$baseUrl/getConfirmedOrder");
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
      print("Orders fetched Successfully");
    }else{
      throw Exception("Failed to fetch Orders");
    }

    return responseData;
  }
  Future<void> deleteOrder(int order_id) async{
    final deleteUrl = Uri.parse("$baseUrl/deleteConfirmedOrder/$order_id");
    final token = await getToken();
    final response = await http.delete(
      deleteUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      }, 
    );
    
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item deleted successfully")));
      refreshData();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to delete item")));
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
    orders = fetchData();
    loadRole();
    });
  }

  void initState(){
    super.initState();
    orders = fetchData();
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
        title: Text("Orders"),
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
              title: Text("Orders"),
              leading: Icon(Icons.shopping_bag_outlined),
              onTap: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Orders())
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
          FutureBuilder<Map>(future: orders, builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(248, 243, 236, 1)));
            }
            if(!snapshot.hasData){
              print(snapshot);
              return Center(
                child: Column(
                  children: [
                    Icon(Icons.error_outline),
                    Text(
                      "You don't have any orders"
                    ),
                  ],
                )
              );
            }
            final response = snapshot.data!;
            final List dataList = response["Order"] ?? [];
            if(dataList.isEmpty) return Text("No data");

            return Expanded(
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index){
                  final item = dataList[index];
                  int order_price = item['price']*item['quantity'];

                  return Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    margin: EdgeInsets.all(10),
                    child: SizedBox(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Text(
                              item['user_name'], 
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              item['item_name'], 
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Quantity: "),
                                Text(
                                  item['quantity'].toString(), 
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Price: "),
                                Text('$order_price', style: TextStyle(fontWeight: FontWeight.bold),),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Adress: "),
                                Text(
                                  item['delivery_adress'].toString(), 
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("Number: "),
                                Text(
                                  item['phone'].toString(), 
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: (){
                                  deleteOrder(item['id']);
                                }, 
                                child: Text("Delivered")
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}