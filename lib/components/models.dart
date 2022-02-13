class Lesson {
  String id;
  String name;
  double average;
  String emoji;

  Lesson(this.id, this.name, this.emoji, this.average);
}

class Semester {
  String id;
  String name;
  double round;

  Semester(this.id, this.name, this.round);
}

class Grade {
  String id;
  String name;
  double grade;
  double weight;
  String date;

  Grade(this.id, this.name, this.grade, this.weight, this.date);
}

class User {
  String id;
  String name;
  int registration;
  bool status;
  int passwordUpdate;
  String email;
  bool emailVerification;
  String gradeType;
  String choosenSemester;
  bool showcaseViewed;
  String dbID;

  User(
    this.id,
    this.name,
    this.registration,
    this.status,
    this.passwordUpdate,
    this.email,
    this.emailVerification,
    this.gradeType,
    this.choosenSemester,
    this.showcaseViewed,
    this.dbID,
  );
}
