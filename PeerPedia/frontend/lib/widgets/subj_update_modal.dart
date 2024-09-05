import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/providers/user_provider.dart';

import 'package:http/http.dart' as http;

class SubjUpdateModal extends ConsumerStatefulWidget {
  const SubjUpdateModal({required this.delFun, required this.group, super.key});
  final Function(String) delFun;
  final GroupModel group;
  @override
  ConsumerState<SubjUpdateModal> createState() => _SubjUpdateModalState();
}

class _SubjUpdateModalState extends ConsumerState<SubjUpdateModal> {
  final _formKey = GlobalKey<FormState>();
  String _subName = '';
  String _message = "";
  Uri url = Uri.http("192.168.165.50:3000", "group/deleteSub");

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
                label: Text("Subject Name"),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter some name";
                } else {
                  return null;
                }
              },
              onSaved: (newValue) {
                _subName = newValue!;
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
                    final response = await http.post(url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode({
                          "groupName": widget.group.name,
                          "username": ref.watch(userProvider).username,
                          "subName": _subName,
                        }));
                    if (json.decode(response.body)["success"] == false) {
                      setState(() {
                        _message = json.decode(response.body)["message"];
                      });
                    } else {
                      widget.delFun(_subName);
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
