import React, { useState } from 'react';

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
        // Make API call to update the user's name
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
                alert('Name updated successfully');
                setIsEditing(false); // Exit edit mode

                const updatedUser = { ...ud, firstName, lastName };
                localStorage.setItem('user_data', JSON.stringify(updatedUser));
            }
        } catch (e) {
            alert(e.toString());
        }
    };

    return (
        <div id="loggedInDiv">
            {isEditing ? (
                <div>
                    <input type="text" value={firstName} onChange={(e) => setFirstName(e.target.value)} />
                    <input type="text" value={lastName} onChange={(e) => setLastName(e.target.value)} />
                    <button type="button" className="buttons" onClick={handleChangeName}>Save</button>
                    <button type="button" className="buttons" onClick={() => setIsEditing(false)}>Cancel</button>
                </div>
            ) : (
                <div>
                    <span id="userName">Logged In As {firstName} {lastName}</span><br />
                    <button type="button" className="buttons" onClick={() => setIsEditing(true)}>Edit Name</button>
                    <button type="button" className="buttons" onClick={doLogout}> Log Out </button>
                </div>
            )}
        </div>
    );
}

export default LoggedInName;
