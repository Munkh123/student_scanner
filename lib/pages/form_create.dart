import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:student_scanner/dialogs/dialog_validate.dart';

import '../models/student_model.dart';
import '../utils/pdf_generation.dart';

class CreationFormulairePDF extends StatefulWidget {
  const CreationFormulairePDF({super.key, required this.eleves});

  final List<Student> eleves;
  @override
  _CreationFormulairePDFState createState() => _CreationFormulairePDFState();
}

class _CreationFormulairePDFState extends State<CreationFormulairePDF> {
  TextEditingController professeurRefController = TextEditingController();
  TextEditingController matiereController = TextEditingController();
  TextEditingController promoController = TextEditingController();
  TextEditingController fileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Formulaire PDF"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: fileController,
              decoration: InputDecoration(labelText: 'Nom du fichier'),
            ),
            TextField(
              controller: professeurRefController,
              decoration: InputDecoration(labelText: 'Professeur Référent'),
            ),
            TextField(
              controller: matiereController,
              decoration: InputDecoration(labelText: 'Matière'),
            ),
            TextField(
              controller: promoController,
              decoration: InputDecoration(labelText: 'Promo'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                showDialog<String>(context: context, builder: (BuildContext context) => const DialogValid()).then((value ) {
                  if(value == "true") {
                    createPdf(fileController.text.trim(), professeurRefController.text.trim(), matiereController.text.trim(),promoController.text.trim(),widget.eleves);
                    Navigator.pop(context,"clear");
                  }
                });

              },
              child: Text("Confirmer"),
            ),
          ],
        ),
      ),
    );
  }
}