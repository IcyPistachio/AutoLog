const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const path = require('path');
const nodemailer = require('nodemailer');
const crypto = require('crypto');         
const PORT = process.env.PORT || 5000;

const app = express();

app.set('port', (process.env.PORT || 5000));

app.use(cors());
app.use(bodyParser.json());

require('dotenv').config();
const url = process.env.MONGODB_URI;
const MongoClient = require('mongodb').MongoClient; 
const client = new MongoClient(url);
client.connect();

async function getNextSequenceValue(sequenceName) {
    const db = client.db('COP4331');

    const sequenceDocument = await db.collection('counters').findOneAndUpdate(
        { _id: sequenceName },
        { $inc: { sequence_value: 1 } },
        { returnOriginal: false, upsert: true }
    );

    return sequenceDocument.sequence_value;
}

// Helper function to validate email format
function validateEmail(email) {
    const re = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return re.test(String(email).toLowerCase());
}

// Setup Nodemailer
const transporter = nodemailer.createTransport({
    service: 'outlook',
    auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS
    }
});

function getBaseUrl() {
    if (process.env.NODE_ENV === 'production') {
        return 'https://cop4331vehiclehub-330c5739c6af.herokuapp.com';
    } else {
        return 'http://localhost:3000';
    }
}

app.post('/api/forgot-password', async (req, res) => {
    const { email } = req.body;
    if (!validateEmail(email)) {
        return res.status(400).json({ success: false, error: 'Invalid email format' });
    }

    const db = client.db('COP4331');
    const user = await db.collection('Users').findOne({ Email: email });

    if (!user) {
        return res.status(400).json({ success: false, error: 'No user found with that email address' });
    }

    const resetToken = crypto.randomBytes(20).toString('hex');
    const resetTokenExpiration = Date.now() + 3600000; // 1 hour from now
    const resetLink = `${getBaseUrl()}/reset-password/${resetToken}`;

    // Save the reset token and expiration to the user's record
    await db.collection('Users').updateOne({ Email: email }, { $set: { resetToken, resetTokenExpiration } });

    const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: 'Password Reset Request',
        text: `Please click the following link to reset your password: ${resetLink}`
    };

    transporter.sendMail(mailOptions, (err, info) => {
        if (err) {
            return res.status(500).json({ success: false, error: 'Failed to send email' });
        } else {
            res.status(200).json({ success: true });
        }
    });
});

// Endpoint to handle reset password
app.post('/api/reset-password', async (req, res) => {
    const { token, newPassword } = req.body;
    const db = client.db('COP4331');
    const user = await db.collection('Users').findOne({ resetToken: token });

    if (!user || user.resetTokenExpiration < Date.now()) {
        return res.status(400).json({ success: false, error: 'Invalid or expired reset token' });
    }

    // Update the user's password and invalidate the token
    await db.collection('Users').updateOne({ resetToken: token }, { $set: { Password: newPassword, resetToken: null, resetTokenExpiration: null } });

    res.status(200).json({ success: true });
});

// Registration endpoint with email verification
app.post('/api/register', async (req, res, next) => {
    const { firstName, lastName, email, password } = req.body;

    if (!validateEmail(email)) {
        return res.status(400).json({ error: 'Invalid email format' });
    }

    try {
        const db = client.db('COP4331');
        const existingUser = await db.collection('Users').findOne({ Email: email });

        if (existingUser) {
            return res.status(400).json({ error: 'User already exists with this email' });
        }

        const userId = await getNextSequenceValue('userId');
        const token = crypto.randomBytes(16).toString('hex');
        const newUser = {
            UserId: userId,
            FirstName: firstName,
            LastName: lastName,
            Email: email,
            Password: password,
            isVerified: false,
            verificationToken: token
        };

        await db.collection('Users').insertOne(newUser);

        const mailOptions = {
            from: process.env.EMAIL_USER,
            to: email,
            subject: 'Email Verification',
            text: `Hello ${firstName},\n\nPlease verify your email by clicking the link: \nhttp:\/\/${req.headers.host}\/api\/verify\/${token}\n\nThank You!\n`
        };

        transporter.sendMail(mailOptions, (err) => {
            if (err) {
                return res.status(500).json({ error: err.message });
            }
            res.status(200).json({ message: 'A verification email has been sent to ' + email + '.' });
        });
    } catch (e) {
        res.status(500).json({ error: e.toString() });
    }
});

// Email verification endpoint
app.get('/api/verify/:token', async (req, res, next) => {
    const db = client.db('COP4331');
    try {
        const user = await db.collection('Users').findOne({ verificationToken: req.params.token });

        if (!user) {
            return res.status(400).json({ error: 'Invalid or expired token.' });
        }

        await db.collection('Users').updateOne({ verificationToken: req.params.token }, { $set: { isVerified: true }, $unset: { verificationToken: "" } });

        // Redirect to a success page
        res.redirect(`${getBaseUrl()}/email-verified`);
    } catch (e) {
        res.status(500).json({ error: e.toString() });
    }
});


app.post('/api/addcar', async (req, res, next) => {
    // incoming: userId, make, model, year, odometer, color
    // outgoing: error, carId
    const { userId, make, model, year, odometer, color } = req.body;
    var error = '';
    try {
        const db = client.db('COP4331');
        const carId = await getNextSequenceValue('carId');
        const newCar = { carId, userId, make, model, year, odometer, color };
        const result = await db.collection('Cars').insertOne(newCar);
        res.status(200).json({ error: '', carId });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ error });
    }
});

app.post('/api/login', async (req, res, next) => {
    // incoming: email, password
    // outgoing: id, firstName, lastName, error
    var error = '';
    const { email, password } = req.body;
    const db = client.db('COP4331');
    const results = await db.collection('Users').find({ Email: email, Password: password }).toArray();

    var id = -1;
    var fn = '';
    var ln = '';
    if (results.length > 0) {
        id = results[0].UserId;
        fn = results[0].FirstName;
        ln = results[0].LastName;
    }
    var ret = { id: id, firstName: fn, lastName: ln, error: error };
    res.status(200).json(ret);
});

app.post('/api/searchcars', async (req, res, next) => {
    // incoming: userId, search
    // outgoing: results[], error
    var error = '';
    const { userId, search } = req.body;
    var _search = search.trim();
    const db = client.db('COP4331');
    try {
        const results = await db.collection('Cars').find({
            userId: userId,
            $or: [
                { make: { $regex: _search + '.*', $options: 'i' } },
                { model: { $regex: _search + '.*', $options: 'i' } },
                { year: { $regex: _search + '.*', $options: 'i' } },
                { color: { $regex: _search + '.*', $options: 'i' } },
                { odometer: { $regex: _search + '.*', $options: 'i' } }
            ]
        }).toArray();
        res.status(200).json({ results, error });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ results: [], error });
    }
});

app.post('/api/deletecar', async (req, res, next) => {
    // incoming: userId, carId
    // outgoing: error
    var error = '';
    const { userId, carId } = req.body;
    try {
        const db = client.db('COP4331');
        const resultNote = await db.collection('CarNotes').deleteMany({ carId });
        const result = await db.collection('Cars').deleteOne({ carId, userId });
        
        if (result.deletedCount === 0) {
            error = 'Car not found';
        }
        res.status(200).json({ error });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ error });
    }
});

app.post('/api/getcarinfo', async (req, res, next) => {
    // incoming: carId
    // outgoing: car, error
    var error = '';
    const { carId } = req.body;
    const db = client.db('COP4331');
    try {
        const car = await db.collection('Cars').findOne({ carId });
        res.status(200).json({ car, error });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ car: null, error });
    }
});

app.post('/api/updatecar', async (req, res, next) => {
    // incoming: userId, carId, make, model, year, odometer, color
    // outgoing: error
    const { carId, make, model, year, odometer, color } = req.body;
    var error = '';
    try {
        const db = client.db('COP4331');
        const result = await db.collection('Cars').updateOne(
            { carId },
            { $set: { make, model, year, odometer, color } }
        );
        if (result.matchedCount === 0) {
            error = 'Car not found';
        }
        res.status(200).json({ error });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ error });
    }
});

// Add a note
app.post('/api/addnote', async (req, res, next) => {
    // incoming: carId, note, type, miles, dateCreated
    // outgoing: error, noteId
    const { carId, note, type, miles, dateCreated } = req.body;
    var error = '';
    try {
        const db = client.db('COP4331');
        const noteId = await getNextSequenceValue('noteId');
        const newNote = { noteId, carId, note, type, miles, dateCreated }; // Include type and miles
        const result = await db.collection('CarNotes').insertOne(newNote);
        res.status(200).json({ error: '', noteId });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ error });
    }
});

// Delete a note
app.post('/api/deletenote', async (req, res, next) => {
    // incoming: carId, noteId
    // outgoing: error
    const { carId, noteId } = req.body;
    var error = '';
    try {
        const db = client.db('COP4331');
        const result = await db.collection('CarNotes').deleteOne({ carId, noteId });
        
        if (result.deletedCount === 0) {
            error = 'Note not found';
        }
        res.status(200).json({ error });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ error });
    }
});

// Fetch notes for a car
app.post('/api/getcarnotes', async (req, res, next) => {
    // incoming: carId
    // outgoing: notes, error
    var error = '';
    const { carId } = req.body;
    const db = client.db('COP4331');
    try {
        const notes = await db.collection('CarNotes').find({ carId }).toArray();
        res.status(200).json({ notes, error });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ notes: [], error });
    }
});

app.post('/api/updatenote', async (req, res, next) => {
    // incoming: carId, noteId, note, type, miles, dateCreated
    // outgoing: error
    const { carId, noteId, note, type, miles, dateCreated } = req.body;
    var error = '';
    try {
        const db = client.db('COP4331');
        const result = await db.collection('CarNotes').updateOne(
            { carId, noteId },
            { $set: { note, type, miles, dateCreated } } // Include type and miles
        );

        if (result.matchedCount === 0) {
            error = 'Note not found';
        }
        res.status(200).json({ error });
    } catch (e) {
        error = e.toString();
        res.status(200).json({ error });
    }
});

app.use((req, res, next) => {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader(
        'Access-Control-Allow-Headers',
        'Origin, X-Requested-With, Content-Type, Accept, Authorization'
    );
    res.setHeader(
        'Access-Control-Allow-Methods',
        'GET, POST, PATCH, DELETE, OPTIONS'
    );
    next();
});

app.listen(PORT, () => 
{
    console.log('Server listening on port ' + PORT);
});

// Add the following for the correct retrieval path -
// For Heroku deployment

// Server static assets if in production
if (process.env.NODE_ENV === 'production') 
{
    // Set static folder
    app.use(express.static('frontend/build'));


    app.get('*', (req, res) => 
    {
    res.sendFile(path.resolve(__dirname, 'frontend', 'build', 'index.html'));
    });
}
    
