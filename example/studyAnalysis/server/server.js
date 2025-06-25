const express = require('express');
const sqlite3 = require('sqlite3');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3001;
app.use(bodyParser.json());
app.use(cors());
app.use(bodyParser.json());

// Connect to SQLite database (or create it if it doesn't exist)
const db = new sqlite3.Database('./data.db', (err) => {
    if (err) {
        console.error("Error opening database:", err.message);
        process.exit(1);
    }
    console.log("Connected to SQLite database.");
});

// Create the packets table if it doesn't exist
db.run(`CREATE TABLE IF NOT EXISTS packets (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp INTEGER,
    serviceUuid TEXT,
    charUuid TEXT,
    mac TEXT,
    data TEXT
)`, (err) => {
    if (err) {
        console.error("Error creating table:", err.message);
    }
});

// POST API to store packets
app.post('/api/wearable/data', (req, res) => {
    // console.log("Received POST request to /api/wearable/data");
    console.log("Request body:", req.body);
    const packets = req.body.packets;

    const insertStmt = db.prepare(`INSERT INTO packets (timestamp, serviceUuid, charUuid, mac, data)
                                                                     VALUES (?, ?, ?, ?, ?)`);
    
    db.serialize(() => {
        for (const packet of packets) {
            // Assuming the packet has the properties: timestamp, serviceUuid, charUuid, mac, and data.
            insertStmt.run(
                packet.timestamp,
                packet.serviceUuid,
                packet.charUuid,
                packet.mac,
                packet.data
            );
        }
        insertStmt.finalize(err => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.json({ message: "Packets inserted successfully." });
        });
    });
});

// GET API to fetch all data points for a specific MAC address using URL parameter
app.get('/api/study/:mac', (req, res) => {
    const macAddress = req.params.mac;
    console.log(`Received GET request for MAC address: ${macAddress}`);
    db.all("SELECT * FROM packets WHERE mac = ?", [macAddress], (err, rows) => {
        if (err) {
            return res.status(500).json({ error: err.message });
        }
        res.json({ data: rows });
    });
});

// Catch-all route to return 404 as JSON instead of HTML
app.use((req, res) => {
    res.status(404).json({ error: "Not Found" });
});

// Start the server
app.listen(PORT, () => {
    console.log(`Server is running on port ${PORT}`);
});