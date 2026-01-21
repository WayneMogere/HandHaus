import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:hand_haus_mobile/Auth/login.dart';
import 'package:hand_haus_mobile/Views/clothes.dart';
import 'package:hand_haus_mobile/Views/item.dart';
import 'package:hand_haus_mobile/Views/jewelery.dart';
import 'package:hand_haus_mobile/Views/order.dart';
import 'package:hand_haus_mobile/Views/orders.dart';
import 'package:hand_haus_mobile/Views/profile.dart';
import 'package:hand_haus_mobile/Views/user.dart';
import 'package:hand_haus_mobile/Views/woodcrafts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final baseUrl = Uri.parse("http://192.168.0.109:8000/api"); 

  Future<Map>? categories;
  Future<Map>? items;
  File? pickedImage;
  String? _category;

  final TextEditingController imageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  
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
  String role = '';
  void loadRole() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role')??'';
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

  Future<Map> getItems() async{
    final itemsUrl = Uri.parse("$baseUrl/getItem");
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

  Future<void> updateItem(int item_id) async{
    if (pickedImage == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please select an image")));
      return;
    }
    File? originalImage = pickedImage;

    final dir = await getTemporaryDirectory();
    String targetPath =
        "${dir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg";

    XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
      originalImage!.path,
      targetPath,
      quality: 60,
    );
    final token = await getToken();
    final request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/updateItem/$item_id"),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';


    request.files.add(
      await http.MultipartFile.fromPath('image', compressedImage!.path),
    );
    request.fields['name'] = nameController.text;
    request.fields['price'] = priceController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['category_id'] = _category ?? '';

    final response = await request.send();
    final responseStream = await response.stream.bytesToString();
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item updated Successfully")));
      refreshData();
      Navigator.of(context).pop();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to update Item. $responseStream")));
    }

  }

  Future<void> deleteItem(int item_id) async{
    final deleteUrl = Uri.parse("$baseUrl/deleteItem/$item_id");
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

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        pickedImage = File(picked.path);
      });
    }
  }

  ImageProvider getImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return AssetImage('assets/placeholder.png');
    } else if (path.startsWith('http')) {
      return NetworkImage(path);
    } else {
      return FileImage(File(path));
    }
  }

  void refreshData(){
    setState(() {
      categories = fetchData();
      loadName();
      loadRole();
      items = getItems();
    });
  }

  void initState(){
    super.initState();
    categories = fetchData();
    loadName();
    loadRole();
    items = getItems();
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
          FutureBuilder(
            future: items,
            builder: (context, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(backgroundColor: Color.fromRGBO(248, 243, 236, 1)));
            }
            if(!snapshot.hasData){
              print(snapshot);
              return Text("No categories found");
            }
            final response = snapshot.data!;
            final List dataList = response["Item"] ?? [];
            if(dataList.isEmpty) return Text("No data");

            return Expanded(
              child: ListView.builder(
                // scrollDirection: Axis.horizontal,
                itemCount: dataList.length,
                itemBuilder: (context, index){
                  final item = dataList[index];
                  final imageUrl = "http://192.168.0.109:8000/storage/${item['image']}";
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
                              children: [
                                Image.network(
                                  imageUrl,
                                  height: 120,
                                  width: 120,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error_outline);
                                  },
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
                                  child: Column(
                                    children: [
                                      if(role == 'Customer')
                                        ElevatedButton(
                                          onPressed: (){
                                            addOrder(item['id']);
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
                                                      child: Column(
                                                        children: [
                                                          ElevatedButton.icon(
                                                            onPressed: pickImage,
                                                            icon: Icon(Icons.image),
                                                            label: Text("Select Image"),
                                                          ),

                                                          SizedBox(height: 10),

                                                          pickedImage == null
                                                              ? Text("No image selected")
                                                              : Image.file(
                                                                  pickedImage!,
                                                                  height: 120,
                                                                ),
                                                        ],
                                                      ),
                                                    ),
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
                                                        controller: priceController,
                                                        decoration: InputDecoration(
                                                          label: Text("Price"),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                          prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: TextFormField(
                                                        controller: descriptionController,
                                                        decoration: InputDecoration(
                                                          label: Text("Description"),
                                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                                          prefixIcon: Icon(Icons.image_outlined, color: Color.fromRGBO(173, 159, 141, 1),)
                                                        ),
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
                                                              updateItem(item['id']);
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
                                      if(role == 'Staff'||role == 'Administrator')
                                        ElevatedButton(
                                          onPressed: (){
                                            deleteItem(item['id']);
                                          }, 
                                          child: Text("Delete Item", style: TextStyle(color: Colors.red),)
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
            }
          ),
        ],
      ),
      
    );
  }
}