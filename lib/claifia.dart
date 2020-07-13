import 'dart:convert';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Clarifia extends StatefulWidget {
  @override
  _ClarifiaState createState() => _ClarifiaState();
}

class _ClarifiaState extends State<Clarifia> {

  var age = [];
  var gender = [];
  var race = [];
  var result;
  bool isloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ethnicity and Gender Predictor'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              postImage == null ? Container(
                margin: EdgeInsets.all(10),
                height: MediaQuery.of(context).size.height/2,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(border: Border.all(style:BorderStyle.solid)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(icon:Icon(Icons.linked_camera), onPressed:() => uploadPic(),),
                    Text("Choose Image")
                  ],
                ),
              ) : 
              Column(
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    height: MediaQuery.of(context).size.height/2,
                    width: MediaQuery.of(context).size.width,
                    child: Image.file(postImage, fit: BoxFit.cover),
                  ),
                  // SizedBox(height: 10,),
                  InkWell(
                      onTap:() => uploadPic(),
                      child: Container(
                      margin: EdgeInsets.all(30),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      width: MediaQuery.of(context).size.width/2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(style:BorderStyle.solid, color: Colors.blue)
                      ),
                      child: Text("Add Picture"),
                    ),
                  )

                ],
              ),
              SizedBox(
                height: 20,
              ),
              result != null && age.length > 0 && gender.length > 0 && race.length > 0 
                  ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal:20.0),
                    child: Text(
                'gender - ${gender[0]} \nrace - ${race[0]}' ,
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    background: Paint()..color = Colors.white,
                ),
              ),
                  )
              : isloading ? Container(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              ): Container()
            ],
          ),
      ),
       ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () =>uploadPic(),
      //   child: Icon(Icons.image),
      // ),
    );
  }

File postImage;
String imgUrl;

Future uploadPic() async {
      setState(() {
        isloading = true;
      });
      var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
      setState(() {
        postImage = tempImage;
        age = [];
        gender = [];
        race = [];
      });

      var timeKey = DateTime.now();

      if (postImage != null){
        final StorageReference postImageRef = FirebaseStorage.instance.ref().child('Post Images');

        

        final StorageUploadTask uploadTask = postImageRef.child(timeKey.toString() + '.jpg').putFile(postImage);

        var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();


        imgUrl  = imageUrl.toString();

      
      getResult(imgUrl);
    // return location;
   }
}

Future getResult(String imgpath) async{
   http.Response response = await http.post(
      Uri.encodeFull('https://api.clarifai.com/v2/models/c0c0ac362b03416da06ab3fa36fb58e3/outputs'),
      headers: {
         "Content-type": "application/json",
         "Authorization": "Key 1e33d24da2d1450eaf37ce99907cf9cc" 
      },
      body:json.encode({
      "inputs": [
        {
          "data": {
            "image": {'url': imgUrl}
          }
        }
      ]
    })
    
   );
   var resObj = json.decode(response.body);
   var arr = resObj['outputs'][0]['data']['regions'][0]['data']['concepts'];
   
   arr.forEach((elem){
     if (elem['vocab_id'] == 'age_appearance'){
       setState(() {
         age.add(elem['name']);
       });
       
     }
     if (elem['vocab_id'] == 'gender_appearance'){
       setState(() {
         gender.add(elem['name']);
       });
       
     }
     if (elem['vocab_id'] == 'multicultural_appearance'){
       setState(() {
         race.add(elem['name']);
       });
       
     }
   });
   
   print(age[0]);
   print(gender[0]);
   print(race[0]);
   setState(() {
     result = arr;
   });
 }

}
