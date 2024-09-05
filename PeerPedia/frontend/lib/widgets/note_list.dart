import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/NotesModel.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/pdf_reader_screen.dart';
import 'package:frontend/widgets/comment_modal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class NoteList extends ConsumerStatefulWidget {
  const NoteList(
      {required this.noteList,
      required this.group,
      required this.subject,
      super.key});

  final List<NotesModel> noteList;
  final GroupModel group;
  final SubjectModel subject;

  @override
  ConsumerState<NoteList> createState() => _NoteListState();
}

class _NoteListState extends ConsumerState<NoteList> {
  Uri url = Uri.http("192.168.165.50:3000", "group/like");

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return ListView.builder(
      itemCount: widget.noteList.length,
      itemBuilder: (ctx, index) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
        child: Card(
          elevation: 0,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => PdfReaderScreen(
                    matName: widget.noteList[index].name,
                    link: widget.noteList[index].link,
                    subject: widget.subject,
                    group: widget.group,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.noteList[index].name,
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),),
                  const SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        elevation: 0
                      ),
                          onPressed: () async {
                            try {
                              final response = await http.post(url,
                                  headers: {"Content-Type": "application/json"},
                                  body: json.encode({
                                    "groupName": widget.group.name,
                                    "subName": widget.subject.name,
                                    "materialName": widget.noteList[index].name,
                                    "username": user.username,
                                    "matType": "notes",
                                  }));
                              if (json.decode(response.body)["success"] ==
                                  true) {
                                print("sucess uploading like");
                              } else if (json
                                      .decode(response.body)["success"] ==
                                  false) {
                                print("failed uploading like");
                              }
                            } catch (e) {
                              print("error occured while posting like: $e ");
                            }
                            setState(() {
                              if (widget.noteList[index].likedUsers
                                  .contains(user.username)) {
                                widget.noteList[index].likedUsers
                                    .remove(user.username);
                              } else {
                                widget.noteList[index].likedUsers
                                    .add(user.username);
                              }
                            });
                          },
                          icon: Icon(
                            widget.noteList[index].likedUsers
                                    .contains(user.username)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Color.fromARGB(255, 8, 65, 189),
                          ),
                          label: Text(widget.noteList[index].likedUsers.length
                              .toString())),
                      IconButton(
                        onPressed: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (ctx) => CommentModal(
                                    group: widget.group,
                                    matName: widget.noteList[index].name,
                                    matType: "notes",
                                    subject: widget.subject,
                                    pageNo: -1,
                                  ));
                        },
                        icon: const Icon(
                          Icons.comment,
                          color: Color.fromARGB(255, 29, 86, 207),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
