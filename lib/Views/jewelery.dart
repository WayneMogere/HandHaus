import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Jewelery extends StatefulWidget {
  const Jewelery({super.key});

  @override
  State<Jewelery> createState() => _JeweleryState();
}

class _JeweleryState extends State<Jewelery> {
  final baseUrl = Uri.parse("http://192.168.0.109:8000/api");

  Future<Map>? jewelery;
  int? user_id;
  File? pickedImage;

  final TextEditingController imageController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<String?> getToken() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
  Future<int?> getUserId() async{
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('id');
  }
  String role = '';
  void loadRole() async{
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      role = prefs.getString('role')??'';
    });
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

  Future<void> addItem() async{
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
      Uri.parse("$baseUrl/saveItem"),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';


    request.files.add(
      await http.MultipartFile.fromPath('image', compressedImage!.path),
    );
    request.fields['name'] = nameController.text;
    request.fields['price'] = priceController.text;
    request.fields['description'] = descriptionController.text;
    request.fields['category_id'] = '2';

    final response = await request.send();
    final responseStream = await response.stream.bytesToString();
    if(response.statusCode == 200){
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Item added Successfully")));
      refreshData();
      Navigator.of(context).pop();
    }else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to add Item. $responseStream")));
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
    request.fields['category_id'] = '2';

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
    jewelery = getJewelery();
    loadRole();
    });
  }

  void initState(){
    super.initState();
    jewelery = getJewelery();
    loadRole();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Jewelery:")),
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
                        title: Text("Add Item"),
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
                                    addItem();
                                  }, 
                                  child: Text("Add Item")
                                ),
                              ),
                            ],
                          )
                        ],
                      );
                    }
                  );
                }, 
                child: Text("Add Item")
              ),
            ),
          FutureBuilder(
            future: jewelery,
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
                  final imageUrl = "http://192.168.0.109:8000/storage/${item['image']}";
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
                              children: [
                                Image.network(
                                  imageUrl,
                                  height: 120,
                                  width: 150,
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