class Band {
  String? id;
  String? name;
  int? votes;

  Band({ this.id,  this.name,  this.votes});

  //el factory contructor regresa una nueva instancia de la clase pero returnando un tipo de dato distinto  al que entra, en este caso recibe un objeto de tipo Map
  factory Band.fromMap(Map<String, dynamic> obj) =>
      Band(
      id: obj.containsKey('id') ? obj['id'] : 'no-id', 
      name: obj.containsKey('name') ? obj['name'] : 'no-name', 
      votes: obj.containsKey('votes') ? obj['votes'] : 'no-votes');
}
