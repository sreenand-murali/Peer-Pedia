import 'package:flutter/material.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/screens/subject_screen.dart';
import 'package:google_fonts/google_fonts.dart';



class SubList extends StatefulWidget {
  const SubList({required this.group, super.key});

  final GroupModel group;
  @override
  State<SubList> createState() => _SubListState();
}

class _SubListState extends State<SubList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.group.subjects.length,
      itemBuilder: (ctx, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(30)),
        clipBehavior: Clip.hardEdge,
        child: Card(
          elevation: 0,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => SubjectScreen(
                    group: widget.group,
                    subject: widget.group.subjects[index],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(widget.group.subjects[index].name,
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.bold,
                    fontSize: 16
                  )),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
