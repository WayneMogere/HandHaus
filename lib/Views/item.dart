import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hand_haus_mobile/Views/home_page.dart';
import 'package:hand_haus_mobile/Views/order.dart';
import 'package:hand_haus_mobile/Views/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Item extends StatefulWidget {
  const Item({super.key});

  @override
  State<Item> createState() => _ItemState();
}

class _ItemState extends State<Item> {
  final baseUrl = Uri.parse("http://192.168.100.47:8000/api"); 

  Future<Map>? items;
  
  Future<String?> getUserName() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('name');
  }
  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }


  Future<Map> fetchData() async{
    final fetchUrl = Uri.parse("$baseUrl/getItem");
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
      print("Item fetched Successfully");
    }else{
      throw Exception("Failed to fetch Item");
    }

    return responseData;
  }

  void initState(){
    super.initState();
    items = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(173, 159, 141, 1),
        items: [
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => HomePage())
                );
              }, 
              icon: Icon(Icons.home)
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
              icon: Icon(Icons.menu_outlined)
            ), 
            label: "Items"
          ),
          BottomNavigationBarItem(
            icon: IconButton(
              onPressed: (){
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => Order())
                );
              },
              icon: Icon(Icons.shopping_bag_outlined)
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
              icon: Icon(Icons.account_circle_outlined)
            ), 
            label: "Profile"
          ),
        ]
      ),
      appBar: AppBar(backgroundColor: Color.fromRGBO(173, 159, 141, 1), title: Text("Items Page"),),
      drawer: Drawer(
        backgroundColor: Color.fromRGBO(248, 243, 236, 1),
        child: ListView(
          padding: EdgeInsets.all(10),
          children: [
            SizedBox(height: 40,),
            ListTile(
              title: Text("data"),
            )
          ],
        ),
      ),
      body: Column(
        children: [
          FutureBuilder<Map>(future: items, builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(248, 243, 236, 1)));
            }
            if(!snapshot.hasData){
              print(snapshot);
              return Text("No Items found");
            }
            final response = snapshot.data!;
            final List dataList = response["Item"] ?? [];
            if(dataList.isEmpty) return Text("No data");

            return Expanded(
              child: ListView.builder(
                itemCount: dataList.length,
                itemBuilder: (context, index){
                  final item = dataList[index];
                  return ListTile(
                    title: Text(item['name']),
                    subtitle: Text(item['description']),
                    trailing: ElevatedButton(
                      onPressed: (){}, 
                      child: Icon(Icons.delete, color: Colors.red,)
                    ),
                  );
                },
              ),
            );
          })
        ],
      )
    );
  }
}