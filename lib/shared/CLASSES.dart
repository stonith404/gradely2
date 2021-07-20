class Lesson {
    String id;
  String name;

  double average;
  String emoji;

  Lesson(this.id, this.name, this.emoji, this.average);
}

class User {
  String id;
  String name;
  int registration;
  int status;
  int passwordUpdate;
  String email;
  bool emailVerification;
  bool gradelyPlus;
  String gradeType;
  String choosenSemester;

  User(
      this.id,
      this.name,
      this.registration,
      this.status,
      this.passwordUpdate,
      this.email,
      this.emailVerification,
      this.gradelyPlus,
      this.gradeType,
      this.choosenSemester);
}
