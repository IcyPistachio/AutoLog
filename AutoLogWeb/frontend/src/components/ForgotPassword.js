import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './DefaultStyles.css';  // Import the shared CSS
import './ForgotPassword.css';
import logo from '../images/Group 19.png';

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
        <div className="container-center" style={{ width: '50vw', height: '70vh', minHeight: '90vh' }}>
            <img src={logo} alt="AutoLog Logo" />
            <form className="form-standard" onSubmit={handleResetPassword}>
                <h1 className="title">RESET PASSWORD</h1>
                <p>Enter the email to the associated account.</p>

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

                <div className="spacer"></div>

                <div className="buttons">
                    <button className="button-standard accent-button" >SEND RESET LINK</button>
                    <span className="message">{message}</span>
                    <div className="spacer"></div>
                    <button className="button-standard default-button" onClick={() => navigate(-1)}>BACK</button>
                </div>
            </form >
        </div >
    );
}

export default ForgotPassword;
