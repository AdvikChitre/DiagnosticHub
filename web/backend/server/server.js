// Import required modules
const express = require('express');
const bodyParser = require('body-parser');
const morgan = require('morgan');
const cors = require('cors');
const jwt = require('jsonwebtoken');
const mysql = require('mysql2');
const path = require('path');
require('dotenv').config();

// Create Express app
const app = express();

// Configure environment variables
const port = process.env.PORT || 3000;
const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';

app.listen(port, '0.0.0.0', () => { // Bind to all interfaces
    console.log(`Server running at http://0.0.0.0:${port}`);
  });

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

// Get minimal information of all wearables of a manufacturer
app.get('/api/wearables/list', authenticate, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT id,name FROM wearables WHERE manufacturer = ?', [req.user.manufacturerID]);
        res.status(200).json({ wearables: rows });
    }
    catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Add wearable linked to manufacturer
app.put('/api/wearables/add', authenticate, async (req, res) => {
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

// Get current configuration of a wearable
// TODO: convert to GET with query params
app.post('/api/wearables/get', authenticate, async (req, res) => {
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

// Update configuration of a wearable
app.put('/api/wearables/update', authenticate, async (req, res) => {
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

// Get all questions for a device
app.get('/api/wearables/questions/:wearableID', async (req, res) => {
    const { wearableID } = req.params;
    try {
        const [rows] = await pool.query('SELECT * FROM questions WHERE wearable = ?', [wearableID]);
        if (rows.length === 0) {
            return res.status(404).json({ error: 'No questions found for this device' });
        }
        res.status(200).json({ questions: rows });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Add question for a device
app.post('/api/wearables/questions/add', authenticate, async (req, res) => {
    const { wearableID, question_text } = req.body;
    console.log('Received request to add question:', req.body);
    if (!wearableID || !question_text) {
        return res.status(400).json({ error: 'Missing wearableID or question text' });
    }
    try {
        // Verify the wearable exists and belongs to the manufacturer
        const [wearableRows] = await pool.query(
            'SELECT id FROM wearables WHERE id = ? AND manufacturer = ?',
            [wearableID, req.user.manufacturerID]
        );
        if (wearableRows.length === 0) {
            return res.status(404).json({ error: 'Wearable not found or unauthorized' });
        }

        // Insert the new question into the database
        const [result] = await pool.query(
            'INSERT INTO questions (wearable, question) VALUES (?, ?)',
            [wearableID, question_text]
        );
        return res.status(200).json({ message: 'Question added successfully', questionID: result.insertId });
    } catch (error) {
        console.error('Database error:', error);
        return res.status(500).json({ error: 'Database error' });
    }
});

// Update a question of a device
app.put('/api/wearables/questions/update', authenticate, async (req, res) => {
    const { questionId, editedQuestion } = req.body;
    if (!questionId || !editedQuestion) {
        return res.status(400).json({ error: 'Missing questionId or editedQuestion' });
    }
    try {
        // Retrieve the question to confirm it exists and get its wearable id
        const [questionRows] = await pool.query('SELECT wearable FROM questions WHERE id = ?', [questionId]);
        if (questionRows.length === 0) {
            return res.status(404).json({ error: 'Question not found' });
        }
        const wearableId = questionRows[0].wearable;
        // Verify that the wearable belongs to the authenticated manufacturer
        const [wearableRows] = await pool.query('SELECT id FROM wearables WHERE id = ? AND manufacturer = ?', [wearableId, req.user.manufacturerID]);
        if (wearableRows.length === 0) {
            return res.status(403).json({ error: 'Unauthorized access' });
        }
        // Update the question text
        await pool.query('UPDATE questions SET question = ? WHERE id = ?', [editedQuestion, questionId]);
        res.status(200).json({ message: 'Question updated successfully' });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

app.delete('/api/wearables/questions/delete', authenticate, async (req, res) => {
    const { questionId } = req.body;
    if (!questionId) {
        return res.status(400).json({ error: 'Missing questionId' });
    }
    try {
        const [questionRows] = await pool.query('SELECT wearable FROM questions WHERE id = ?', [questionId]);
        if (questionRows.length === 0) {
            return res.status(404).json({ error: 'Question not found' });
        }
        const wearableId = questionRows[0].wearable;
        const [wearableRows] = await pool.query('SELECT id FROM wearables WHERE id = ? AND manufacturer = ?', [wearableId, req.user.manufacturerID]);
        if (wearableRows.length === 0) {
            return res.status(403).json({ error: 'Unauthorized access' });
        }
        const [deleteResult] = await pool.query('DELETE FROM questions WHERE id = ?', [questionId]);
        if (deleteResult.affectedRows === 0) {
            return res.status(500).json({ error: 'Error deleting question' });
        }
        res.status(200).json({ message: 'Question deleted successfully' });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// --- Public API --- //

// Get all studies
app.get('/api/study/list', authenticate, async (req, res) => {
    try {
        const [rows] = await pool.query('SELECT * FROM studies WHERE manufacturer = ?', [req.user.manufacturerID]);
        return res.status(200).json({ studies: rows });
    } catch (error) {
        console.error('Database error:', error);
        return res.status(500).json({ error: 'Database error' });
    }
});

// Create study
app.post('/api/study/add', authenticate, async (req, res) => {
    const { wearableID, start_date, end_date, DoB } = req.body;
    try {
        const [rows] = await pool.query('INSERT INTO studies (wearable, start_date, end_date, date_of_birth) VALUES (?, ?, ?, ?)', [wearableID, start_date, end_date, DoB]);
        return res.status(200).json({ message: 'Study created successfully', studyID: rows.insertId });
    } catch (error) {
        console.error('Database error:', error);
        return res.status(500).json({ error: 'Database error' });
    }
});

// Update study
app.put('/api/study/update', authenticate, async (req, res) => {
    const { studyID, start_date, end_date, date_of_birth, status } = req.body;
    if (!studyID) {
        return res.status(400).json({ error: 'Missing studyID' });
    }
    try {
        // Retrieve the study along with its wearable's manufacturer
        const [rows] = await pool.query(
            `SELECT s.id, w.manufacturer 
             FROM studies s
             JOIN wearables w ON s.wearable = w.id
             WHERE s.id = ?`,
            [studyID]
        );
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Study not found' });
        }
        // Ensure that the authenticated manufacturer is authorized to update the study
        if (rows[0].manufacturer !== req.user.manufacturerID) {
            return res.status(403).json({ error: 'Unauthorized access' });
        }
        // Update the study with provided fields
        await pool.query(
            `UPDATE studies 
             SET start_date = ?, end_date = ?, date_of_birth = ?, status = ? 
             WHERE id = ?`,
            [start_date, end_date, date_of_birth, status, studyID]
        );
        res.status(200).json({ message: 'Study updated successfully' });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Delete study
app.delete('/api/study/delete', authenticate, async (req, res) => {
    const { studyID } = req.body;
    if (!studyID) {
        return res.status(400).json({ error: 'Missing studyID' });
    }
    try {
        const [rows] = await pool.query(
            `SELECT s.id, w.manufacturer 
             FROM studies s
             JOIN wearables w ON s.wearable = w.id
             WHERE s.id = ?`,
            [studyID]
        );
        if (rows.length === 0) {
            return res.status(404).json({ error: 'Study not found' });
        }
        if (rows[0].manufacturer !== req.user.manufacturerID) {
            return res.status(403).json({ error: 'Unauthorized access' });
        }
        const [deleteResult] = await pool.query(
            'DELETE FROM studies WHERE id = ?',
            [studyID]
        );
        if (deleteResult.affectedRows === 0) {
            return res.status(500).json({ error: 'Error deleting study' });
        }
        res.status(200).json({ message: 'Study deleted successfully' });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Create device activation code
// TODO: make secure
app.post('/api/studies/activation', authenticate, async (req, res) => {
    const { deviceID } = req.body;
    try {
        const activationCode = Math.floor(Math.random() * 900000) + 100000;
        const [result] = await pool.query(
            'UPDATE manufacturers SET activation_code = ? WHERE id = ?',
            [activationCode, deviceID, req.user.manufacturerID]
        );
        if (result.affectedRows === 0) {
            return res.status(404).json({ error: 'Device not found' });
        }
        res.status(200).json({ message: 'Activation code updated successfully', activationCode });
        console.log
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// --- Device API --- //

// Get device config with questions added for each wearable
app.get('/api/wearables/config', async (req, res) => {
    try {
        // Get all wearables
        const [wearables] = await pool.query('SELECT * FROM wearables');
        if (wearables.length === 0) {
            return res.status(404).json({ error: 'No devices' });
        }
        // Get all questions
        const [questions] = await pool.query('SELECT * FROM questions');

        // Group questions by wearable id (using column "wearable" from the questions table)
        const questionsByWearable = {};
        questions.forEach(q => {
            const wearableId = q.wearable;
            if (!questionsByWearable[wearableId]) {
                questionsByWearable[wearableId] = [];
            }
            questionsByWearable[wearableId].push(q);
        });

        // Add questions field to each wearable
        wearables.forEach(wearable => {
            wearable.questions = questionsByWearable[wearable.id] || [];
        });

        return res.status(200).json({ wearables });
    } catch (error) {
        console.error('Database error:', error);
        return res.status(500).json({ error: 'Database error' });
    }
});

// Confirm DoB
app.post('/api/studies/confirm', async (req, res) => {
    const { DoB, activationCode } = req.body;
    console.log('Received request to confirm DoB:', req.body);
    try {
        // Retrieve the study by deviceID (assumed as study ID)
        const [studies] = await pool.query(
            'SELECT id, wearable, date_of_birth, status FROM studies WHERE activation_code = ?',
            [activationCode]
        );
        console.log('Studies found:', studies);
        if (studies.length === 0) {
            return res.status(404).json({ error: 'Study not found' });
        }

        const study = studies[0];
        // Check if the provided DoB matches the stored
        const date = new Date(study.date_of_birth);
        const day = ('0' + date.getUTCDate()).slice(-2);
        const month = ('0' + (date.getUTCMonth() + 1)).slice(-2);
        const year = date.getUTCFullYear();
        const formattedStudyDoB = `${day}/${month}/${year}`;
        if (DoB !== formattedStudyDoB) {
            return res.status(400).json({ error: 'Date of birth does not match' });
        }
        // Only update if current status is 'planned'
        if (study.status !== 'planned') {
            return res.status(400).json({ error: 'Study is not in planned status' });
        }
        // Update status to 'active'
        const [updateResult] = await pool.query(
            'UPDATE studies SET status = ? WHERE id = ?',
            ['active', study.id]
        );
        // Get device name for connection process
        const [wearableRows] = await pool.query(
            'SELECT name FROM wearables WHERE id = ?',
            [study.wearable]
        );
        res.status(200).json({ wearableName: wearableRows[0].name, studyID: study.id });
    } catch (error) {
        console.error('Database error:', error);
        res.status(500).json({ error: 'Database error' });
    }
});

// Firmware update
app.get('/api/receiver/firmware', async (req, res) => {
    try {
        const firmwarePath = path.join(__dirname, 'firmware', 'qt-firmware.bin');
        res.download(firmwarePath, 'qt-firmware.bin', (err) => {
            if (err) {
                console.error('Firmware download error:', err);
                return res.status(500).json({ error: 'Firmware download error' });
            }
        });
    } catch (error) {
        console.error('Error during firmware update:', error);
        res.status(500).json({ error: 'Internal server error' });
    }
});

// Test post request
app.post('/api/test', async (req, res) => {
    const { packets } = req.body;
    console.log('Received test request:', packets);
    res.status(200).json({ message: 'Test successful', data: packets });
});


// Get latest version

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
