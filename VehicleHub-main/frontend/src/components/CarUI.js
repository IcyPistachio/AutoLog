import React, { useState, useEffect, useRef } from 'react';
import './CarUI.css'; // Assuming you have a CSS file for styling

function CarUI({ onSelectCar, selectedCarId, carInfoUpdated }) {
    const [message, setMessage] = useState('');
    const [carList, setCarList] = useState([]);

    const makeRef = useRef(null);
    const modelRef = useRef(null);
    const yearRef = useRef(null);
    const odometerRef = useRef(null);
    const colorRef = useRef(null);
    const searchRef = useRef(null);

    var bp = require('./Path.js');

    useEffect(() => {
        searchCars(searchRef.current.value); // Initial search with empty search term on component mount
    }, [carInfoUpdated]);

    const addCar = async (event) => {
        event.preventDefault();
        const userId = JSON.parse(localStorage.getItem('user_data')).id;
        const make = makeRef.current.value;
        const model = modelRef.current.value;
        const year = yearRef.current.value;
        const odometer = odometerRef.current.value;
        const color = colorRef.current.value;

        const obj = { userId, make, model, year, odometer, color };
        const js = JSON.stringify(obj);
        try {
            const response = await fetch(bp.buildPath('api/addcar'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });
            const res = await response.json();

            if (res.error.length > 0) {
                setMessage("API Error:" + res.error);
            } else {
                setMessage('Car has been added');
                makeRef.current.value = '';
                modelRef.current.value = '';
                yearRef.current.value = '';
                odometerRef.current.value = '';
                colorRef.current.value = '';
                searchCars(searchRef.current.value); // Refresh the car list with the current search term
            }
        } catch (e) {
            setMessage(e.toString());
        }
    };

    const searchCars = async (searchTerm) => {
        const userId = JSON.parse(localStorage.getItem('user_data')).id;

        const obj = { userId, search: searchTerm };
        const js = JSON.stringify(obj);

        try {
            const response = await fetch(bp.buildPath('api/searchcars'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setMessage("API Error:" + res.error);
            } else {
                setCarList(res.results);
            }
        } catch (e) {
            setMessage(e.toString());
        }
    };

    const deleteCar = async (carId) => {
        if (!window.confirm('Are you sure you want to delete this car?')) {
            return;
        }

        const userId = JSON.parse(localStorage.getItem('user_data')).id;
        const obj = { userId, carId };
        const js = JSON.stringify(obj);

        try {
            const response = await fetch(bp.buildPath('api/deletecar'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setMessage("API Error:" + res.error);
            } else {
                setMessage('Car has been deleted');
                searchCars(searchRef.current.value); // Refresh the car list with the current search term
            }
        } catch (e) {
            setMessage(e.toString());
        }
    };

    const handleSearchChange = () => {
        const searchTerm = searchRef.current.value;
        searchCars(searchTerm); // Trigger search on input change
    };

    return (
        <div className="car-ui-container">
            <div className="add-car-section">
                <input type="text" placeholder="Make" ref={makeRef} className="width" />
                <input type="text" placeholder="Model" ref={modelRef} className="width" />
                <input type="text" placeholder="Year" ref={yearRef} className="width" />
                <input type="text" placeholder="Odometer" ref={odometerRef} className="width" />
                <input type="text" placeholder="Color" ref={colorRef} className="width" />
                <button type="button" onClick={addCar}>Add Car</button>
            </div>
            <br />
            <input type="text" placeholder="Search Cars" ref={searchRef} onChange={handleSearchChange} />
            <div className="car-list">
                {carList.map((car) => (
                    <div key={car.carId} className="car-box" onClick={() => onSelectCar(car.carId)}>
                        <div>
                            <strong>Make:</strong> {car.make}
                        </div>
                        <div>
                            <strong>Model:</strong> {car.model}
                        </div>
                        <div>
                            <strong>Year:</strong> {car.year}
                        </div>
                        <div>
                            <strong>Odometer:</strong> {car.odometer}
                        </div>
                        <div>
                            <strong>Color:</strong> {car.color}
                        </div>
                        <button onClick={(e) => { e.stopPropagation(); deleteCar(car.carId); }}>Delete</button>
                    </div>
                ))}
            </div>
        </div>
    );
}

export default CarUI;
