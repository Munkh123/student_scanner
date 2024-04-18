import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:student_scanner/components/student_list.dart';
import 'package:student_scanner/dialogs/dialog_choose_doc.dart';
import 'package:localstorage/localstorage.dart';
import 'package:student_scanner/dialogs/dialog_scan.dart';
import 'package:student_scanner/models/student_model.dart';
import 'package:student_scanner/pages/form_create.dart';
import 'firebase_options.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Student> _students = [];
  final LocalStorage storage = LocalStorage('app.json');
  var db = FirebaseFirestore.instance;
  bool _initialized = false;
  ValueNotifier<dynamic> result = ValueNotifier(null);


  Future<void> _showDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const DialogScan()
    );
  }

  void _tagRead() {
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      result.value = tag.data;
      IsoDep? iso = IsoDep.from(tag);
      String numId = "";
      if (iso != null){
        for (var element in iso.identifier) {
          if(element < 10) numId += "0";
          numId =  "$numId${element.toRadixString(16)}:";
        }
        numId = numId.substring(0, numId.length - 1).toUpperCase();
        bool exist = false;
        for (var student in _students){
          if (student.ID_carte == numId){
            exist = true;
            if (student.arrive){
              student.parti = true;
              updateStudents(_students);
            }else {
              student.arrive = true;
              updateStudents(_students);
            }
          }
        }
        if (!exist)
          _showDialog();
      }
    });
  }

  void updateStudents(List<Student> temp) {
    setState(() {
      _students = temp;
      saveToStorage();
    });
  }

  void saveToStorage(){
    if(_students.isEmpty){

    }
    final forLocalStorage = _students
        .map((item) {
      return item.toJSONEncodable();
    }).toList();
    storage.setItem("eleves", forLocalStorage );
  }

  @override
  initState(){
    super.initState();
    _tagRead();
  }


  Future<void> _navigateAndDisplaySelection(BuildContext context) async {
    final param = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  CreationFormulairePDF(eleves: _students)),
    );

    if (!context.mounted) return;
    if (param.toString() == "clear") {
      updateStudents([]);
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('La liste des étudiants a été supprimé')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cours = db.collection("cours");
    final documentList = cours.get();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // boutton d'ajout d'étudiants
        children: [
          FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
            future: documentList,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
              List<Widget> children;
              if (snapshot.hasData) {
                print("loaded");
                final data = snapshot.data?.docs as List<DocumentSnapshot>;
                children = <Widget>[
                  DialogChooseDoc(
                      data,
                          (arg) {
                        final docRef = cours.doc(arg);
                        docRef.get().then(
                                (DocumentSnapshot doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              List<Student> temp = [];
                              if (data.containsKey("eleves")){
                                for(var doc in data["eleves"]) {
                                  temp.add(Student(
                                    doc["nom"],
                                    doc["prenom"],
                                    doc["ID_carte"],
                                    doc["numeroLeocarte"],
                                    false,
                                    false,
                                  ));
                                }
                              }
                              updateStudents(temp);
                            }
                        );
                      }
                  ),
                ];
              } else if (snapshot.hasError) {
                print("error");
                children = <Widget>[
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text('Error: ${snapshot.error}'),
                  ),
                ];
              } else {
                print("loading");
                children = const <Widget>[
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Awaiting result...'),
                  ),
                ];
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: children,
                ),
              );
            },
          ),
          FutureBuilder(future: storage.ready, builder : (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.data == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (!_initialized) {
              var items = storage.getItem('eleves');

              if (items != null) {
                _students = List<Student>.from(
                    (items as List).map(
                            (item) =>
                            Student(
                              item["nom"],
                              item["prenom"],
                              item["ID_carte"],
                              item["numeroLeocarte"],
                              item["arrive"],
                              item["parti"],
                            )
                    )
                );
              }

              _initialized = true;
            }
            return StudentList(eleves: _students);
          }),
          const Spacer(
            flex: 1,
          ),
          Padding(padding: const EdgeInsets.only(bottom: 10), child: ElevatedButton( onPressed: () {
            _navigateAndDisplaySelection(context);
          },
              child: const Text('Exporter PDF')))

        ]
      ),
    );
  }
}
