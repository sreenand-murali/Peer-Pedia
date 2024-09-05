
class QuestionPaperModel{
  QuestionPaperModel({required this.name, required this.link1, required this.link2, });

  String name;
  String link1;
  String link2;
  List<String> admins = [];
  List<String> likedUsers = [];
}