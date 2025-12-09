import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:hand_haus_mobile/Auth/login.dart';
import 'package:hand_haus_mobile/Views/category.dart';
import 'package:hand_haus_mobile/Views/home_page.dart';
import 'package:hand_haus_mobile/Views/item.dart';
import 'package:hand_haus_mobile/Views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  final baseUrl = Uri.parse("http://192.168.0.104:8000/api"); 

  Future<Map>? orders;
  int? user_id;
  int total = 0;

  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  Future<int?> getUserId() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }
  
  Future<Map> fetchData() async{
    int? user_id = await getUserId();
    final fetchUrl = Uri.parse("$baseUrl/userOrder/$user_id");
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

  Future<void> addQuantity(order) async{
    final itemsUrl = Uri.parse("$baseUrl/addQuantity/$order");
    final token = await getToken();
    final data = await http.put(
      itemsUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      },
      
    ); 

    final responseData = jsonDecode(data.body);
    if(responseData['statusCode'] == 200){
      print("Quantity added successfully");
      refreshData();
    }else{
      throw Exception("Failed to add quantity");
    }

    return responseData;
  }

  Future<void> minusQuantity(order) async{
    final itemsUrl = Uri.parse("$baseUrl/minusQuantity/$order");
    final token = await getToken();
    final data = await http.put(
      itemsUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      },
      
    ); 

    final responseData = jsonDecode(data.body);
    if(responseData['statusCode'] == 200){
      print("Quantity deducted successfully");
      refreshData();
    }else{
      throw Exception("Failed to deduct quantity");
    }

    return responseData;
  }

  void refreshData(){
    setState(() {
      orders = fetchData();
    });
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
  void initState(){
    super.initState();
    orders = fetchData();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.brown,
        selectedFontSize: 13,
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
              icon: Icon(Icons.home_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
            ),
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Order())
                );
              },
              icon: Icon(Icons.shopping_bag_outlined, color: Colors.brown)
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
              icon: Icon(Icons.account_circle_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
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
            final List dataList = response["orders"] ?? [];
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
                              item['item_name'], 
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: (){
                                    minusQuantity(item['order_id']);
                                  }, 
                                  icon: Icon(Icons.remove)
                                ),
                                Text("Quantity: "),
                                Text(
                                  item['quantity'].toString(),
                                ),
                                IconButton(
                                  onPressed: (){
                                    addQuantity(item['order_id']);
                                    }, 
                                  icon: Icon(Icons.add)
                                )
                              ],
                            ),
                            Text('$order_price'),
                          ],
                        ),
                      ),
                    )
                  );
                },
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Total: $total"),
                SizedBox(width: 200,),
                ElevatedButton(
                  onPressed: (){}, 
                  child: Text("Checkout")
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}