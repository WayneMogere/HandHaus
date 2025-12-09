import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Auth/login.dart';
import 'package:hand_haus_mobile/Views/category.dart';
import 'package:hand_haus_mobile/Views/clothes.dart';
import 'package:hand_haus_mobile/Views/item.dart';
import 'package:hand_haus_mobile/Views/jewelery.dart';
import 'package:hand_haus_mobile/Views/order.dart';
import 'package:hand_haus_mobile/Views/profile.dart';
import 'package:hand_haus_mobile/Views/woodcrafts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final baseUrl = Uri.parse("http://192.168.0.104:8000/api"); 

  Future<Map>? categories;
  Future<Map>? woodcrafts;
  Future<Map>? jewelery;
  Future<Map>? clothes;
  
  Future<String?> getUserName() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }
  Future<int?> getUserId() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }

  String name = '';
  void loadName() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name')??'';
    });
  }

  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  Future<Map> fetchData() async{
    final fetchUrl = Uri.parse("$baseUrl/getCategory");
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
      print("Categories fetched Successfully");
    }else{
      throw Exception("Failed to fetch Categories");
    }

    return responseData;
  }

  Future<Map> getWoodcrafts() async{
    final itemsUrl = Uri.parse("$baseUrl/itemsCategory/1");
    final token = await getToken();
    final data = await http.get(
      itemsUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      },
      
    ); 

    final responseData = jsonDecode(data.body);
    if(responseData['statusCode'] == 200){
      print("Woodcrafts fetched Successfully");
    }else{
      throw Exception("Failed to fetch Woodcrafts");
    }

    return responseData;
  }

  Future<Map> getJewelery() async{
    final itemsUrl = Uri.parse("$baseUrl/itemsCategory/2");
    final token = await getToken();
    final data = await http.get(
      itemsUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      },
      
    ); 

    final responseData = jsonDecode(data.body);
    if(responseData['statusCode'] == 200){
      print("Jewelery fetched Successfully");
    }else{
      throw Exception("Failed to fetch Jewelery");
    }

    return responseData;
  }

  Future<Map> getClothes() async{
    final itemsUrl = Uri.parse("$baseUrl/itemsCategory/3");
    final token = await getToken();
    final data = await http.get(
      itemsUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      },
      
    ); 

    final responseData = jsonDecode(data.body);
    if(responseData['statusCode'] == 200){
      print("Clothes fetched Successfully");
    }else{
      throw Exception("Failed to fetch Clothes");
    }

    return responseData;
  }

  Future<void> addOrder(int item_id) async{
    final orderUrl = Uri.parse("$baseUrl/saveOrder");
    int? user_id = await getUserId();
    final token = await getToken();
    final response = await http.post(
      orderUrl, 
      headers:{
      "Content-Type" : "application/json",
      "Authorization": "Bearer $token"
      }, 
      body: jsonEncode({
        'user_id' : user_id,
        'item_id': item_id,
        'quantity': '1',
        'status': 'not paid',
      })
    );
    
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added to cart")));
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add item to cart")));
    }

  }

  void initState(){
    super.initState();
    categories = fetchData();
    loadName();
    woodcrafts = getWoodcrafts();
    jewelery = getJewelery();
    clothes = getClothes();
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
              icon: Icon(Icons.home_outlined, color: Colors.brown,)
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
              icon: Icon(Icons.shopping_bag_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
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
          Text("Welcome $name", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(height: 30,),
          Text("Categories:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
          FutureBuilder<Map>(future: categories, builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(248, 243, 236, 1)));
            }
            if(!snapshot.hasData){
              print(snapshot);
              return Text("No categories found");
            }
            final response = snapshot.data!;
            final List dataList = response["Category"] ?? [];
            if(dataList.isEmpty) return Text("No data");

            return Expanded(
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index){
                  final item = dataList[index];
                  return ListTile(
                    title: Text(item['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(item['description']),
                    trailing: TextButton(
                      onPressed: (){
                        if(item['name'] == 'Woodcrafts'){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => Woodcraft())
                          );
                        }
                        if(item['name'] == 'Jewelry'){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => Jewelery())
                          );
                        }
                        if(item['name'] == 'Clothes'){
                          Navigator.push(
                            context, 
                            MaterialPageRoute(builder: (context) => Clothes())
                          );
                        }
                      }, 
                      child: Icon(Icons.arrow_forward_ios_rounded)
                    ),
                  );
                },
              ),
            );
          }),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text(
                  "Woodcrafts:", 
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    fontSize: 15
                  )
                ),
              ],
            ),
          ),
          FutureBuilder(
            future: woodcrafts,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(248, 243, 236, 1)));
            }
            if(!snapshot.hasData){
              print(snapshot);
              return Text("No categories found");
            }
            final response = snapshot.data!;
            final List dataList = response["Data"] ?? [];
            if(dataList.isEmpty) return Text("No data");

            return Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: dataList.length,
                itemBuilder: (context, index){
                  final item = dataList[index];
                  return Row(
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
                              // mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'images/handhaus_logo.png',
                                  width: 150,
                                  height: 150,
                                ),
                                Text(
                                  item['name'], 
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  item['description'],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: (){
                                      addOrder(item['id']);
                                    }, 
                                    child: Text("Add to Cart")
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
            }
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Row(
          //     children: [
          //       Text(
          //         "Jewelery:", 
          //         style: TextStyle(
          //           fontWeight: FontWeight.bold, 
          //           fontSize: 15
          //         )
          //       ),
          //     ],
          //   ),
          // ),
          // FutureBuilder(
          //   future: jewelery,
          //   builder: (context, snapshot) {
          //     if(snapshot.connectionState == ConnectionState.waiting){
          //     return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(248, 243, 236, 1)));
          //   }
          //   if(!snapshot.hasData){
          //     print(snapshot);
          //     return Text("No categories found");
          //   }
          //   final response = snapshot.data!;
          //   final List dataList = response["Data"] ?? [];
          //   if(dataList.isEmpty) return Text("No data");

          //   return Expanded(
          //     child: ListView.builder(
          //       scrollDirection: Axis.horizontal,
          //       itemCount: dataList.length,
          //       itemBuilder: (context, index){
          //         final item = dataList[index];
          //         return Card(
          //           elevation: 5,
          //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //           margin: EdgeInsets.all(10),
          //           child: SizedBox(
          //             width: 300,
          //             height: 300,
          //             child: Padding(
          //               padding: const EdgeInsets.all(8.0),
          //               child: Column(
          //                 children: [
          //                   Image.asset(
          //                     'images/handhaus_logo.png',
          //                     width: 150,
          //                     height: 150,
          //                   ),
          //                   Text(
          //                     item['name'], 
          //                     style: TextStyle(fontWeight: FontWeight.bold),
          //                   ),
          //                   Text(
          //                     item['description'],
          //                   ),
                            // Align(
                            //   alignment: Alignment.centerRight,
                            //   child: ElevatedButton(
                            //     onPressed: (){}, 
                            //     child: Text("Add to Cart")
                            //   ),
                            // )
          //                 ],
          //               ),
          //             ),
          //           )
          //         );
          //       },
          //     ),
          //   );
          //   }
          // ),
          
        ],
      ),
      
    );
  }
}