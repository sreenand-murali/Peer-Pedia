import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;

class SubInputModal extends ConsumerStatefulWidget {
  const SubInputModal({required this.addSub, required this.group, super.key});

  final Function(SubjectModel) addSub;
  final GroupModel group;
  @override
  ConsumerState<SubInputModal> createState() => _SubInputModalState();
}

class _SubInputModalState extends ConsumerState<SubInputModal> {
  final _formKey = GlobalKey<FormState>();
  String _subName = '';
  Uri url = Uri.http("192.168.165.50:3000", "group/addSub");

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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  try {
                    final response = await http.post(url,
                        headers: {"Content-Type": "application/json"},
                        body: json.encode({
                          "groupName": widget.group.name,
                          "admin": ref.watch(userProvider).username,
                          "subject": {
                            "name": _subName,
                          },
                        }));
                  } catch (e) {
                    print("error occured while posting subject: $e ");
                  }
                  widget.addSub(
                    SubjectModel(name: _subName),
                  );
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }

              },
              child: const Text("submit"),
            ),
          ],
        ),
      ),
    );
  }
}
