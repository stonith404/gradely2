import "package:appwrite/appwrite.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";

class SubjectController {
  final BuildContext? context;
  SubjectController(this.context);

  /// Get a list of `Subject` object from the where the `parentId` is `user.choosenSemester`.
  Future<List<Subject>> list({bool getFromCache = false}) async {
    List<Subject> res = (await api.listDocuments(
            collection: collectionSubjects,
            name: "subjectList_${user.choosenSemester}",
            queries: [Query.equal("parentId", user.choosenSemester)],
            offlineMode: getFromCache))
        .map((r) => Subject(
            r["\$id"], r["name"], double.parse(r["average"].toString())))
        .toList();
    res.sort((a, b) => b.average.compareTo(a.average));
    return res;
  }

  /// Create a new subject.
  Future<void> create({required String name}) async {
    isLoadingController.add(true);
    await api.createDocument(
      context,
      collectionId: collectionSubjects,
      data: {
        "parentId": user.choosenSemester,
        "name": name,
        "average": -99,
      },
    );
    isLoadingController.add(false);
  }

  /// Update an existing subject.
  Future<void> update({required String id, required String name}) async {
    isLoadingController.add(true);
    await api.updateDocument(context,
        collectionId: collectionSubjects,
        documentId: id,
        data: {
          "name": name,
        });
    isLoadingController.add(false);
  }

  /// Delete a subject.
  Future<void> delete(String id) async {
    await api.deleteDocument(context,
        collectionId: collectionSubjects, documentId: id);
  }
}
