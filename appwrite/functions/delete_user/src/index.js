const sdk = require("node-appwrite");


module.exports = async function (req, res) {
  const client = new sdk.Client();

  // Setup Appwrite connection
  let database = new sdk.Database(client);
  let users = new sdk.Users(client);

  client
    .setEndpoint(req.env['APPWRITE_ENDPOINT'])
    .setProject(req.env['APPWRITE_FUNCTION_PROJECT_ID'])
    .setKey(req.env['APPWRITE_API_KEY'])


  // Delete an user  
  let uid = process.env.APPWRITE_FUNCTION_USER_ID;

  let userEmail = (await users.get(uid)).email
  await users.deleteSessions(uid)
  await users.delete(uid)
  let dbDocumentId = (await database.listDocuments("60f40d07accb6", [sdk.Query.equal("uid", uid)])).documents[0].$id
  await database.deleteDocument("60f40d07accb6", dbDocumentId)


  res.json({
    message: `Deleted user ${userEmail} successfully`,
  });
};


