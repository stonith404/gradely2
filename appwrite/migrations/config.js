import { Client, Users, Database } from "node-appwrite";
import dotenv from "dotenv";
dotenv.config()

let client = new Client();
client
    .setEndpoint(process.env.APPWRITE_ENDPOINT)
    .setProject("60f40cb212896")
    .setKey(
        process.env.APPWRITE_API_KEY
    );

let users = new Users(client);
let database = new Database(client);

export {
    client,
    users,
    database
}