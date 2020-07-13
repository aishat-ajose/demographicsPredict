import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:topic_classification/result.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController _controller = TextEditingController();
  Future<Result> classification ;

  Future<Result> getData(String text) async{
    http.Response response = await http.post(
      Uri.encodeFull('http://api.datumbox.com/1.0/TopicClassification.json'),
      headers: {
        'Accept': 'application/json'
      },
      body: {
        'text': text,
        'api_key': 'd185c5a036ac42eddd565728e9ce1743',
      }
    );

    if (response.statusCode == 200) {
      return Result.fromJson(json.decode(response.body)['output']);
      } 
    else {
      throw Exception('Failed to load response');
    } 
  }

 Future getResult() async{
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
            "image": {"url": "https://samples.clarifai.com/demographics.jpg"}
          }
        }
      ]
    })
    
   );
   var resObj = json.decode(response.body);
    var arr = resObj['outputs'][0]['data'];
    print(arr);
 }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container( 
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8.0),
        child: (classification == null)
          ? Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(hintText: 'Enter Text'),
              ),
            ),
            RaisedButton(
              child: Text('Create Data'),
              onPressed: () {
                setState(() {
                  classification =  getData(_controller.text);
                  
                });
              },
            ),
          ],
        ):
        FutureBuilder<Result>(
          future: classification,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data.classification);
            } else if (snapshot.hasError) {
              return Text("${snapshot.error}");
            }

            return CircularProgressIndicator();
          },
        ))
      
      // body:Center(
      //   child: RaisedButton(
      //     child: Text('Create Data'),
      //     onPressed: () {
      //       getResult();
      //     }
      //   ),
      // )
    );
  }
}