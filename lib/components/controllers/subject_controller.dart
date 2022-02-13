import "package:appwrite/appwrite.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/models.dart";
import "package:gradely2/components/variables.dart";

class SubjectController {
  final BuildContext context;
  SubjectController(this.context);

  /// G
  Future<List<Lesson>> list({bool getFromCache = false}) async {
    List<Lesson> res = (await api.listDocuments(
            collection: collectionLessons,
            name: "lessonList_${user.choosenSemester}",
            queries: [Query.equal("parentId", user.choosenSemester)],
            offlineMode: getFromCache))
        .map((r) => Lesson(r["\$id"], r["name"], r["emoji"],
            double.parse(r["average"].toString())))
        .toList();
    res.sort((a, b) => b.average.compareTo(a.average));
    return res;
  }

  Future<void> create({@required String name}) async {
    isLoadingController.add(true);
    await api.createDocument(
      collectionId: collectionLessons,
      data: {
        "parentId": user.choosenSemester,
        "name": name,
        "average": -99,
      },
    );
    isLoadingController.add(false);
  }

  Future<void> update({@required String id, @required String name}) async {
    isLoadingController.add(true);
    await api.updateDocument(context,
        collectionId: collectionLessons,
        documentId: id,
        data: {
          "name": name,
        });
    isLoadingController.add(false);
  }

  Future<void> delete(String id) async {
    await api.deleteDocument(context,
        collectionId: collectionLessons, documentId: id);
  }
}
