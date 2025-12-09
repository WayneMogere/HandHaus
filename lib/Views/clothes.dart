import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Clothes extends StatefulWidget {
  const Clothes({super.key});

  @override
  State<Clothes> createState() => _ClothesState();
}

class _ClothesState extends State<Clothes> {
  final baseUrl = Uri.parse("http://192.168.0.104:8000/api");

  Future<Map>? clothes;
  int? user_id;

  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  Future<int?> getUserId() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
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
    clothes = getClothes();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Clothes:")),
      body: Column(
        children: [
          FutureBuilder(
            future: clothes,
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
                itemCount: dataList.length,
                itemBuilder: (context, index){
                  final item = dataList[index];
                  return Row(
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
        ],
      ),
    );
  }
}