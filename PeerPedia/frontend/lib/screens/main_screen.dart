import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/models/NotesModel.dart';
import 'package:frontend/models/QuestionPaperModel.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/models/subject_model.dart';
import 'package:frontend/models/user_model.dart';
import 'package:frontend/providers/user_provider.dart';
import 'package:frontend/screens/login_screen.dart';
import 'package:frontend/widgets/group_input_modal.dart';
import 'package:frontend/widgets/group_namechange_modal.dart';
import 'package:frontend/widgets/group_update_modal.dart';
import 'package:frontend/widgets/groups_list.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
// import 'package:another_carousel_pro/another_carousel_pro.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({required this.user, super.key});

  final UserModel user;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  List<GroupModel> groupList = [];

  Uri url = Uri.http("192.168.165.50:3000", "group/add");
  Uri urlSearch = Uri.http("192.168.165.50:3000", "group/searchGroup");
  Uri urlGet = Uri.http("192.168.165.50:3000", "group/get");

  void addGroup(GroupModel group) async {
    group.admins = [ref.watch(userProvider).username];

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'name': group.name,
        "description": group.desc,
        'admins': group.admins,
        'subjects': group.subjects
            .map((e) => {
                  "name": e.name,
                })
            .toList(),
      }),
    );
    if (json.decode(response.body)["success"]) {
      setState(() {
        groupList.add(group);
      });
    } else if (json.decode(response.body)["groupExist"] && context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text(
            "Group with same name already exits,try using a different group.",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("ok"))
          ],
        ),
      );
    }
  }

  void setGroupList() async {
    try {
      final response = await http.get(urlGet);
      setState(() {
        groupList = json.decode(response.body)["groups"].map<GroupModel>((e) {
          final group = GroupModel(name: e["name"], desc: e["description"]);
          group.admins = e["admins"].map<String>((e) => e as String).toList();
          group.subjects = e["subjects"].map<SubjectModel>((e) {
            final subject = SubjectModel(name: e["name"]);
            subject.questionPapers =
                e["questionPapers"].map<QuestionPaperModel>((e) {
              final qpaks = QuestionPaperModel(
                  name: e["name"], link1: e["linkQp"], link2: e["linkAk"]);
              qpaks.admins =
                  e["admins"].map<String>((e) => e as String).toList();
              qpaks.likedUsers =
                  e["likedUserNames"].map<String>((e) => e as String).toList();
              return qpaks;
            }).toList();
            ;
            subject.notes = e["notes"].map<NotesModel>((e) {
              final notes = NotesModel(name: e["name"], link: e["link"]);
              notes.admins =
                  e["admins"].map<String>((e) => e as String).toList();
              notes.likedUsers =
                  e["likedUserNames"].map<String>((e) => e as String).toList();
              return notes;
            }).toList();
            return subject;
          }).toList();
          return group;
        }).toList();
      });
    } catch (e) {
      print("error occured while getting groups : $e");
    }
  }

  void groupDelFun(String groupName){
  setState(() {
    groupList.removeWhere((group) => group.name.toLowerCase() == groupName.toLowerCase());
  });
}

  void groupUpdateFun(String oldGroupName, String newGroupName, String desc) {
    setState(() {
      for (int i = 0; i < groupList.length; i++) {
        if (groupList[i].name.toLowerCase() == oldGroupName.toLowerCase()) {
          groupList[i].name = newGroupName;
          groupList[i].desc = desc;
          break;
        }
      }
    });
  }
  

  @override
  void initState() {
    setGroupList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        actions: [
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) =>
                        GroupNameChangeModal(updateFun: groupUpdateFun,));
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                showModalBottomSheet(
                    context: context,
                    builder: (context) =>
                        GroupUpdateModal(delFun: groupDelFun));
              },
              icon: const Icon(Icons.delete_outlined)),
        ],
        leading: Builder(
          builder: (context) => InkWell(
            onTap: (){
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 0),
              child: CircleAvatar(radius: 30.0,
                    backgroundImage:
                        NetworkImage("${ref.watch(userProvider).dpLink}"),
                    backgroundColor: Colors.transparent,),
            ),
          ),
        ),
      ),

      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                   CircleAvatar(radius: 30.0,
                backgroundImage:
                    NetworkImage("${ref.watch(userProvider).dpLink}"),
                backgroundColor: Colors.transparent,),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    widget.user.username,
                    style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    "${widget.user.firstName} ${widget.user.lastName}",
                    style: GoogleFonts.nunito(),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
            
                ],
              ),
            ),
            ListTile(
              title: Text(
                "Logout",
                style: GoogleFonts.nunito(),
              ),
              trailing: const Icon(Icons.logout),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('token');
                if (context.mounted) {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(25, 30, 25, 10),
            child: Text(
              "Hey ${ref.watch(userProvider).firstName}\nSearch your Hubs",
              // textAlign: Alignment.,
              style: GoogleFonts.nunito(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 1),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) async {
                      if (value.isEmpty || value == "") {
                        setGroupList();
                      } else {
                        try {
                          final response = await http.post(
                            urlSearch,
                            headers: {
                              'Content-Type': 'application/json',
                            },
                            body: json.encode({
                              'groupName': value,
                            }),
                          );
                          setState(() {
                            groupList = json
                                .decode(response.body)["groups"]
                                .map<GroupModel>((e) {
                              final group = GroupModel(
                                  name: e["name"], desc: e["description"]);
                              group.admins = e["admins"]
                                  .map<String>((e) => e as String)
                                  .toList();
                              group.subjects =
                                  e["subjects"].map<SubjectModel>((e) {
                                final subject = SubjectModel(name: e["name"]);
                                subject.questionPapers = e["questionPapers"]
                                    .map<QuestionPaperModel>((e) {
                                  final qpaks = QuestionPaperModel(
                                      name: e["name"],
                                      link1: e["linkQp"],
                                      link2: e["linkAk"]);
                                  qpaks.admins = e["admins"]
                                      .map<String>((e) => e as String)
                                      .toList();
                                  qpaks.likedUsers = e["likedUserNames"]
                                      .map<String>((e) => e as String)
                                      .toList();
                                  return qpaks;
                                }).toList();
                                ;
                                subject.notes = e["notes"].map<NotesModel>((e) {
                                  final notes = NotesModel(
                                      name: e["name"], link: e["link"]);
                                  notes.admins = e["admins"]
                                      .map<String>((e) => e as String)
                                      .toList();
                                  notes.likedUsers = e["likedUserNames"]
                                      .map<String>((e) => e as String)
                                      .toList();
                                  return notes;
                                }).toList();
                                return subject;
                              }).toList();
                              return group;
                            }).toList();
                          });
                        } catch (e) {
                          print("error occured while getting groups : $e");
                        }
                      }
                    },
                    style: GoogleFonts.nunito(),
                    decoration: const InputDecoration(
                      hintText: 'Search your group here...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.search,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Expanded(
              child: Container(
            margin: const EdgeInsets.all(15),
            child: GroupList(groupList: groupList),
          )),
        ],
      ),
      // ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 158, 185, 247),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => GroupInputModal(addGroupFun: addGroup),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
