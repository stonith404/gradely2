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
      String orderField}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List result = [];
    if (await internetConnection()) {
      DocumentList res = await database.listDocuments(
        filters: filters ?? [],
        collectionId: collection,
      );

      for (var i = 0; i < res.sum; i++) {
        result.add(res.documents[i].data);
      }
      await prefs.setString(name, jsonEncode(result));
    } else {
      result = jsonDecode(prefs.getString(name));
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
