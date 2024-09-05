import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/NotesModel.dart';
import 'package:frontend/models/QuestionPaperModel.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';

UploadTask? uploadTask;
UploadTask? uploadTask2;

class MaterialInputModal extends ConsumerStatefulWidget {
  const MaterialInputModal(
      {required this.addMaterial,
      required this.group,
      required this.subject,
      super.key});

  final Function(dynamic, String) addMaterial;
  final SubjectModel subject;
  final GroupModel group;
  @override
  ConsumerState<MaterialInputModal> createState() => _MaterialInputModalState();
}

class _MaterialInputModalState extends ConsumerState<MaterialInputModal> {
  final _formKey = GlobalKey<FormState>();
  String _materialName = '';
  String _materialType = "note";
  PlatformFile? pickedFile;
  PlatformFile? pickedFile2;
  Uri url = Uri.http("192.168.165.50:3000", "group/addMat");
  String? urlDownload;
  String? urlDownload2;
  bool uploading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
              if (pickedFile != null && _materialType == "note") Text(pickedFile!.name),
            if (_materialType == "note")
            ElevatedButton(
              onPressed: () async {
                final result = await FilePicker.platform.pickFiles();
                if (result == null) {
                  return;
                }
                setState(() {
                  pickedFile = result.files.first;
                });
              },
              child: const Text("Chose Note File"),
            ),
            if (_materialType == "qpak")
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (pickedFile != null) Text(pickedFile!.name),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result == null) {
                        return;
                      }
                      setState(() {
                        pickedFile = result.files.first;
                      });
                    },
                    child: const Text("Choose Question Paper File"),
                  ),
                  if (pickedFile2 != null) Text(pickedFile2!.name),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await FilePicker.platform.pickFiles();
                      if (result == null) {
                        return;
                      }
                      setState(() {
                        pickedFile2 = result.files.first;
                      });
                    },
                    child: const Text("Chose Answer Key File"),
                  ),
                ],
              ),
            buildProgress(),
            if(_materialType == "qpak") buildProgress2(),
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
                _materialName = newValue!;
              },
            ),
            DropdownButton(
                value: _materialType,
                items: const [
                  DropdownMenuItem(
                    value: "note",
                    child: Text("Note"),
                  ),
                  DropdownMenuItem(
                    value: "qpak",
                    child: Text("Qp/AK"),
                  )
                ],
                onChanged: (selectedMat) {
                  setState(() {
                    _materialType = selectedMat!;
                  });
                }),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                var file2;
                var path2;
                var reference2;
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();

                  final path = 'files/${pickedFile!.name}';
                  final file = File(pickedFile!.path!);
                  final reference = FirebaseStorage.instance.ref().child(path);
                  if (_materialType == "qpak") {
                     path2 = 'files/${pickedFile!.name}';
                     file2 = File(pickedFile!.path!);
                     reference2 =
                        FirebaseStorage.instance.ref().child(path2);
                  }
                  try {
                    setState(() {
                      uploadTask = reference.putFile(file);
                    });
                    
                    final snapshot = await uploadTask!.whenComplete(() {});

                    urlDownload = await snapshot.ref.getDownloadURL();
                    if (_materialType == "qpak") {
                      setState(() {
                        uploadTask2 = reference2.putFile(file2);
                      });

                      final snapshot2 = await uploadTask2!.whenComplete(() {});

                      urlDownload2 = await snapshot2.ref.getDownloadURL();
                    }
                    try {
                      var response;
                      if(_materialType == "note"){
                        response = await http.post(url,
                          headers: {"Content-Type": "application/json"},
                          body: json.encode({
                            "groupName": widget.group.name,
                            "subName": widget.subject.name,
                            "materialName": _materialName,
                            "admin": ref.watch(userProvider).username,
                            "materialType": _materialType,
                            "link": urlDownload,
                            "link2": "",
                          }));
                      }else{
                        response = await http.post(url,
                          headers: {"Content-Type": "application/json"},
                          body: json.encode({
                            "groupName": widget.group.name,
                            "subName": widget.subject.name,
                            "materialName": _materialName,
                            "admin": ref.watch(userProvider).username,
                            "materialType": _materialType,
                            "link": urlDownload,
                            "link2": urlDownload2,
                          }));
                      }
                      if (json.decode(response.body)["success"] == true) {
                        print("sucess uploading material");
                      } else if (json.decode(response.body)["success"] ==
                          false) {
                        print("failed uploading material");
                      }
                    } catch (e) {
                      print("error occured while posting subject: $e ");
                    }
                    if (urlDownload == null) {
                      return;
                    }
                    if(_materialType=="note"){

                    widget.addMaterial(
                      NotesModel(
                        name: _materialName,
                        link: urlDownload!,
                      ),
                      "note",
                    );
                    }else{
                      
                    widget.addMaterial(
                      QuestionPaperModel(
                        name: _materialName,
                        link1: urlDownload!,
                        link2: urlDownload2!
                      ),
                      "qpak",
                    );
                    }
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } catch (e) {
                    print("error roocured on uploading: $e");
                    print(e);
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

Widget buildProgress() => StreamBuilder<TaskSnapshot>(
    stream: uploadTask?.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.data!;
        double progress = data.bytesTransferred / data.totalBytes;
        return Text("${(progress * 100).round().toString()}%");
      } else {
        return const Text("");
      }
    });

Widget buildProgress2() => StreamBuilder<TaskSnapshot>(
    stream: uploadTask2?.snapshotEvents,
    builder: (context, snapshot) {
      if (snapshot.hasData) {
        final data = snapshot.data!;
        double progress = data.bytesTransferred / data.totalBytes;
        return Text("${(progress * 100).round().toString()}%");
      } else {
        return const Text("");
      }
    });
