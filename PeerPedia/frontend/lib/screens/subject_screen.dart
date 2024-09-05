import 'package:flutter/material.dart';
import 'package:frontend/models/QuestionPaperModel.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/NotesModel.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/widgets/mat_update_screen.dart';
import 'package:frontend/widgets/material_input_modal.dart';
import 'package:frontend/widgets/note_list.dart';
import 'package:frontend/widgets/qp_list.dart';
import 'package:google_fonts/google_fonts.dart';

class SubjectScreen extends StatefulWidget {
  const SubjectScreen({required this.group, required this.subject, super.key});

  final GroupModel group;
  final SubjectModel subject;

  @override
  State<SubjectScreen> createState() => _SubjectScreenState();
}

class _SubjectScreenState extends State<SubjectScreen> {
  int _selectedScreen = 0;
  List<QuestionPaperModel> qp = [];
  List<NotesModel> note = [];

  void openSubInput() {
    showModalBottomSheet(
        context: context,
        builder: (ctx) => MaterialInputModal(
              addMaterial: addMaterial,
              group: widget.group,
              subject: widget.subject,
            ));
  }

  void addMaterial(mat, String matType) {
    setState(() {
      if (matType == "note") {
        note.add(mat);
      } else if (matType == "qpak") {
        qp.add(mat);
      }
    });
  }

void matDelFun(String matName){
  setState(() {
    widget.subject.notes.removeWhere((note) => note.name.toLowerCase() == matName.toLowerCase());
    widget.subject.questionPapers.removeWhere((qp) => qp.name.toLowerCase() == matName.toLowerCase());
  });
}


  @override
  void initState() {
    qp = widget.subject.questionPapers;
    print(qp);
    note = widget.subject.notes;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subject.name,
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(onPressed: () {
            if(_selectedScreen == 0){
              showModalBottomSheet(context: context, builder: (context) => MatUpdateModal(delFun: matDelFun, group: widget.group, sub: widget.subject, matType: "note",));

            }else{
              showModalBottomSheet(context: context, builder: (context) => MatUpdateModal(delFun: matDelFun, group: widget.group, sub: widget.subject, matType: "qp",));

            }

          }, icon: const Icon(Icons.delete_outlined)),
        ],
      ),
      body: _selectedScreen == 0
          ? NoteList(
              noteList: note, group: widget.group, subject: widget.subject)
          : QpList(
              qpList: qp, group: widget.group, subject: widget.subject),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.note,
                color: Color.fromARGB(255, 61, 33, 240),
              ),
              label: "Notes"),
          BottomNavigationBarItem(
              icon: Icon(Icons.not_listed_location), label: "QP&AK"),
        ],
        currentIndex: _selectedScreen,
        onTap: (index) {
          setState(() {
            _selectedScreen = index;
          });
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 76, 131, 250),
        onPressed: openSubInput,
        child: const Icon(Icons.add),
      ),
    );
  }
}
