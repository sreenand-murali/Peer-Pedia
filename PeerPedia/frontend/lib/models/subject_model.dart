import 'package:frontend/models/NotesModel.dart';
import 'package:frontend/models/QuestionPaperModel.dart';

class SubjectModel{
  SubjectModel({required this.name});
  final admins = [];
  String name;
  List<NotesModel> notes = [];
  List<QuestionPaperModel> questionPapers = [];
  
}