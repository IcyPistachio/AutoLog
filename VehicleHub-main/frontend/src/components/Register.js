import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './Register.css';

function Register() {
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [message, setMessage] = useState('');
    const navigate = useNavigate();

    var bp = require('./Path.js');

    const handleRegister = async (event) => {
        event.preventDefault();
        setMessage('');
        if (!validateEmail(email)) {
            setMessage('Invalid email address');
            return;
        }

        const obj = { firstName, lastName, email, password };
        const js = JSON.stringify(obj);

        try {
            const response = await fetch(bp.buildPath('api/register'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' }
            });
            const res = await response.json();
            if (res.error) {
                setMessage(res.error);
            } else {
                setMessage('Registration successful. Please check your email to verify your account.');
                setFirstName('');
                setLastName('');
                setEmail('');
                setPassword('');
            }
        } catch (e) {
            setMessage(e.toString());
        }
    };

    const validateEmail = (email) => {
        const re = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;
        return re.test(email);
    };

    return (
        <div className="register-container">
            <h1 className="title">Register</h1>
            <form className="register-form" onSubmit={handleRegister}>
                <input type="text" placeholder="First Name" value={firstName} onChange={(e) => setFirstName(e.target.value)} required />
                <input type="text" placeholder="Last Name" value={lastName} onChange={(e) => setLastName(e.target.value)} required />
                <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} required />
                <input type="password" placeholder="Password" value={password} onChange={(e) => setPassword(e.target.value)} required />
                <input type="submit" value="Register" />
                <span className="message">{message}</span>
            </form>
            <button className="back-button" onClick={() => navigate(-1)}>Back</button>
        </div>
    );
}

export default Register;
