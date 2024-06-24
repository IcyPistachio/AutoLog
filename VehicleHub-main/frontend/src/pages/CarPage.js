import React, { useState } from 'react';
import GarageTitle from '../components/GarageTitle';
import LoggedInName from '../components/LoggedInName';
import CarUI from '../components/CarUI';
import CarInfo from '../components/CarInfo';
import './CarPage.css'; // CSS for CarPage layout

const CarPage = () => {
    const [selectedCarId, setSelectedCarId] = useState(null);
    const [carInfoUpdated, setCarInfoUpdated] = useState(false); // Track car info update

    const handleCarSelect = (carId) => {
        setSelectedCarId(carId);
    };

    const handleCarInfoUpdated = () => {
        setCarInfoUpdated(!carInfoUpdated); // Toggle state to trigger refresh
    };

    return (
        <div className="car-page-container">
            <GarageTitle />
            <LoggedInName />
            <div className="car-page-content">
                <div className="left-half">
                    <CarUI onSelectCar={handleCarSelect} selectedCarId={selectedCarId} carInfoUpdated={carInfoUpdated} />
                </div>
                <div className="right-half">
                    {selectedCarId && <CarInfo carId={selectedCarId} onCarInfoUpdated={handleCarInfoUpdated} />}
                </div>
            </div>
        </div>
    );
}

export default CarPage;
