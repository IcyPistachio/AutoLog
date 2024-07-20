import React, { useState } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import Form from 'react-bootstrap/Form';
import './DefaultStyles.css';
import './Login.css';
import garageSound from '../sounds/garageSound.mp3';
import logo from '../images/Group 19.png';

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
                playGarageSound(); // Call function to play garage sound
                navigate('/garage');
            }
        } catch (e) {
            alert(e.toString());
            return;
        }
    };

    const playGarageSound = () => {
        const audio = new Audio(garageSound); // Create a new audio object
        audio.play(); // Play the sound
        setTimeout(() => {
            audio.pause(); // Pause after 5 seconds
            audio.currentTime = 0; // Reset audio time for next play
        }, 5000); // Play for 5 seconds
    };

    return (
        <div className="container-center" style={{ width: '50vw', height: '70vh', minHeight: '90vh' }}>
            <img src={logo} alt="AutoLog Logo" />
            <form className="form-standard" onSubmit={doLogin}>
                <h1 className="title">LOG IN</h1>

                <div className="vbox">
                    <label>
                        Email:
                        <input
                            type="email"
                            id="loginEmail"
                            placeholder="Email"
                            value={loginEmail}
                            onChange={(e) => setLoginEmail(e.target.value)}
                        />
                    </label>
                    <label>
                        Password:
                        <input
                            type="password"
                            id="loginPassword"
                            placeholder="Password"
                            value={loginPassword}
                            onChange={(e) => setLoginPassword(e.target.value)}
                        />
                    </label>
                </div>

                <div className="forgot-password">
                    <Link className="forgot-password-link" to="/forgot-password">Forgot password?</Link>
                </div>

                <div className="buttons">
                    <button type="submit" className="button-standard accent-button">
                        LOG IN
                    </button>

                    <span id="loginResult" className="message">{message}</span>

                    <div className="separator">
                        <hr className="line" />
                        <span className="or">OR</span>
                        <hr className="line" />
                    </div>

                    <button className="button-standard default-button" onClick={() => navigate('/register')}>
                        SIGN UP
                    </button>
                </div>
            </form >
        </div >
    );
}

export default Login;
