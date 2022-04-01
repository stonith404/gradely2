const sdk = require("node-appwrite");


module.exports = async function (req, res) {
  const client = new sdk.Client();

  // Setup Appwrite connection
  let users = new sdk.Users(client);

  client
    .setEndpoint(req.env['APPWRITE_ENDPOINT'])
    .setProject(req.env['APPWRITE_FUNCTION_PROJECT_ID'])
    .setKey(req.env['APPWRITE_API_KEY'])


  // Delete the unverifed users  
  let result = [""];
  let lastId;
  let deletedUsers = 0;
  while (result.length != 0) {
    result = (await users.list(undefined, 100, undefined, lastId, "after")).users;
    for (const user of result) {
      let isOlderThenThreeMonths = (Date.now() / 1000 - user.registration) > 3600 * 24 * 31 * 3 // 3 Months
      if (!user.emailVerification && isOlderThenThreeMonths) {
        users.delete(user.$id)
        deletedUsers++;
      }
    }
    try {
      lastId = result[result.length - 1].$id
    } catch (_) {
      break;
    }
  }

  res.json({
    message: `Deleted ${deletedUsers} users.`,
  });
};


