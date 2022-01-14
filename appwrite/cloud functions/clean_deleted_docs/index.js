let sdk = require("node-appwrite");


// Initialise the client SDK
let client = new sdk.Client();
client
  .setEndpoint(process.env.APPWRITE_ENDPOINT)
  .setProject("60f40cb212896")
  .setKey(
    process.env.APPWRITE_API_KEY
  ); 

const collectionUser = { name: "Users", id: "60f40d07accb6" };
const collectionSemester = { name: "Semesters", id: "60f40d1b66424" };
const collectionLessons = { name: "Lessons", id: "60f40d0ed5da4" };
const collectionGrades = { name: "Grades", id: "60f71651520e5" };
// Initialise
let database = new sdk.Database(client);
let deletedDocuments = 0;

async function checkCollections(checkCollection, parentCollection) {
  console.log(
    "\nChecking " + checkCollection.name + "..."
  );

  let checkCollectionList = await listDocuments(checkCollection.id);

  let parentCollectionList = await listDocuments(parentCollection.id);

  for (let index = 0; index < checkCollectionList.length; index++) {
    if (
      !parentCollectionList.find(
        (parentCollectionDoc) => {
          return (
            parentCollectionDoc["$id"] ===
            checkCollectionList[index]["parentId"]
          );
        }
      )
    ) {
      deletedDocuments++;

      try {
         database.deleteDocument(checkCollection.id, checkCollectionList[index]["$id"])
      } catch {
        console.log("Error while deleting" + checkCollectionList[index]["$id"]);
      }
      console.log("deleted  " + checkCollectionList[index]["name"]);
    }
  }
}
async function listDocuments(collection) {
  let documentList = [];
  let stopLoop = false;
  let lastId = (await database.listDocuments(collection, undefined, 1))
    .documents[0].$id;
  while (!stopLoop) {
    let response = await database.listDocuments(
      collection,
      undefined,
      100,
      undefined,
      lastId,
      "after"
    );

    if (response.documents.length == 0) {
      stopLoop = true;
    } else {
      lastId = response.documents[response.documents.length - 1].$id;
      for (let index = 0; index < response.documents.length; index++) {
        documentList.push(response.documents[index]);
      }
    }
  }

  return documentList;
}

(async () => {
  await checkCollections(collectionSemester, collectionUser);
  await checkCollections(collectionLessons, collectionSemester);
  await checkCollections(collectionGrades, collectionLessons);
  console.log("\nDELETED " + deletedDocuments + " DOCUMENTS");
})();
