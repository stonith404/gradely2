import "package:appwrite/appwrite.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/utils/grades.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";

class GradeController {
  final BuildContext? context;
  GradeController(this.context);

  /// Get a list of `Grade` object where the `parentId` is `subjectId`.
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

  /// Create a new grade.
  Future<void> create(
      {required String subjectId,
      required String name,
     required String grade,
      required String weight,
     required String date}) async {
    isLoadingController.add(true);

    await api.createDocument(
      context,
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

  /// Update an existing grade.
  Future<void> update(
      {required String id,
      required String name,
     required String grade,
      required String weight,
     required String date}) async {
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

  /// Delete a grade.
  Future<void> delete(String id) async {
    await api.deleteDocument(context,
        collectionId: collectionGrades, documentId: id);
  }
}
