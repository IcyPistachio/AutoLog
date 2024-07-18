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
            <img src={logo} alt="AutoLog Logo" />
            <form className="forgot-password-form" onSubmit={handleResetPassword}>
                <h1 className="title">RESET PASSWORD</h1>
                <p>Enter the email associated with the account password you are trying to reset.</p>
                <div className="vbox">
                    <label>
                    Email
                        <input
                            type="email"
                            placeholder="Email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            required
                        />
                    </label>
                </div>
                <div className="buttons">
                    <input type="submit" value="Send Reset Link" className="reset-button" />
                    <span className="message">{message}</span>
                    <button className="back-button" onClick={() => navigate(-1)}>Back</button>
                </div>
            </form>
        </div>
    );
}

export default ForgotPassword;
