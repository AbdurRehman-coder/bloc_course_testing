// Program the Person
class Person {
  // final String name;
  final int id;
  final String title;
  // default constructor
  const Person({required this.id, required this.title});
// constructor for json
  Person.fromJson(Map<String, dynamic> json)
      // : name = json['name'] as String,
      : id = json['id'] as int,
        title = json['title'] as String;

  @override
  String toString() => 'Person ( id: $id, title: $title)';
}
