import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import './Login.css'; 

function Login() {
    const [loginEmail, setLoginEmail] = useState('');
    const [loginPassword, setLoginPassword] = useState('');
    const [message, setMessage] = useState('');
    const navigate = useNavigate();
    var bp = require('./Path.js');

    const doLogin = async (event) => {
        event.preventDefault();

        var obj = { email: loginEmail, password: loginPassword };
        var js = JSON.stringify(obj);

        try {
            const response = await fetch(bp.buildPath('api/login'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' }
            });

            const res = await response.json();

            if (res.id <= 0) {
                setMessage('Email/Password combination incorrect');
            } else {
                if (!res.isVerified) {
                    setMessage('Email is not verified. Please verify your email to log in.');
                    return;
                }

                var user = { firstName: res.firstName, lastName: res.lastName, id: res.id };
                localStorage.setItem('user_data', JSON.stringify(user));
                setMessage('');
                navigate('/garage');
            }
        } catch (e) {
            alert(e.toString());
            return;
        }
    };

    return (
        <div className="login-container">
            <h1 className="title">VehicleHub</h1>
            <span id="inner-title">LOG IN</span>
            <input
                type="email"
                id="loginEmail"
                placeholder="Email"
                value={loginEmail}
                onChange={(e) => setLoginEmail(e.target.value)}
            />
            <input
                type="password"
                id="loginPassword"
                placeholder="Password"
                value={loginPassword}
                onChange={(e) => setLoginPassword(e.target.value)}
            />
            <input
                type="submit"
                id="loginButton"
                className="buttons"
                value="Log In"
                onClick={doLogin}
            />
            <span id="loginResult" className="message">{message}</span>
            <div className="separator">
                <hr className="line" />
                <span className="or">or</span>
                <hr className="line" />
            </div>
            <button className="signup-button" onClick={() => navigate('/register')}>
                Sign Up
            </button>
            <div className="forgot-password-link">
                <Link to="/forgot-password">Forgot password?</Link>
            </div>
        </div>
    );
}

export default Login;
