import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/providers/user_provider.dart';

import 'package:http/http.dart' as http;

class MatUpdateModal extends ConsumerStatefulWidget {
  const MatUpdateModal({required this.delFun, required this.group, required this.matType, required this.sub, super.key});
  final Function(String) delFun;
  final GroupModel group;
  final SubjectModel sub;
  final String matType;
  @override
  ConsumerState<MatUpdateModal> createState() => _MatUpdateModalState();
}

class _MatUpdateModalState extends ConsumerState<MatUpdateModal> {
  final _formKey = GlobalKey<FormState>();
  String _matName = '';
  String _message = "";
  Uri url = Uri.http("192.168.165.50:3000", "group/deleteNote");
  Uri url2 = Uri.http("192.168.165.50:3000", "group/deleteQp");

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Material Name"),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter some name";
                } else {
                  return null;
                }
              },
              onSaved: (newValue) {
                _matName = newValue!;
              },
            ),
            const SizedBox(height: 10),
            Text(
              _message,
              style: TextStyle(color: Color.fromARGB(255, 150, 3, 40)),
            ),
            ElevatedButton(
              onPressed: () async {
               
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                   var response;
                   if(widget.matType == "note"){
                    response = await http.post(url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode({
                          "groupName": widget.group.name,
                          "username": ref.watch(userProvider).username,
                          "subName": widget.sub.name,
                          "noteName": _matName,
                        }));
                   }else{
                    response = await http.post(url2,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode({
                          "groupName": widget.group.name,
                          "username": ref.watch(userProvider).username,
                          "subName": widget.sub.name,
                          "qpName": _matName,
                        }));
                   }
                      
                    if (json.decode(response.body)["success"] == false) {
                      setState(() {
                        _message = json.decode(response.body)["message"];
                      });
                    } else {
                      widget.delFun(_matName);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  } catch (e) {
                    print("error occured while posting subject: $e ");
                  }
                }
              },
              child: const Text("delete"),
            ),
          ],
        ),
      ),
    );
  }
}
