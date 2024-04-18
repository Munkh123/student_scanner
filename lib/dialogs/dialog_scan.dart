import 'package:flutter/material.dart';

class DialogScan extends StatefulWidget {
  const DialogScan({super.key});

  @override
  State<DialogScan> createState() => _DialogScanState();
}

class _DialogScanState extends State<DialogScan> {

  late TextEditingController _prenom;
  late TextEditingController _nom;
  late TextEditingController _leo;

  @override
  void initState() {
    super.initState();
    _prenom = TextEditingController();
    _nom = TextEditingController();
    _leo = TextEditingController();
  }

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _leo.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
       return Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text('Carte non reconnue, veuillez indiquer vos informations',style: ThemeData().textTheme.headlineLarge),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _nom,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Nom',
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _prenom,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Prenom',
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _leo,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Léocode',
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context,
                              {
                                "prenom" : _prenom.text,
                                "nom" : _nom.text,
                                "leo" : _leo.text
                              });
                          },
                          child: const Text('Valider'),
                        ),
                      ],
                    )

                  ],
                ),
              ),
       );

  }
}
