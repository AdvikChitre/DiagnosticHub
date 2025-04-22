// Import required modules
const express = require('express');
const bodyParser = require('body-parser');
const morgan = require('morgan');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2');
require('dotenv').config();

// Create Express app
const app = express();

// Configure environment variables
const port = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

// Create MySQL connection pool
const pool = mysql.createPool({
    connectionLimit: 10,
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || 'password',
    database: 'diagnostichub'
}).promise();

// Test database connection
pool.getConnection()
    .then(connection => {
        console.log('Connected to database');
        connection.release();
    })
    .catch(err => {
        console.error('Database connection error:', err);
    });

// Apply middleware
app.use(bodyParser.json()); // Parse JSON request bodies
app.use(morgan('dev'));     // HTTP request logging
app.use(cors());            // Enable CORS


// --- Private API -- //

// Check server and database
app.get('/health', async (req, res) => {
    try {
        const connection = await pool.getConnection();
        connection.release();
        res.status(200).json({ 
            status: 'OK',
            database: 'connected',
            uptime: process.uptime()
        });
    } catch (err) {
        console.error('Database connection error:', err);
        res.status(500).json({ database: 'error' });
    }
});

// Create account with billing agreement
// TODO

// Login endpoint that issues a JWT token
app.post('/api/login', async (req, res) => {
    const { name, password } = req.body;
    try {
        const [rows] = await pool.query('SELECT id,password FROM manufacturers WHERE name = ?', [name]);

        // If user not found or credentials don't match
        if (rows.length === 0 || password !== rows[0].password) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        // Generate JWT token
        const manufacturerID = rows[0].id;
        const token = jwt.sign({ manufacturerID }, JWT_SECRET, { expiresIn: '1h' });
        res.status(200).json({ message: 'Login successful', token });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Database error' });
    }
});
  
// JWT authentication middleware
function authenticate(req, res, next) {
    // Expect header: Authorization: Bearer <token>
    const authHeader = req.headers['authorization'];
    if (!authHeader) {
        return res.status(401).json({ error: 'No token provided' });
    }
    const token = authHeader.split(' ')[1];
    jwt.verify(token, JWT_SECRET, (err, decoded) => {
        if (err) {
            return res.status(401).json({ error: 'Unauthorized' });
        }
        req.user = decoded;
        next();
    });
}

// Get info of all wearables of a user
app.get('/api/wearables', authenticate, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT id,name FROM wearables WHERE manufacturer = ?', [req.user.manufacturerID]);
        res.status(200).json({ wearables: rows });
    }
    catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Add wearable
app.put('/api/wearable/add', authenticate, async (req, res) => {
    // TODO: add data to db. If exists, overwrite
    const { name } = req.body;
    try {
        const response = await pool.query('INSERT INTO wearables (name, manufacturer) VALUES (?, ?)', [name, req.user.manufacturerID]);
        res.status(200).json({ message: 'success' });
    }
    catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Get wearable options
// TODO: convert to get with query params
app.post('/api/wearable/get', authenticate, async (req, res) => {
    try {
        const { wearableID } = req.body;
        const [rows] = await pool.query('SELECT * FROM wearables WHERE id = ?', [wearableID]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Wearable not found' });
        }
        if (rows.length > 1) {
            return res.status(500).json({ error: 'Multiple wearables found' });
        }
        if (rows[0].manufacturer !== req.user.manufacturerID) {
            return res.status(403).json({ error: 'Unauthorized access' });
        }
        res.status(200).json({ data: rows[0] });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Update wearable options
app.put('/api/wearable/update', authenticate, async (req, res) => {
    const { wearableID, name, description, image_url, video_url, forwarding_address, forwarding_port, record_type, is_enabled } = req.body;
    try {
        const [rows] = await pool.query(
            'UPDATE wearables SET name=?, description=?, image_url=?, video_url=?, forwarding_address=?, forwarding_port=?, record_type=?, is_enabled=? WHERE id = ? AND manufacturer = ?'
            , [name, description, image_url, video_url, forwarding_address, forwarding_port, record_type, is_enabled, wearableID, req.user.manufacturerID]);
        if (rows.affectedRows === 0) {
            return res.status(404).json({ error: 'Wearable not found or unauthorized' });
        }
        res.status(200).json({ message: 'Wearable updated successfully' });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// --- Public API --- //

// Get all studies

// Create study
// TODO

// Update study

// Delete study

// Create device activation code
// TODO

// Confirm DoB
// TODO

// --- Start server --- //

// 404 handler
app.use((req, res, next) => {
    res.status(404).json({ error: 'Endpoint not found' });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).json({ error: 'Something went wrong!' });
});

app.listen(port, () => {
    console.log(`Server running on port ${port}`);
    console.log(`Available endpoints:`);
    console.log(`- GET http://localhost:${port}/health`);
    console.log(`- POST http://localhost:${port}/login`);
});
