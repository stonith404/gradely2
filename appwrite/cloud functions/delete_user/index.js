import { Query, Client, Users, Database } from "node-appwrite";


// Initialise the client SDK
let client = new Client();
client
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject(process.env.APPWRITE_FUNCTION_PROJECT_ID)
    .setKey(
        process.env.APPWRITE_API_KEY
    );

let users = new Users(client);
let database = new Database(client);
let uid = process.env.APPWRITE_FUNCTION_USER_ID;

(async () => {
    let userEmail = (await users.get(uid)).email
    await users.deleteSessions(uid)
    await users.delete(uid)
    let dbDocumentId = (await database.listDocuments("60f40d07accb6", [Query.equal("uid", uid)])).documents[0].$id
    await database.deleteDocument("60f40d07accb6", dbDocumentId)
    console.log(`Deleted user ${userEmail} successfully`)
})();
