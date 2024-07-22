import React, { useState, useEffect } from 'react';
import LoggedInName from '../components/LoggedInName';
import CarUI from '../components/CarUI';
import CarInfo from '../components/CarInfo';
import CreateVehicle from '../components/CreateVehicle';
import '../components/CarPage.css';
import '../components/DefaultStyles.css';  // Import the shared CSS

const CarPage = () => {
    const [selectedCarId, setSelectedCarId] = useState(null);
    const [carInfoUpdated, setCarInfoUpdated] = useState(false);
    const [creatingVehicle, setCreatingVehicle] = useState(false);
    const [showGarageDoor, setShowGarageDoor] = useState(true);

    useEffect(() => {
        const timer = setTimeout(() => {
            setShowGarageDoor(false);
        }, 2000); // Adjust the time to match the animation duration
        return () => clearTimeout(timer);
    }, []);

    const handleCarSelect = (carId) => {
        setSelectedCarId(carId);
        setCreatingVehicle(false); // Hide create vehicle form if a car is selected
    };

    const handleCarInfoUpdated = () => {
        setCarInfoUpdated(!carInfoUpdated); // Toggle state to trigger refresh
    };

    const handleCreateVehicle = () => {
        setCreatingVehicle(true); // Show create vehicle form
        setSelectedCarId(null); // Deselect any car
    };

    const handleVehicleCreated = () => {
        setCarInfoUpdated(!carInfoUpdated); // Refresh car list after adding new car
        // setCreatingVehicle(false); // Hide create vehicle form
    };

    return (
        <div className="car-page-container">
            {showGarageDoor && <div className="garage-door"></div>}
            <LoggedInName />
            <div className="car-page-content">
                <div className="left-half">
                    <div className="car-list">
                        <CarUI
                            onSelectCar={handleCarSelect}
                            selectedCarId={selectedCarId}
                            carInfoUpdated={carInfoUpdated}
                            onCreateVehicle={handleCreateVehicle}
                        />
                    </div>
                </div>
                <div className="right-half">
                    {selectedCarId && (
                        <div className="car-ui-container">
                            <CarInfo carId={selectedCarId} onCarInfoUpdated={handleCarInfoUpdated} />
                        </div>
                    )}
                    {creatingVehicle && (
                        <div className="car-ui-container">
                            <CreateVehicle onVehicleCreated={handleVehicleCreated} />
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}

export default CarPage;
