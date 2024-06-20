import React, { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';

function CarInfo() {
    const { carId } = useParams();
    const [car, setCar] = useState(null);
    const [error, setError] = useState('');
    const [note, setNote] = useState('');
    const [notes, setNotes] = useState([]);
    const [editNoteId, setEditNoteId] = useState(null);
    const [editNoteContent, setEditNoteContent] = useState('');
    const [editMode, setEditMode] = useState(false); // State to toggle edit mode
    const [make, setMake] = useState('');
    const [model, setModel] = useState('');
    const [year, setYear] = useState('');
    const [odometer, setOdometer] = useState('');
    const [color, setColor] = useState(''); // State for color
    const [searchTerm, setSearchTerm] = useState(''); // State to hold search term
    const navigate = useNavigate();

    const app_name = 'cop4331vehiclehub-330c5739c6af'
    function buildPath(route)
    {
        if (process.env.NODE_ENV === 'production') 
        {
            return 'https://' + app_name +  '.herokuapp.com/' + route;
        }
        else
        {        
            return 'http://localhost:5000/' + route;
        }
    }

    useEffect(() => {
        const fetchCarInfo = async () => {
            try {
                const response = await fetch(buildPath('api/getcarinfo'), {
                    method: 'POST',
                    body: JSON.stringify({ carId: parseInt(carId) }),
                    headers: { 'Content-Type': 'application/json' },
                });

                const res = await response.json();
                if (res.error.length > 0) {
                    setError("API Error: " + res.error);
                } else {
                    setCar(res.car);
                    // Set initial values for edit mode
                    setMake(res.car.make);
                    setModel(res.car.model);
                    setYear(res.car.year);
                    setOdometer(res.car.odometer);
                    setColor(res.car.color); // Set initial color
                }
            } catch (e) {
                setError(e.toString());
            }
        };

        const fetchCarNotes = async () => {
            try {
                const response = await fetch(buildPath('api/getcarnotes'), {
                    method: 'POST',
                    body: JSON.stringify({ carId: parseInt(carId) }),
                    headers: { 'Content-Type': 'application/json' },
                });

                const res = await response.json();
                if (res.error.length > 0) {
                    setError("API Error: " + res.error);
                } else {
                    const sortedNotes = res.notes.sort((a, b) => new Date(b.dateCreated) - new Date(a.dateCreated));
                    setNotes(sortedNotes);
                }
            } catch (e) {
                setError(e.toString());
            }
        };

        fetchCarInfo();
        fetchCarNotes();
    }, [carId]);

    const addNote = async () => {
        if (!car) {
            setError("Car information is not available");
            return;
        }

        const noteWithOdometer = `${note} (Odometer: ${car.odometer} miles)`;
        
        try {
            const response = await fetch(buildPath('api/addnote'), {
                method: 'POST',
                body: JSON.stringify({ carId: parseInt(carId), note: noteWithOdometer, dateCreated: new Date().toISOString() }),
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setError("API Error: " + res.error);
            } else {
                fetchNotes();
                setNote('');
            }
        } catch (e) {
            setError(e.toString());
        }
    };

    const fetchNotes = async () => {
        try {
            const response = await fetch(buildPath('api/getcarnotes'), {
                method: 'POST',
                body: JSON.stringify({ carId: parseInt(carId) }),
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setError("API Error: " + res.error);
            } else {
                const sortedNotes = res.notes.sort((a, b) => new Date(b.dateCreated) - new Date(a.dateCreated));
                setNotes(sortedNotes);
            }
        } catch (e) {
            setError(e.toString());
        }
    };

    const deleteNote = async (noteId) => {
        if (!window.confirm('Are you sure you want to delete this note?')) {
            return;
        }

        try {
            const response = await fetch(buildPath('api/deletenote'), {
                method: 'POST',
                body: JSON.stringify({ carId: parseInt(carId), noteId }),
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setError("API Error: " + res.error);
            } else {
                fetchNotes();
            }
        } catch (e) {
            setError(e.toString());
        }
    };

    const editNote = (noteId, currentNote) => {
        setEditNoteId(noteId);
        setEditNoteContent(currentNote);
    };

    const updateNote = async () => {
        try {
            const response = await fetch(buildPath('api/updatenote'), {
                method: 'POST',
                body: JSON.stringify({ carId: parseInt(carId), noteId: editNoteId, note: editNoteContent, dateCreated: new Date().toISOString() }),
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setError("API Error: " + res.error);
            } else {
                fetchNotes();
                setEditNoteId(null);
                setEditNoteContent('');
            }
        } catch (e) {
            setError(e.toString());
        }
    };

    const saveCarChanges = async () => {
        try {
            const userId = JSON.parse(localStorage.getItem('user_data')).id;
            const obj = { userId, carId: parseInt(carId), make, model, year, odometer, color }; // Include color
            const js = JSON.stringify(obj);

            const response = await fetch(buildPath('api/updatecar'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();

            if (res.error.length > 0) {
                setError("API Error:" + res.error);
            } else {
                setError('');
                setEditMode(false); // Exit edit mode
                setCar({ ...car, make, model, year, odometer, color }); // Update local car state
            }
        } catch (e) {
            setError(e.toString());
        }
    };

    const formatDate = (dateString) => {
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Date(dateString).toLocaleDateString(undefined, options);
    };

    const goBack = () => {
        navigate('/cars');
    };

    // Function to handle search input change
    const handleSearchChange = (e) => {
        setSearchTerm(e.target.value);
    };

    // Function to filter notes based on search term
    const filteredNotes = notes.filter((note) =>
        note.note.toLowerCase().includes(searchTerm.toLowerCase()) ||
        formatDate(note.dateCreated).toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div>
            <h2>Car Information</h2>
            {error && <p>{error}</p>}
            {car ? (
                <div>
                    <div>
                        <label>Make: </label>
                        {editMode ? (
                            <input type="text" value={make} onChange={(e) => setMake(e.target.value)} />
                        ) : (
                            <span>{car.make}</span>
                        )}
                    </div>
                    <div>
                        <label>Model: </label>
                        {editMode ? (
                            <input type="text" value={model} onChange={(e) => setModel(e.target.value)} />
                        ) : (
                            <span>{car.model}</span>
                        )}
                    </div>
                    <div>
                        <label>Year: </label>
                        {editMode ? (
                            <input type="text" value={year} onChange={(e) => setYear(e.target.value)} />
                        ) : (
                            <span>{car.year}</span>
                        )}
                    </div>
                    <div>
                        <label>Odometer: </label>
                        {editMode ? (
                            <input type="text" value={odometer} onChange={(e) => setOdometer(e.target.value)} />
                        ) : (
                            <span>{car.odometer}</span>
                        )}
                    </div>
                    <div>
                        <label>Color: </label> {/* New color field */}
                        {editMode ? (
                            <input type="text" value={color} onChange={(e) => setColor(e.target.value)} />
                        ) : (
                            <span>{car.color}</span>
                        )}
                    </div>
                    <button onClick={() => setEditMode(!editMode)}>
                        {editMode ? 'Cancel Edit' : 'Edit'}
                    </button>
                    {editMode && (
                        <button onClick={saveCarChanges}>Save Changes</button>
                    )}
    
                    <button onClick={goBack}>Back</button>
    
                    <h3>Add a Note</h3>
                    <textarea
                        value={note}
                        onChange={(e) => setNote(e.target.value)}
                        rows="4"
                        cols="50"
                        placeholder="Enter your notes here"
                    ></textarea>
                    <button onClick={addNote}>Add Note</button>
    
                    <h3>Notes</h3>
                    <input
                        type="text"
                        value={searchTerm}
                        onChange={handleSearchChange}
                        placeholder="Search notes..."
                    />
                    <ul>
                        {filteredNotes.map((n) => (
                            <li key={n.noteId}>
                                {editNoteId === n.noteId ? (
                                    <div>
                                        <textarea
                                            value={editNoteContent}
                                            onChange={(e) => setEditNoteContent(e.target.value)}
                                            rows="4"
                                            cols="50"
                                            placeholder="Edit your note here"
                                        ></textarea>
                                        <button onClick={updateNote}>Save</button>
                                    </div>
                                ) : (
                                    <div>
                                        {formatDate(n.dateCreated)}: {n.note}
                                        <button onClick={() => deleteNote(n.noteId)}>Delete</button>
                                        <button onClick={() => editNote(n.noteId, n.note)}>Edit</button>
                                    </div>
                                )}
                            </li>
                        ))}
                    </ul>
                </div>
            ) : (
                <p>Loading...</p>
            )}
        </div>
    );
}

export default CarInfo;
