class Student {
  String nom = "";
  String prenom = "";
  String ID_carte = "";
  String numeroLeocarte = "";
  bool arrive = false;
  bool parti = false;

  Student(this.nom,this.prenom,this.ID_carte,this.numeroLeocarte,this.arrive,this.parti);

  toJSONEncodable() {
    Map<String, dynamic> m = Map();
    m['nom'] = nom;
    m['prenom'] = prenom;
    m['ID_carte'] = ID_carte;
    m['numeroLeocarte'] = numeroLeocarte;
    m['arrive'] = arrive;
    m['parti'] = parti;

    return m;
  }
}