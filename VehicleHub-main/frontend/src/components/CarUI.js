import React, { useState, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import './CarUI.css'; // Assuming you have a CSS file for styling

function CarUI() {
    const [message, setMessage] = useState('');
    const [carList, setCarList] = useState([]);
    const [editingCar, setEditingCar] = useState(null);

    const makeRef = useRef(null);
    const modelRef = useRef(null);
    const yearRef = useRef(null);
    const odometerRef = useRef(null);
    const colorRef = useRef(null);
    const searchRef = useRef(null);

    const navigate = useNavigate();

    var bp = require('./Path.js');

    useEffect(() => {
        searchCars(''); // Initial search with empty search term on component mount
    }, []);

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

    const editCar = (car) => {
        setEditingCar(car);
        makeRef.current.value = car.make;
        modelRef.current.value = car.model;
        yearRef.current.value = car.year;
        odometerRef.current.value = car.odometer;
        colorRef.current.value = car.color;
    };

    const updateCar = async (event) => {
        event.preventDefault();
        const userId = JSON.parse(localStorage.getItem('user_data')).id;
        const carId = editingCar.carId;
        const make = makeRef.current.value;
        const model = modelRef.current.value;
        const year = yearRef.current.value;
        const odometer = odometerRef.current.value;
        const color = colorRef.current.value;

        const obj = { userId, carId, make, model, year, odometer, color };
        const js = JSON.stringify(obj);
        try {
            const response = await fetch(bp.buildPath('api/updatecar'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });
            const res = await response.json();

            if (res.error.length > 0) {
                setMessage("API Error:" + res.error);
            } else {
                setMessage('Car has been updated');
                setEditingCar(null);
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

    const viewInfo = (carId) => {
        navigate(`/carinfo/${carId}`);
    };

    const handleSearchChange = () => {
        const searchTerm = searchRef.current.value;
        searchCars(searchTerm); // Trigger search on input change
    };

    return (
        <div id="carUIDiv">
            <div id="addCarSection">
                <input type="text" id="makeText" placeholder="Make" ref={makeRef} />
                <input type="text" id="modelText" placeholder="Model" ref={modelRef} />
                <input type="text" id="yearText" placeholder="Year" ref={yearRef} />
                <input type="text" id="odometerText" placeholder="Odometer" ref={odometerRef} />
                <input type="text" id="colorText" placeholder="Color" ref={colorRef} />
                {editingCar ? (
                    <button type="button" id="updateCarButton" className="buttons" onClick={updateCar}>Update Car</button>
                ) : (
                    <button type="button" id="addCarButton" className="buttons" onClick={addCar}>Add Car</button>
                )}
            </div>
            <br />
            <input type="text" id="searchText" placeholder="Search Cars" ref={searchRef} onChange={handleSearchChange} />
            <div id="carSearchResult">{message}</div>
            <div id="carList" className="carContainer">
                {carList.map((car) => (
                    <div key={car.carId} className="carBox" onClick={() => viewInfo(car.carId)}>
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
                        <button onClick={(e) => { e.stopPropagation(); editCar(car); }}>Edit</button>
                        <button onClick={(e) => { e.stopPropagation(); deleteCar(car.carId); }}>Delete</button>
                    </div>
                ))}
            </div>
        </div>
    );
}

export default CarUI;
