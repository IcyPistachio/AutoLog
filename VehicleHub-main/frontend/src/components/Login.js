import React, { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import './Login.css'; // Assuming you have a CSS file for styling

function Login() {
    var loginEmail;
    var loginPassword;
    const [message, setMessage] = useState('');
    const navigate = useNavigate();

    useEffect(() => {
        // Add a class to the body when the component mounts
        document.body.classList.add('login-body');

        // Remove the class from the body when the component unmounts
        return () => {
            document.body.classList.remove('login-body');
        };
    }, []);

    var bp = require('./Path.js');

    const doLogin = async event => {
        event.preventDefault();
        var obj = { email: loginEmail.value, password: loginPassword.value };
        var js = JSON.stringify(obj);
        try {
            const response = await fetch(bp.buildPath('api/login'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' }
            });
            var res = JSON.parse(await response.text());
            if (res.id <= 0) {
                setMessage('Email/Password combination incorrect');
            } else {
                var user = { firstName: res.firstName, lastName: res.lastName, id: res.id };
                localStorage.setItem('user_data', JSON.stringify(user));
                setMessage('');
                window.location.href = '/cars';
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
            <input type="email" id="loginEmail" placeholder="Email" ref={(c) => loginEmail = c} />
            <input type="password" id="loginPassword" placeholder="Password" ref={(c) => loginPassword = c} />
            <input type="submit" id="loginButton" className="buttons" value="Log In" onClick={doLogin} />
            <span id="loginResult" className="message">{message}</span>
            <div className="separator">
                <hr className="line" />
                <span className="or">or</span>
                <hr className="line" />
            </div>
            <button className="signup-button" onClick={() => navigate('/register')}>Sign Up</button>
            <div className="forgot-password-link">
                <Link to="/forgot-password">Forgot password?</Link>
            </div>
        </div>
    );
}

export default Login;
