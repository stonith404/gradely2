import "dart:convert";
import "package:appwrite/appwrite.dart";
import "package:appwrite/models.dart";
import "package:flutter/material.dart";
import "package:gradely2/components/utils/app.dart";
import "package:gradely2/components/variables.dart";
import "package:shared_preferences/shared_preferences.dart";

class GradelyApi {
  Future<List> listDocuments(
      {@required String collection,
      @required String name,
      List queries,
      String orderField,
      bool offlineMode = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List result = [];
    if (!offlineMode && await internetConnection()) {
      DocumentList res = await database.listDocuments(
        queries: queries ?? [],
        collectionId: collection,
      );

      for (var i = 0; i < res.sum; i++) {
        result.add(res.documents[i].data);
      }
      prefs.setString(name, jsonEncode(result));
    } else {
      var res = jsonDecode(prefs.getString(name) ?? "{}");

      for (var i = 0; i < res.length; i++) {
        result.add(res[i]);
      }
    }

    return result;
  }

  deleteDocument(context, {collectionId, documentId}) async {
    if (!await internetConnection()) {
      // noNetworkDialog(context);
    } else {
      try {
        return await database.deleteDocument(
            collectionId: collectionId, documentId: documentId);
      } on AppwriteException {
        // errorSuccessDialog(context: context, error: true, text: e.message);
      }
    }
  }

  createDocument({collectionId, data}) async {
    if (!await internetConnection()) {
      // noNetworkDialog(context);
    } else {
      try {
        return await database.createDocument(
            documentId: "unique()", collectionId: collectionId, data: data);
      } on AppwriteException {
        // errorSuccessDialog(context: context, error: true, text: e.message);
      }
    }
  }

  updateDocument(context, {collectionId, documentId, data}) async {
    if (!await internetConnection()) {
      // noNetworkDialog(context);
    } else {
      try {
        return await database.updateDocument(
            collectionId: collectionId, documentId: documentId, data: data);
      } on AppwriteException {
        // errorSuccessDialog(context: context, error: true, text: e.message);
      }
    }
  }
}
