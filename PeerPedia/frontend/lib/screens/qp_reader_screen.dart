import 'package:flutter/material.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/screens/ak_reader_screen.dart';
import 'package:frontend/widgets/comment_modal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class QpReaderScreen extends StatefulWidget {
  const QpReaderScreen(
      {required this.subject,
      required this.group,
      required this.matName,
      required this.link1,
      required this.link2,
      super.key});

  final String matName;
  final String link1;
  final String link2;
  final GroupModel group;
  final SubjectModel subject;
  
  @override
  State<QpReaderScreen> createState() => _QpReaderScreenState();
}

class _QpReaderScreenState extends State<QpReaderScreen> {
  final matController = PdfViewerController();
  final _pdfViewerKey = GlobalKey<SfPdfViewerState>();
  Offset scrOff = Offset(0, 0);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            widget.matName,
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
                            matType: "qp",
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
        body: Stack(
          children: [
            SfPdfViewer.network(
              widget.link1,
              controller: matController,
              key: _pdfViewerKey,
            ),
            Container(
                alignment: Alignment.bottomRight,
                margin: const EdgeInsets.all(10),
                child: IconButton.filled(
                  onPressed: () async {
                    
                    scrOff = await Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => AkReaderScreen(
                            subject: widget.subject,
                            group: widget.group,
                            matName: widget.matName,
                            link1: widget.link1,
                            link2: widget.link2,
                            scrOff: scrOff)));
                  },
                  icon: Icon(Icons.swap_calls),
                )),
          ],
        ));
  }
}
