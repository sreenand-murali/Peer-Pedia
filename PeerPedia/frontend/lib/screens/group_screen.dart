import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/widgets/sub_input_modal.dart';
import 'package:frontend/widgets/subj_update_modal.dart';
import 'package:frontend/widgets/subject_list.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupScreen extends StatefulWidget {
  const GroupScreen({required this.group, super.key});

  final GroupModel group;

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {


  void openSubInput() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => SubInputModal(
              addSub: addSub,
              group: widget.group,
            ));
  }

  void addSub(SubjectModel sub) {
    setState(() {
      widget.group.subjects.add(sub);
    });
  }
void subDelFun(String subName){
  setState(() {
    widget.group.subjects.removeWhere((sub) => sub.name.toLowerCase() == subName.toLowerCase());
  });
}


  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.group.name,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
       
          IconButton(
            onPressed: () {
              showModalBottomSheet(context: context, builder: (context) => SubjUpdateModal(delFun: subDelFun, group: widget.group,));
            },
            icon: const Icon(Icons.delete_outlined),
          ),
        ],
      ),
       
          body: SubList(group: widget.group),


      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 158, 185, 247),
        onPressed: openSubInput,
        child: const Icon(Icons.add),
      ),
    );
  }
}
