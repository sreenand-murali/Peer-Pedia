import 'package:flutter/material.dart';
import 'package:frontend/models/group_model.dart';

class GroupInputModal extends StatefulWidget {
  const GroupInputModal({required this.addGroupFun, super.key});

  final void Function(GroupModel) addGroupFun;

  @override
  State<GroupInputModal> createState() => _GroupInputModalState();
}

class _GroupInputModalState extends State<GroupInputModal> {
  final _formKey = GlobalKey<FormState>();
  String _groupName = '';
  String _groupDesc = '';

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
                label: Text("Hub Name"),
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
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Hub Description"),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Enter some Description";
                } else {
                  return null;
                }
              },
              onSaved: (newValue) {
                _groupDesc = newValue!;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  widget.addGroupFun(
                    GroupModel(name: _groupName, desc: _groupDesc),
                  );
                  Navigator.of(context).pop();
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
