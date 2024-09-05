import 'package:flutter/material.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/widgets/comment_modal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AkReaderScreen extends StatefulWidget {
  const AkReaderScreen(
      {required this.subject,
      required this.group,
      required this.matName,
      required this.link1,
      required this.link2,
      required this.scrOff,
      super.key});

  final String matName;
  final String link1;
  final String link2;
  final Offset scrOff;
  final GroupModel group;
  final SubjectModel subject;

  @override
  State<AkReaderScreen> createState() => _AkReaderScreenState();
}

class _AkReaderScreenState extends State<AkReaderScreen> {
  final matController = PdfViewerController();
  final _pdfViewerKey = GlobalKey<SfPdfViewerState>();
  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "${widget.matName} Answer Key",
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (ctx) => CommentModal(
                            group: widget.group,
                            matName: widget.matName,
                            matType: "ak",
                            subject: widget.subject,
                            pageNo: matController.pageNumber,
                          ));
                },
                icon: const Icon(
                  Icons.comment,
                  color: Color.fromARGB(255, 24, 118, 185),
                ))
          ],
        ),
        body: 
        WillPopScope(
        onWillPop: () async {
          // Custom code you want to execute before popping the route
 
          // Return true to allow popping the route, return false to prevent it
          Navigator.of(context).pop(
            matController.scrollOffset,
          );
            return false;
        },
        child:
            SfPdfViewer.network(
      widget.link2,
      controller: matController,
      key: _pdfViewerKey,
      initialScrollOffset: widget.scrOff,
    ),

        )
        );
  }
}
