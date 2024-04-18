
import 'dart:io';


import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pdf/widgets.dart' as pdf_widget;
import 'dart:developer' as developer;
import 'package:student_scanner/utils/android_check.dart';

import '../models/student_model.dart';

void createPdf(nomFichier, enseignantRef, matiere, promo, etudiants) async {

  //récupération permission et demande si non accordée
  var etat = await Permission.storage.status;
  var androidModern = await checkDevice();

  if (etat.isDenied && !androidModern ) {
    await Permission.storage.request();
    if (etat.isDenied) {
      await openAppSettings();
    }
  } else if (etat.isPermanentlyDenied && !androidModern) {
    await openAppSettings();
  } else {
    final pdf = pdf_widget.Document();

    //multipages pdf avec format A4
    pdf.addPage(pdf_widget.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (pdf_widget.Context context) {
        //le contenu du pdf qui va etre ajouté à la fin de la mise en page et la structuration des données
        return getContenu(etudiants, enseignantRef, matiere, promo);
      },
      footer: (context) {
        return pdf_widget.Row(
          mainAxisAlignment: pdf_widget.MainAxisAlignment.spaceBetween,
          children: [
            pdf_widget.Text('Page ${context.pageNumber}'),
          ],
        );
      },
    ));

    //chemin stockage pdf "vérifier le stocakge interne du téléphone puis le dossier Download", chemin accessible uniquement sur Android!!!
    final output = Directory("/storage/emulated/0/Download/");

    final fichier = File("${output.path}$nomFichier.pdf");

    await fichier.writeAsBytes(await pdf.save()).then(
            (value) => developer.log("Le PDF a été généré: ${fichier.toString()}"));
  }
}

//génération contenu pdf
List<pdf_widget.Widget> getContenu(List<Student> tabEtudiants,
    String enseignantRef, String matiere, String promo) {
  //nombre de valeurs à afficher par page avant de sauter à la page suivante
  const sautToutesLesXLignes = 40;

  List<pdf_widget.Widget> content = [];

  //itération sur la liste des étudiants
  for (int i = 0; i < tabEtudiants.length; i++) {
    //détails concernant l'examen que sur la 1ere page
    if (i == 0) {
      getDetailsExamen(content, enseignantRef, matiere, promo);
    }

    //nom des champs sur chaque page
    getNomChamps(i, sautToutesLesXLignes, content);

    //affichage etudiant
    content.add(pdf_widget.Table(
      border: pdf_widget.TableBorder.all(),
      columnWidths: {
        0: const pdf_widget.FixedColumnWidth(100),
        1: const pdf_widget.FixedColumnWidth(100),
        2: const pdf_widget.FixedColumnWidth(100),
        3: const pdf_widget.FixedColumnWidth(100),
      },
      children: [
        pdf_widget.TableRow(
          children: [
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              child: pdf_widget.Text(tabEtudiants[i].nom),
            ),
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              child: pdf_widget.Text(tabEtudiants[i].prenom),
            ),
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              color: PdfColor.fromHex(
                  tabEtudiants[i].arrive ? "#FFFFFF" : "#FF0000"),
              child: pdf_widget.Text(tabEtudiants[i].arrive ? "oui" : "non"),
            ),
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              color: PdfColor.fromHex(
                  tabEtudiants[i].parti ? "#FFFFFF" : "#FF0000"),
              child: pdf_widget.Text(tabEtudiants[i].parti ? "oui" : "non"),
            ),
          ],
        ),
      ],
    ));

    //une nouvelle page toutes les x lignes
    if ((i + 1) % sautToutesLesXLignes == 0 && (i + 1) < tabEtudiants.length) {
      content.add(pdf_widget.SizedBox(height: 12));
      content.add(pdf_widget.NewPage());
    }
  }
  //fin de génération des contenus on envoie le contenu du pdf
  return content;
}


//ajouter détails d'examen
getDetailsExamen(List<pdf_widget.Widget> content, String enseignantRef,
    String matiere, String promo) {
  String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

  //ajout titre avec la date courante
  content.add(pdf_widget.Row(
    mainAxisAlignment: pdf_widget.MainAxisAlignment.center,
    children: [
      pdf_widget.Text('Fiche de présence de $date',
          style: pdf_widget.TextStyle(
              fontWeight: pdf_widget.FontWeight.bold, fontSize: 25)),
    ],
  ));
  //détails examen(enseignant, promo, matiere)
  content.add(pdf_widget.Column(
    crossAxisAlignment: pdf_widget.CrossAxisAlignment.start,
    children: [
      pdf_widget.SizedBox(height: 20),
      pdf_widget.Text('Enseignant référant: ${enseignantRef.toUpperCase()}',
          style: pdf_widget.TextStyle(
              fontWeight: pdf_widget.FontWeight.bold, fontSize: 15)),
      pdf_widget.Text(
          'Matière: ${matiere[0].toUpperCase()}${matiere.substring(1)}',
          style: pdf_widget.TextStyle(
              fontWeight: pdf_widget.FontWeight.bold, fontSize: 15)),
      pdf_widget.Text('Promotion: ${promo.toUpperCase()}',
          style: pdf_widget.TextStyle(
              fontWeight: pdf_widget.FontWeight.bold, fontSize: 15)),
      pdf_widget.SizedBox(height: 12),
    ],
  ));
}

//afficher le nom des champs sur la 1ere ligne d'une nouvele page
getNomChamps(int i, int sautToutesLesXLignes, List<pdf_widget.Widget> content) {
  if (i % sautToutesLesXLignes == 0) {
    content.add(pdf_widget.Table(
      border: pdf_widget.TableBorder.all(),
      columnWidths: {
        0: const pdf_widget.FixedColumnWidth(100),
        1: const pdf_widget.FixedColumnWidth(100),
        2: const pdf_widget.FixedColumnWidth(100),
        3: const pdf_widget.FixedColumnWidth(100),
      },
      children: [
        pdf_widget.TableRow(
          children: [
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              color: PdfColor.fromHex("#43d9d1"),
              child: pdf_widget.Text('Nom',
                  style: pdf_widget.TextStyle(
                      fontWeight: pdf_widget.FontWeight.bold)),
            ),
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              color: PdfColor.fromHex("#43d9d1"),
              child: pdf_widget.Text('Prénom',
                  style: pdf_widget.TextStyle(
                      fontWeight: pdf_widget.FontWeight.bold)),
            ),
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              color: PdfColor.fromHex("#43d9d1"),
              child: pdf_widget.Text('Scan d\'arrivé',
                  style: pdf_widget.TextStyle(
                      fontWeight: pdf_widget.FontWeight.bold)),
            ),
            pdf_widget.Container(
              padding: const pdf_widget.EdgeInsets.only(left: 10),
              color: PdfColor.fromHex("#43d9d1"),
              child: pdf_widget.Text('Scan de départ',
                  style: pdf_widget.TextStyle(
                      fontWeight: pdf_widget.FontWeight.bold)),
            ),
          ],
        ),
      ],
    ));
  }


}