
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DialogChooseDoc extends StatelessWidget {
  const DialogChooseDoc(this.listDocuments, this.setDocument, {super.key});
  final List<DocumentSnapshot> listDocuments;
  final Function(String) setDocument;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => {
        showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('Choix de la liste d\'élèves'),
            content: Container(
              height: 300.0,
              width: 300.0,
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: listDocuments.length,
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    height: 40,
                    color: Colors.amber[100],
                    child: Center(
                        child: TextButton(
                            onPressed: ()=>{
                              Navigator.pop(context, 'Validated'),
                              setDocument(listDocuments[index].id),
                            },
                            child: Text(listDocuments[index].id)
                        )
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) => const Divider(),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
            ],
          ),
        )
      },
      child: const Text('Importer élèves'),
    );
  }
}
