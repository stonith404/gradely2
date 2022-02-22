import { users, database } from "../config.js"
import Query from "node-appwrite/lib/query.js"

// Currently there is an emoji and name key in the db. This function merges the meoji to the name.
async function emojiToTitle() {
    // add an index to enable filtering
    await database.createIndex("60f40d0ed5da4", "emoji-migration", "key", ["emoji"])
    let lastId;
    let res = [""];
    let migratedDocuments = 0;
    while (res.length != 0) {
        res = (await database.listDocuments("60f40d0ed5da4", [Query.notEqual("emoji", "")], undefined, 100, lastId, "after")).documents;
        for (const subject of res) {
            migratedDocuments++;
            database.updateDocument("60f40d0ed5da4", subject.$id, { "name": subject.emoji + " " + subject.name, "emoji": "" })
        }
        try {
            lastId = res[res.length - 1].$id
        } catch (_) {
            break;
        }
    }
    // Delete the index
    c.database.deleteIndex("60f40d0ed5da4", "emoji-migration")
    console.log("Migrated " + migratedDocuments + " documents.")
}

async function deleteBlockedUsers() {
    let res = [""];
    let lastId;
    let deletedUsers = 0;
    while (res.length != 0) {
        res = (await users.list(undefined, 100, undefined, lastId, "after")).users;
        for (const user of res) {
            if (!user.status) {
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
}

emojiToTitle()
deleteBlockedUsers()