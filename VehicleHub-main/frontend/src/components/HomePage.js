import React from 'react';
import { useNavigate } from 'react-router-dom';
import './HomePage.css'; 

function HomePage() {
    const navigate = useNavigate();

    const handleLoginSignup = () => {
        navigate('/login'); 
    };

    return (
        <div className="home-container">
            <h1>Vehicle Hub</h1>
            <p>Welcome to Vehicle Hub! This is your one-stop solution to manage all your vehicles. Whether you want to add new vehicles, update their details, or keep track of maintenance, Vehicle Hub has got you covered.</p>
            <button onClick={handleLoginSignup}>Login/Signup</button>
        </div>
    );
}

export default HomePage;
