import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/providers/user_provider.dart';

import 'package:http/http.dart' as http;

class GroupNameChangeModal extends ConsumerStatefulWidget {
  const GroupNameChangeModal({required this.updateFun, super.key});
  final Function(String, String, String) updateFun;
  @override
  ConsumerState<GroupNameChangeModal> createState() => _GroupNameChangeModalState();
}

class _GroupNameChangeModalState extends ConsumerState<GroupNameChangeModal> {
  final _formKey = GlobalKey<FormState>();
  String _groupName = '';
  String _newGroupName = '';
  String _newDescription = '';
  String _message = "";
  Uri url = Uri.http("192.168.165.50:3000", "group/update");

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
                label: Text("Group Name"),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter some name";
                } else {
                  return null;
                }
              },
              onSaved: (newValue) {
                _groupName = newValue!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("New Group Name"),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter some name";
                } else {
                  return null;
                }
              },
              onSaved: (newValue) {
                _newGroupName = newValue!;
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("New Description"),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter some description";
                } else {
                  return null;
                }
              },
              onSaved: (newValue) {
                _newDescription = newValue!;
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
                          "name": _groupName,
                          "newGroupName": _newGroupName,
                          "newDescription": _newDescription,
                          "username": ref.watch(userProvider).username,
                        }));
                    if (json.decode(response.body)["success"] == false) {
                      setState(() {
                        _message = json.decode(response.body)["message"];
                      });
                    } else {
                      widget.updateFun(_groupName, _newGroupName, _newDescription);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  } catch (e) {
                    print("error occured while updating group name: $e ");
                  }
                }
              },
              child: const Text("update"),
            ),
          ],
        ),
      ),
    );
  }
}
