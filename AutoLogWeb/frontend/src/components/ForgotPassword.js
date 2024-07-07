import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './ForgotPassword.css';
import Form from 'react-bootstrap/Form';
import logo from '../images/Group 19.png'

function ForgotPassword() {
    const [email, setEmail] = useState('');
    const [message, setMessage] = useState('');
    const navigate = useNavigate();

    var bp = require('./Path.js');

    const handleResetPassword = async (event) => {
        event.preventDefault();
        const response = await fetch(bp.buildPath('api/forgot-password'), {
            method: 'POST',
            body: JSON.stringify({ email }),
            headers: { 'Content-Type': 'application/json' }
        });

        const result = await response.json();
        if (result.success) {
            navigate('/password-reset-link-sent');
        } else {
            setMessage(result.error);
        }
    };

    return (
        <div className="forgot-password-container">
            <img src={logo} alt="AutoLog Logo" className="logo" />
            <div className='textContainer'>
                <h1>RESET PASSWORD</h1> 
                <p>Enter the email associated with the account password you are trying to reset.</p>
                <form onSubmit={handleResetPassword}>
                    <input
                        type="email"
                        placeholder="Email"
                        value={email}
                        onChange={(e) => setEmail(e.target.value)}
                        required
                    />
                    <input type="submit" value="Send Reset Link" />
                </form>
                <span className="message">{message}</span>
                <button onClick={() => navigate(-1)}>Back</button>
            </div>
        </div>
    );
}

export default ForgotPassword;
