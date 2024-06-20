import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import './App.css';
import LoginPage from './pages/LoginPage';
import CarPage from './pages/CarPage';
import CarUI from './components/CarUI';
import CarInfo from './components/CarInfo';
import Register from './components/Register';
import ForgotPassword from './components/ForgotPassword';
import PasswordResetLinkSent from './components/PasswordResetLinkSent';
import ResetPassword from './components/ResetPassword';
import EmailVerified from './components/EmailVerified'; 
import HomePage from './components/HomePage';

function App() {
    return (
        <Router>
            <Routes>
                <Route path="/" element={<HomePage />} /> {/* HomePage as the default route */}
                <Route path="/login" element={<LoginPage />} /> {/* Separate route for Login */}
                <Route path="/register" element={<Register />} />
                <Route path="/forgot-password" element={<ForgotPassword />} />
                <Route path="/password-reset-link-sent" element={<PasswordResetLinkSent />} />
                <Route path="/reset-password/:token" element={<ResetPassword />} />
                <Route path="/email-verified" element={<EmailVerified />} /> {/* Route for EmailVerified */}
                <Route path="/cars" element={<CarPage />} />
                <Route path="/carinfo/:carId" element={<CarInfo />} />
                <Route path="/" element={<CarUI />} />
            </Routes>
        </Router>
    );
}

export default App;
