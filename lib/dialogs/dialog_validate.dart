import 'package:flutter/material.dart';

class DialogValid extends StatelessWidget {
  const DialogValid({super.key});

  @override
  Widget build(BuildContext context) {
    return (
        AlertDialog(
          title: const Text('Etes-vous sûr de vouloir exporter le document ?'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Toutes les données seront perdus'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Non'),
              onPressed: () {
                Navigator.pop(context, "false");
              },
            ),
            TextButton(
              child: const Text('Oui'),
              onPressed: () {
                Navigator.pop(context,"true");
              },
            ),
          ],
        )
    );
  }
}
