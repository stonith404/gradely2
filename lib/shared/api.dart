import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gradely2/shared/FUNCTIONS.dart';
import 'package:gradely2/shared/VARIABLES.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GradelyApi {
  Future<Map> listDocuments(
      {@required String collection,
      @required String name,
      List filters,
      String orderField}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map response;
    if (await internetConnection()) {
      Future result = database.listDocuments(
        filters: filters ?? [],
        collectionId: collection,
      );

      await result.then((r) async {
        response = jsonDecode(r.toString());

        await prefs.setString(name, jsonEncode(response));
      }).catchError((error) {});
    } else {
      response = jsonDecode(prefs.getString(name));
    }

    return response;
  }

  deleteDocument(context,{collectionId, documentId}) async {
    if (!await internetConnection()) {
      noNetworkDialog(context);
    } else {
      return await database.deleteDocument(
          collectionId: collectionId, documentId: documentId);
    }
  }

  createDocument(context,{collectionId, data}) async {
    if (!await internetConnection()) {
      noNetworkDialog(context);
    } else {
      return await database.createDocument(
          collectionId: collectionId, data: data);
    }
  }

  updateDocument(context,{collectionId, documentId, data}) async {
    if (!await internetConnection()) {
      noNetworkDialog(context);
    } else {
      return await database.updateDocument(
          collectionId: collectionId, documentId: documentId, data: data);
    }
  }
}
