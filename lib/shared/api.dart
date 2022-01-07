import 'dart:convert';
import 'package:appwrite/models.dart';
import 'package:flutter/material.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradelyApi {
  Future<List> listDocuments(
      {@required String collection,
      @required String name,
      List filters,
      String orderField,
      bool offlineMode = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List result = [];
    if (!offlineMode && await internetConnection()) {
      DocumentList res = await database.listDocuments(
        filters: filters ?? [],
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
      noNetworkDialog(context);
    } else {
      return await database.deleteDocument(
          collectionId: collectionId, documentId: documentId);
    }
  }

  createDocument(context, {collectionId, data}) async {
    if (!await internetConnection()) {
      noNetworkDialog(context);
    } else {
      return await database.createDocument(
          collectionId: collectionId, data: data);
    }
  }

  updateDocument(context, {collectionId, documentId, data}) async {
    if (!await internetConnection()) {
      noNetworkDialog(context);
    } else {
      return await database.updateDocument(
          collectionId: collectionId, documentId: documentId, data: data);
    }
  }
}
