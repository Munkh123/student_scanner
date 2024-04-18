import 'package:flutter/material.dart';
import 'package:student_scanner/models/student_model.dart';


class StudentList extends StatefulWidget {
  const StudentList({super.key, required this.eleves});

  final List<Student> eleves;
  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color getColor(bool arrive) {
    if ( arrive )
      return Colors.green;
    else
      return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return widget.eleves.length > 0 ? ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(8),
        itemCount: widget.eleves.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            width: 200,
            color: Colors.white,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
                children:[

              Text(widget.eleves[index].prenom + " " + widget.eleves[index].nom),
              Spacer(flex: 1 ),
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: getColor(widget.eleves[index].arrive),
                  shape: BoxShape.circle
                ),
              ),
              SizedBox(width: 20),
              Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                      color: getColor(widget.eleves[index].parti),
                      shape: BoxShape.circle
                  ),
                )
            ] ),
          );
        }
    ): const Padding(padding: EdgeInsets.only(top: 20), child: Center(child: Text('Aucun élèves'))) ;
  }
}
