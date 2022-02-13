import "package:appwrite/appwrite.dart";
import "package:easy_localization/easy_localization.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/utils/user.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";

class SemesterController {
  final BuildContext context;
  SemesterController(this.context);

  /// Get a list of `Semester` object that the user owns.
  list() async {
    List<Semester> semesterList = (await api.listDocuments(
            collection: collectionSemester,
            name: "semesterList",
            queries: [Query.equal("parentId", user.dbID)]))
        .map((r) => Semester(r["\$id"], r["name"], r["round"]))
        .toList();

    return semesterList;
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
      {@required String userDbId,
      @required String name,
      @required double round}) async {
    isLoadingController.add(true);
    await getUserInfo();
    await api.createDocument(
        collectionId: collectionSemester,
        data: {"parentId": userDbId, "name": name, "round": round});
    isLoadingController.add(false);
  }

  /// Update an existing `Semester`.
  Future<void> update({@required String id, String name, double round}) async {
    isLoadingController.add(true);
    await getUserInfo();
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

  /// Create a `Semester` and copy the `Lessons` to it.
  Future<void> duplicateSemester(Semester semester) async {
    isLoadingController.add(true);
    List<Lesson> lessonsList = (await api.listDocuments(
            collection: collectionLessons,
            name: "lessonList_${semester.id}",
            queries: [Query.equal("parentId", semester.id)]))
        .map((r) => Lesson(r["\$id"], r["name"], r["emoji"],
            double.parse(r["average"].toString())))
        .toList();

    String newSemester =
        (await api.createDocument(collectionId: collectionSemester, data: {
      "parentId": user.dbID,
      "name": semester.name + " - ${'copy'.tr()}",
      "round": semester.round
    }))
            .$id;

    for (var i = 0; i < lessonsList.length; i++) {
      api.createDocument(collectionId: collectionLessons, data: {
        "parentId": newSemester,
        "name": lessonsList[i].name,
        "average": -99,
        "emoji": lessonsList[i].emoji
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
