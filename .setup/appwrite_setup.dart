// -------
// A script to setup your Appwrite instance for Gradely 2.
// ! This script isn't ready yet.
// -------

import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';

Database database;
String endpoint;
String projectId = "60f40cb212896";
String apiKey;
void main() async {
  introduction();

  // Init SDK
  Client client = Client();
  database = Database(client);

  client
      .setEndpoint(endpoint) // Your API Endpoint
      .setProject(projectId) // Your project ID
      .setKey(apiKey); // Your secret API key

  try {
    await createCollections();
    print("Setup completed. 🎉");
  } catch (e) {
    print("\n❌-----------❌\n\n$e\n\n❌-----------❌\n");
    print(
        "😫 Oops the setup failed. Please check the error message. If you think it's a bug please create an issue on GitHub: \nhttps://github.com/generalxhd/gradely2/issues/new\n");
  }
}

void createCollections() async {
  for (var collection in collections) {
    try {
      stdout.write("\nCreating collection ${collection['name']}...");
      await database.createCollection(
          collectionId: collection["id"],
          name: collection["name"],
          permission: collection["permission"] ?? "document",
          read: collection["read"],
          write: collection["write"]);

      await createAttributes(collection);
      // Wait until attributes are available
      bool isAttributeAvailable = false;
      while (!isAttributeAvailable) {
        isAttributeAvailable = await (() async {
          for (var attribute
              in (await database.listAttributes(collectionId: collection["id"]))
                  .attributes) {
            return attribute["status"] == "available";
          }
        }());

        sleep(Duration(seconds: 2));
      }

// Let's create the indexes
      createIndexes(collection);
      print(" ✅");
    } catch (e) {
      print(" ❌");
      throw e;
    }
  }
}

// First of all we create the collection

void createAttributes(collection) async {
  for (var attribute in collection["attributes"]) {
    if (attribute["type"] == "string") {
      await database.createStringAttribute(
          collectionId: collection["id"],
          key: attribute["key"],
          size: attribute["size"],
          xrequired: attribute["required"]);
    } else if (attribute["type"] == "bool") {
      await database.createBooleanAttribute(
          collectionId: collection["id"],
          key: attribute["key"],
          xrequired: attribute["required"]);
    } else if (attribute["type"] == "double") {
      await database.createFloatAttribute(
          collectionId: collection["id"],
          key: attribute["key"],
          xrequired: attribute["required"]);
    }
  }
}

void createIndexes(collection) async {
  for (var index in collection["indexes"]) {
    await database.createIndex(
        collectionId: collection["id"],
        key: index["key"],
        type: index["type"],
        attributes: index["attributes"],
        orders: index["orders"]);
  }
}

void introduction() {
  List setupQuestions = [
    "First of all install and setup Appwrite (https://appwrite.io/docs/installation)",
    "Have you set up your Appwrite Account?",
    "Now create a Project with the project Id 60f40cb212896",
    "Okay you're done let's setup Gradely 2!"
  ];

  print('''
                                    
 _____           _     _        ___ 
|   __|___ ___ _| |___| |_ _   |_  |
|  |  |  _| .'| . | -_| | | |  |  _|
|_____|_| |__,|___|___|_|_  |  |___|
                        |___|       

Welcome to the Gradely 2 Appwrite setup.
''');

// //check list
  print(
      "This is a checklist to make sure you've done everything to start the setup. Press enter to continue. \n");

  for (var i = 0; i < setupQuestions.length; i++) {
    bool ok = false;
    while (!ok) {
      print((i + 1).toString() + ". " + setupQuestions[i] + " (y/n)");
      if (stdin.readLineSync() != "y") {
        print("Okay lets try again");
      } else {
        ok = true;
      }
    }
  }
  //ask for endpoint
  print("Enter your Appwrite endpoint:");
  endpoint = stdin.readLineSync();

//ask for api key
  print("Enter your Appwrite Api-Key:");
  apiKey = stdin.readLineSync();
}

List collections = [
  {
    "id": "60f40d07accb6",
    "name": "Users",
    "permission": "document",
    "read": ["role:all"],
    "write": ["role:all"],
    "attributes": [
      {"type": "string", "key": "uid", "size": 255, "required": true},
      {"type": "string", "key": "grade_type", "size": 10, "required": true},
      {
        "type": "string",
        "key": "choosenSemester",
        "size": 255,
        "required": true
      },
      {"type": "bool", "key": "showcase_viewed", "required": true}
    ],
    "indexes": [
      {
        "key": "uid",
        "type": "key",
        "attributes": ["uid"],
        "orders": ["ASC"]
      }
    ]
  },
  {
    "id": "60f40d1b66424",
    "name": "Semesters",
    "permission": "document",
    "read": ["role:all"],
    "write": ["role:all"],
    "attributes": [
      {"type": "string", "key": "parentId", "size": 255, "required": true},
      {"type": "string", "key": "name", "size": 255, "required": true},
      {"type": "double", "key": "round", "required": true},
      {"type": "bool", "key": "showcase_viewed", "required": true}
    ],
    "indexes": [],
  },
  {
    "id": "60f40d0ed5da4",
    "name": "Subjects",
    "permission": "document",
    "read": ["role:all"],
    "write": ["role:all"],
    "attributes": [
      {"type": "string", "key": "parentId", "size": 255, "required": true},
      {"type": "string", "key": "name", "size": 255, "required": true},
      {"type": "string", "key": "emoji", "size": 255, "required": true},
      {"type": "double", "key": "average", "required": true},
    ],
    "indexes": [
      {
        "key": "subjects_parentId",
        "type": "key",
        "attributes": ["parentId"],
        "orders": ["ASC"]
      }
    ],
  },
  {
    "id": "60f71651520e5",
    "name": "Grades",
    "permission": "document",
    "read": ["role:all"],
    "write": ["role:all"],
    "attributes": [
      {"type": "string", "key": "parentId", "size": 255, "required": true},
      {"type": "string", "key": "name", "size": 255, "required": true},
      {"type": "double", "key": "grade", "required": true},
      {"type": "double", "key": "weight", "required": true},
      {"type": "string", "date": "name", "size": 100, "required": true}
    ],
    "indexes": [],
  },
  {
    "id": "60f71651520e5",
    "name": "App Configuration",
    "permission": "collection",
    "read": ["role:all"],
    "write": [],
    "attributes": [
      {"type": "string", "key": "key", "size": 255, "required": true},
      {"type": "string", "key": "value", "size": 255, "required": true},
    ],
    "indexes": [],
  },
];
