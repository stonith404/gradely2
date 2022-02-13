import "package:appwrite/appwrite.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/utils/grades.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";

class GradeController {
  final BuildContext context;
  GradeController(this.context);
  Future list(String subjectId) async {
    List<Grade> res = (await api.listDocuments(
      orderField: "date",
      collection: collectionGrades,
      name: "gradeList_$subjectId",
      queries: [Query.equal("parentId", subjectId)],
    ))
        .map((r) => Grade(
              r["\$id"],
              r["name"],
              double.parse(r["grade"].toString()),
              double.parse(r["weight"].toString()),
              r["date"] ?? "-",
            ))
        .toList();

    res.sort((a, b) => b.date.compareTo(a.date));

    return res;
  }

  Future<void> create(
      {String subjectId,
      @required String name,
      String grade,
      @required String weight,
      String date}) async {
    isLoadingController.add(true);

    await api.createDocument(
      collectionId: collectionGrades,
      data: {
        "parentId": subjectId,
        "name": name,
        "grade": (() {
          try {
            return double.parse(grade.replaceAll(",", "."));
          } catch (_) {
            return -99.0;
          }
        }()),
        "weight": double.parse(weight.replaceAll(",", ".")),
        "date": (() {
          try {
            return formatDateForDB(date);
          } catch (_) {
            return null;
          }
        }())
      },
    );
    isLoadingController.add(false);
  }

  Future<void> update(
      {String id,
      @required String name,
      String grade,
      @required String weight,
      String date}) async {
    isLoadingController.add(true);
    await api.updateDocument(context,
        collectionId: collectionGrades,
        documentId: id,
        data: {
          "name": name,
          "grade": (() {
            try {
              return double.parse(grade.replaceAll(",", "."));
            } catch (_) {
              return -99.0;
            }
          }()),
          "weight": double.parse(weight.replaceAll(",", ".")),
          "date": (() {
            try {
              return formatDateForDB(date);
            } catch (_) {
              return "";
            }
          }())
        });
    isLoadingController.add(false);
  }

  Future<void> delete(String id) async {
    await api.deleteDocument(context,
        collectionId: collectionGrades, documentId: id);
  }
}
