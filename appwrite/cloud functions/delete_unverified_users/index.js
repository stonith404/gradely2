import { Client, Users } from "node-appwrite";




// Initialise the client SDK
let client = new Client();
client
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject("60f40cb212896")
    .setKey(
        process.env.APPWRITE_API_KEY
    );

let users = new Users(client);

(async () => {
    let res = [""];
    let lastId;
    let deletedUsers = 0;
    while (res.length != 0) {
        res = (await users.list(undefined, 100, undefined, lastId, "after")).users;
        for (const user of res) {
            let isOlderThenThreeMonths = (Date.now() / 1000 - user.registration) > 3600 * 24 * 31 * 3 // 3 Months
            if (!user.emailVerification && isOlderThenThreeMonths) {
                users.delete(user.$id)
                deletedUsers++;
            }
        }
        try {
            lastId = res[res.length - 1].$id
        } catch (_) {
            break;
        }
    }
    console.log(`Deleted ${deletedUsers} users.`)
})();
