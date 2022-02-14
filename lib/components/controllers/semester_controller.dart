import "package:appwrite/appwrite.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/controllers/user_controller.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";

class SemesterController {
  final BuildContext? context;
  final UserController userController = UserController();
  SemesterController(this.context);

  /// Get a list of `Semester` object that the user owns.
  list() async {
    List<Semester> res = (await api.listDocuments(
            collection: collectionSemester,
            name: "semesterList",
            queries: [Query.equal("parentId", user.dbID)]))
        .map((r) => Semester(r["\$id"], r["name"], r["round"]))
        .toList();
    return res;
  }

  /// Get a semester by id.
  Future<Semester> getById(String semesterId) async {
    List<dynamic> res = await api.listDocuments(
        collection: collectionSemester,
        name: "semesterName",
        queries: [Query.equal("\$id", semesterId)]);
    return res
        .map((r) => Semester(r["\$id"], r["name"], r["round"]))
        .toList()[0];
  }

  /// Create a new `Semester`.
  Future<void> create(
      {required String userDbId,
      required String name,
      required double round}) async {
    isLoadingController.add(true);
    await userController.getUserInfo();
    await api.createDocument(context,
        collectionId: collectionSemester,
        data: {"parentId": userDbId, "name": name, "round": round});
    isLoadingController.add(false);
  }

  /// Update an existing `Semester`.
  Future<void> update(
      {required String id, required String name, required double round}) async {
    isLoadingController.add(true);
    await userController.getUserInfo();
    await api.updateDocument(context,
        documentId: id,
        collectionId: collectionSemester,
        data: {"name": name, "round": round});
    isLoadingController.add(false);
  }

  /// Delete a `Semester`
  Future<void> delete(String id) async {
    await api.deleteDocument(context,
        collectionId: collectionSemester, documentId: id);
  }

  /// Create a `Semester` and copy the `Subjects` to it.
  Future<void> duplicateSemester(Semester semester) async {
    isLoadingController.add(true);
    List<Subject> subjectsList = (await api.listDocuments(
            collection: collectionSubjects,
            name: "subjectList_${semester.id}",
            queries: [Query.equal("parentId", semester.id)]))
        .map((r) => Subject(
            r["\$id"], r["name"], double.parse(r["average"].toString())))
        .toList();

    String newSemester = (await api
            .createDocument(context, collectionId: collectionSemester, data: {
      "parentId": user.dbID,
      "name": semester.name + " - ${'copy'.tr()}",
      "round": semester.round
    }))
        .$id;

    for (var i = 0; i < subjectsList.length; i++) {
      api.createDocument(context, collectionId: collectionSubjects, data: {
        "parentId": newSemester,
        "name": subjectsList[i].name,
        "average": -99,
      });
    }
    isLoadingController.add(false);
  }

  /// Sets the active `Semester` from an user.
  Future<void> setActiveSemester(String id) async {
    user.choosenSemester = id;
    await api.updateDocument(context,
        collectionId: collectionUser,
        documentId: user.dbID,
        data: {"choosenSemester": id});
  }
}
