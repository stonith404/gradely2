import c from "../config.js"
import Query from "node-appwrite/lib/query.js"

// Currently there is an emoji and name key in the db. This function merges the meoji to the name.
async function emojiToTitle() {
    // add an index to enable filtering
    await c.database.createIndex("60f40d0ed5da4", "emoji-migration", "key", ["emoji"])
    let lastId;
    let res = [""];
    let migratedDocuments = 0;
    while (res.length != 0) {
        res = (await c.database.listDocuments("60f40d0ed5da4", [Query.notEqual("emoji", "")], undefined, 2, lastId, "after")).documents;
        for (const subject of res) {
            migratedDocuments++;
            console.log(subject.name + " " + subject.emoji)
            c.database.updateDocument("60f40d0ed5da4", subject.$id, { "name": subject.name + " " + subject.emoji, "emoji": "" })
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

emojiToTitle()