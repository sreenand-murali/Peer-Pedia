
class NotesModel{
  NotesModel({required this.name, required this.link});

  String name;
  String link;
  List<String> admins = [];
  List<String> likedUsers = [];
}