import 'package:flutter/material.dart';
import 'package:frontend/models/group_model.dart';
import 'package:frontend/screens/group_screen.dart';
import 'package:google_fonts/google_fonts.dart';

class GroupList extends StatefulWidget {
  const GroupList({required this.groupList, super.key});
  final List<GroupModel> groupList;
  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 cards in a row
      ),
      itemCount: widget.groupList.length,
      itemBuilder: (BuildContext ctx, int index) => Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 255, 255, 255),

            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => GroupScreen(
                    group: widget.groupList[index],
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.groupList[index].name,
                    style: GoogleFonts.nunito(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                       ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.groupList[index].desc==null?"":widget.groupList[index].desc!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.nunito(
                      
                    ),
                  ),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
