// -------
// A script to setup your Appwrite instance for Gradely 2.
// ! This script isn't ready yet.
// -------

import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';

Database database;
void main() {
  print('''
                                    
 _____           _     _        ___ 
|   __|___ ___ _| |___| |_ _   |_  |
|  |  |  _| .'| . | -_| | | |  |  _|
|_____|_| |__,|___|___|_|_  |  |___|
                        |___|       

Welcome to the Gradely 2 Appwrite setup.
''');

//check list
  print(
      "This is a checklist to make sure you've done everything to start the setup. Press enter to continue. \n");
  stdin.readLineSync();
        print("First of all install and setup Appwrite (https://appwrite.io/docs/installation)\n");
  stdin.readLineSync();
          print("Have you set up your Appwrite Account?\n");
  stdin.readLineSync();
            print("Now create a Project you can you can name it whatever you want.\n");
  stdin.readLineSync();
              print("Okay you're done let's setup Gradely 2!\n");
  stdin.readLineSync();

//ask for endpoint
  print("Enter your Appwrite endpoint:");
  String endpoint = stdin.readLineSync();

//ask for project id
  print("Enter your Appwrite project id:");
  String projectId = stdin.readLineSync();

//ask for api key
  print("Enter your Appwrite Api-Key:");
  String apiKey = stdin.readLineSync();
  // Init SDK
  Client client = Client();
  database = Database(client);

  client
      .setEndpoint(endpoint) // Your API Endpoint
      .setProject(projectId) // Your project ID
      .setKey(apiKey); // Your secret API key

        print("Setup completed. 🎉");
}

void createCollections() {
  try {} on AppwriteException catch (e) {
    print(e.message);
  }
}

