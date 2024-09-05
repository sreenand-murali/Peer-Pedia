import 'package:frontend/models/subject_model.dart';

class GroupModel{
  GroupModel({required this.name,this.desc});

  String name;
  String? desc;
  List<String> admins = [];
  List<SubjectModel> subjects = [];
}