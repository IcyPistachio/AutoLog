import React, { useState } from 'react';
import { useNavigate, useParams } from 'react-router-dom';

function ResetPassword() {
    const [newPassword, setNewPassword] = useState('');
    const [message, setMessage] = useState('');
    const navigate = useNavigate();
    const { token } = useParams(); // Assuming the token is passed as a URL parameter

    const app_name = 'cop4331vehiclehub-330c5739c6af';
    function buildPath(route) {
        if (process.env.NODE_ENV === 'production') {
            return 'https://' + app_name + '.herokuapp.com/' + route;
        } else {
            return 'http://localhost:5000/' + route;
        }
    }

    const handleResetPassword = async (event) => {
        event.preventDefault();
        const response = await fetch(buildPath('api/reset-password'), {
            method: 'POST',
            body: JSON.stringify({ token, newPassword }),
            headers: { 'Content-Type': 'application/json' }
        });

        const result = await response.json();
        if (result.success) {
            alert('Password reset successful');
            navigate('/login');
        } else {
            setMessage(result.error);
        }
    };

    return (
        <div className="reset-password-container">
            <h1>Reset Password</h1>
            <p>Enter a new password for your account</p>
            <form onSubmit={handleResetPassword}>
                <input
                    type="password"
                    placeholder="New Password"
                    value={newPassword}
                    onChange={(e) => setNewPassword(e.target.value)}
                    required
                />
                <input type="submit" value="Reset Password" />
            </form>
            <span className="message">{message}</span>
        </div>
    );
}

export default ResetPassword;
