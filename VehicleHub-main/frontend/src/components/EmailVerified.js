import React from 'react';
import { Link } from 'react-router-dom';

function EmailVerified() {
    return (
        <div className="email-verified-container">
            <h1>Email Verified!</h1>
            <p>Your email has been successfully verified.</p>
            <Link to="/login">
                <button>Back to Login</button>
            </Link>
        </div>
    );
}

export default EmailVerified;
