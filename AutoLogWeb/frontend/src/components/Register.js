import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './Register.css';

function Register() {
    const [firstName, setFirstName] = useState('');
    const [lastName, setLastName] = useState('');
    const [email, setEmail] = useState('');
    const [password, setPassword] = useState('');
    const [confirmPassword, setConfirmPassword] = useState('');
    const [message, setMessage] = useState('');
    const [passwordValidations, setPasswordValidations] = useState({
        length: false,
        lowercase: false,
        uppercase: false,
        number: false,
        symbol: false,
        noSpaces: false,
    });
    const [isPasswordMatching, setIsPasswordMatching] = useState(false);
    const [isPasswordFocused, setIsPasswordFocused] = useState(false);
    const [isConfirmPasswordFocused, setIsConfirmPasswordFocused] = useState(false);

    const navigate = useNavigate();
    var bp = require('./Path.js');

    useEffect(() => {
        const checkPasswordMatch = () => {
            setIsPasswordMatching(password === confirmPassword);
        };

        checkPasswordMatch();
    }, [password, confirmPassword]);

    const handleRegister = async (event) => {
        event.preventDefault();
        setMessage('');

        if (!validateEmail(email)) {
            setMessage('Invalid email address');
            return;
        }

        if (Object.values(passwordValidations).some((valid) => !valid)) {
            setMessage('Password does not meet the criteria');
            return;
        }

        if (password !== confirmPassword) {
            setMessage('Passwords do not match');
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
                setConfirmPassword('');
                setPasswordValidations({
                    length: false,
                    lowercase: false,
                    uppercase: false,
                    number: false,
                    symbol: false,
                    noSpaces: false,
                });
                setIsPasswordMatching(false);
            }
        } catch (e) {
            setMessage(e.toString());
        }
    };

    const validateEmail = (email) => {
        const re = /^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$/;
        return re.test(email);
    };

    const handlePasswordChange = (e) => {
        const newPassword = e.target.value;
        setPassword(newPassword);
        setPasswordValidations({
            length: newPassword.length >= 8 && newPassword.length <= 20,
            lowercase: /[a-z]/.test(newPassword),
            uppercase: /[A-Z]/.test(newPassword),
            number: /\d/.test(newPassword),
            symbol: /[@$!%*?&]/.test(newPassword),
            noSpaces: /^\S*$/.test(newPassword),
        });
    };

    const handleConfirmPasswordChange = (e) => {
        const newConfirmPassword = e.target.value;
        setConfirmPassword(newConfirmPassword);
    };

    const isPasswordValid = Object.values(passwordValidations).every((valid) => valid);

    return (
        <div className="register-container">
            <h1 className="title">Register</h1>
            <form className="register-form" onSubmit={handleRegister}>
                <input type="text" placeholder="First Name" value={firstName} onChange={(e) => setFirstName(e.target.value)} required />
                <input type="text" placeholder="Last Name" value={lastName} onChange={(e) => setLastName(e.target.value)} required />
                <input type="email" placeholder="Email" value={email} onChange={(e) => setEmail(e.target.value)} required />
                <div className="password-container">
                    <input
                        type="password"
                        placeholder="Password"
                        value={password}
                        onChange={handlePasswordChange}
                        onFocus={() => setIsPasswordFocused(true)}
                        onBlur={() => setIsPasswordFocused(false)}
                        required
                    />
                    {isPasswordValid && <span className="checkmark">✔</span>}
                    {!isPasswordValid && <span className="crossmark">✖</span>}
                </div>
                {isPasswordFocused && (
                    <ul className="password-requirements">
                        <li className={passwordValidations.length ? 'valid' : 'invalid'}>8-20 characters</li>
                        <li className={passwordValidations.lowercase ? 'valid' : 'invalid'}>At least one lowercase letter</li>
                        <li className={passwordValidations.uppercase ? 'valid' : 'invalid'}>At least one uppercase letter</li>
                        <li className={passwordValidations.number ? 'valid' : 'invalid'}>At least one number</li>
                        <li className={passwordValidations.symbol ? 'valid' : 'invalid'}>At least one symbol (@, $, !, %, *, ?, &)</li>
                        <li className={passwordValidations.noSpaces ? 'valid' : 'invalid'}>No spaces</li>
                    </ul>
                )}
                <div className="password-container">
                    <input
                        type="password"
                        placeholder="Confirm Password"
                        value={confirmPassword}
                        onChange={handleConfirmPasswordChange}
                        onFocus={() => setIsConfirmPasswordFocused(true)}
                        onBlur={() => setIsConfirmPasswordFocused(false)}
                        required
                    />
                    {isPasswordMatching && <span className="checkmark">✔</span>}
                    {!isPasswordMatching && <span className="crossmark">✖</span>}
                </div>
                {isConfirmPasswordFocused && (
                    <p className={isPasswordMatching ? 'valid' : 'invalid'}>
                        {isPasswordMatching ? '✔ Passwords match' : '✖ Passwords do not match'}
                    </p>
                )}
                <input type="submit" value="Register" />
                <span className="message">{message}</span>
            </form>
            <button className="back-button" onClick={() => navigate(-1)}>Back</button>
        </div>
    );
}

export default Register;
