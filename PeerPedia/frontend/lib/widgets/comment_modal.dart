import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;

class CommentModal extends ConsumerStatefulWidget {
  const CommentModal(
      {required this.matName,
      required this.matType,
      required this.group,
      required this.subject,
      required this.pageNo,
      super.key});

  final String matName;
  final String matType;
  final GroupModel group;
  final SubjectModel subject;
  final pageNo;

  // final void Function(GroupModel) addGroupFun;

  @override
  ConsumerState<CommentModal> createState() => _CommentModalState();
}

class _CommentModalState extends ConsumerState<CommentModal> {
  Uri url = Uri.http("192.168.165.50:3000", "group/comment");
  Uri url2 = Uri.http("192.168.165.50:3000", "group/getComment");
  final _formKey = GlobalKey<FormState>();
  String _comment = '';
  List commentsFetched = [];

  void fetchComment() async {
    try {
      
      final response = await http.post(url2,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "groupName": widget.group.name,
            "subName": widget.subject.name,
            "materialName": widget.matName,
            "materialType": widget.matType,
            "pageNo": widget.pageNo,
          }));
      setState(() {
        commentsFetched = json.decode(response.body)["comments"];
      });
    } catch (e) {
      print("error occured while fetching comment: $e ");
    }
  }

  @override
  void initState() {
    fetchComment();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: commentsFetched.length,
                itemBuilder: (context, index) => Card(
                  elevation: 0,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          commentsFetched[index]["username"],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Text("  :  "),
                        Text(commentsFetched[index]["comment"]),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Type your Comment"),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter some comment";
                } else {
                  return null;
                }
              },
              onSaved: (newValue) {
                _comment = newValue!;
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
                          "subName": widget.subject.name,
                          "materialName": widget.matName,
                          "materialType": widget.matType,
                          "username": ref.watch(userProvider).username,
                          "comment": _comment,
                          "pageNo": widget.pageNo,
                        }));
                    if (json.decode(response.body)["success"] == true) {
                      print("sucess uploading comment");
                    } else if (json.decode(response.body)["success"] == false) {
                      print("failed uploading comment");
                    }
                    setState(() {
                      commentsFetched.add({
                        "username": ref.watch(userProvider).username,
                        "comment": _comment
                      });
                    });
                  } catch (e) {
                    print("error occured while uploading comment: $e ");
                  }
                }

                // Navigator.of(context).pop();
              },
              child: const Text("submit"),
            ),
          ],
        ),
      ),
    );
  }
}
