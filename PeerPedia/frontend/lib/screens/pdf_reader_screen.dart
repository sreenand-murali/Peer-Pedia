import 'package:flutter/material.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/widgets/comment_modal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfReaderScreen extends StatefulWidget {
  const PdfReaderScreen(
      {required this.subject,
      required this.group,
      required this.matName,
      required this.link,
      super.key});

  final String matName;
  final String link;
  final GroupModel group;
  final SubjectModel subject;

  @override
  State<PdfReaderScreen> createState() => _PdfReaderScreenState();
}

class _PdfReaderScreenState extends State<PdfReaderScreen> {
  final matController = PdfViewerController();
  final _pdfViewerKey = GlobalKey<SfPdfViewerState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.matName,style: GoogleFonts.nunito(
          fontWeight: FontWeight.bold,
        ),),
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (ctx) => CommentModal(
                          group: widget.group,
                          matName: widget.matName,
                          subject: widget.subject,
                          matType: "notes",
                          pageNo: matController.pageNumber,
                        ));
              },
              icon: const Icon(Icons.comment,color: Color.fromARGB(255, 24, 118, 185),))
        ],
      ),
      body: SfPdfViewer.network(
        widget.link,
        controller: matController,
        key: _pdfViewerKey,
      ),
    );
  }
}
