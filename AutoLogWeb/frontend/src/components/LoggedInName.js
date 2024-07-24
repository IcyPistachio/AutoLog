import React, { useState } from 'react';
import './LoggedInName.css';
import './DefaultStyles.css';
function LoggedInName() {
    var _ud = localStorage.getItem('user_data');
    var ud = JSON.parse(_ud);
    var userId = ud.id;
    var initialFirstName = ud.firstName;
    var initialLastName = ud.lastName;
    var bp = require('./Path.js');

    const [firstName, setFirstName] = useState(initialFirstName);
    const [lastName, setLastName] = useState(initialLastName);
    const [isEditing, setIsEditing] = useState(false);

    const doLogout = event => {
        event.preventDefault();
        localStorage.removeItem("user_data");
        window.location.href = '/login';
    };

    const handleChangeName = async () => {
        const obj = { userId, firstName, lastName };
        const js = JSON.stringify(obj);

        try {
            const response = await fetch(bp.buildPath('api/changename'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });
            const res = await response.json();

            if (res.error) {
                alert('Failed to update name');
            } else {
                setIsEditing(false);

                const updatedUser = { ...ud, firstName, lastName };
                localStorage.setItem('user_data', JSON.stringify(updatedUser));
            }
        } catch (e) {
            alert(e.toString());
        }
    };

    return (
        <div id="loggedInDiv">
            <div id="userName">
                {firstName}'s GARAGE
            </div>
            <div id="editNameContainer">
                {isEditing ? (
                    <div className="edit-inputs-container">
                        <input type="text" value={firstName} onChange={(e) => setFirstName(e.target.value)} />
                        <input type="text" value={lastName} onChange={(e) => setLastName(e.target.value)} />
                        <button type="button" className="button-fitted default-button" onClick={() => setIsEditing(false)}>Cancel</button>
                        <button type="button" className="button-fitted accent-button" onClick={handleChangeName}>Save</button>
                    </div>
                ) : (
                    <div className="buttons-container">
                        <button type="button" className="icon-button" onClick={() => setIsEditing(true)}>
                            <i className="bi bi-pencil-square"></i>Edit Name
                        </button>
                        <div className="spacer" />
                        <button type="button" className="icon-button" onClick={doLogout}>
                            <i class="bi bi-box-arrow-right"></i>Log Out
                        </button>
                    </div>
                )}
            </div>
        </div>
    );
}


export default LoggedInName;
