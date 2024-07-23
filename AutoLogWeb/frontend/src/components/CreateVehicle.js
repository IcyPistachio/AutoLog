import React, { useRef, useState } from 'react';
import './CreateVehicle.css'; 

function CreateVehicle({ onVehicleCreated }) {
    const [message, setMessage] = useState('');

    const makeRef = useRef(null);
    const modelRef = useRef(null);
    const yearRef = useRef(null);
    const odometerRef = useRef(null);
    const colorRef = useRef(null);

    var bp = require('./Path.js');

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
                setMessage('Vehicle has been added');
                makeRef.current.value = '';
                modelRef.current.value = '';
                yearRef.current.value = '';
                odometerRef.current.value = '';
                colorRef.current.value = '';
                onVehicleCreated(); 
            }
        } catch (e) {
            setMessage(e.toString());
        }
    };

    return (
        <div className="create-vehicle-container">
            <div id="sectionHeader">Add New Vehicle</div>
            <form onSubmit={addCar}>
                <div className="add-car-section">
                    <div className="input-group">
                        <label>Make: </label>
                        <input type="text" placeholder="Make" ref={makeRef} className="width" />
                    </div>
                    <div className="input-group">
                        <label>Model: </label>
                        <input type="text" placeholder="Model" ref={modelRef} className="width" />
                    </div>
                    <div className="input-group">
                        <label>Year: </label>
                        <input type="text" placeholder="Year" ref={yearRef} className="width" />
                    </div>
                    <div className="input-group">
                        <label>Odometer: </label>
                        <input type="text" placeholder="Odometer" ref={odometerRef} className="width" />
                    </div>
                    <div className="input-group">
                        <label>Color: </label>
                        <input type="text" placeholder="Color" ref={colorRef} className="width" />
                    </div>
                    <div className='search-add-section'>
                        <button type="submit">
                            <i class="bi bi-plus" />ADD VEHICLE
                        </button>
                    </div>
                </div>
            </form>
            <div className="message">{message}</div>
        </div>
    );
}

export default CreateVehicle;
