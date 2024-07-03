import React, { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import './CarInfo.css'; 

function CarInfo({ carId, onCarInfoUpdated }) {
    const [car, setCar] = useState(null);
    const [error, setError] = useState('');
    const [note, setNote] = useState('');
    const [type, setType] = useState('');
    const [miles, setMiles] = useState('');
    const [notes, setNotes] = useState([]);
    const [editNoteId, setEditNoteId] = useState(null);
    const [editNoteContent, setEditNoteContent] = useState('');
    const [editNoteType, setEditNoteType] = useState('');
    const [editNoteMiles, setEditNoteMiles] = useState('');
    const [editMode, setEditMode] = useState(false);
    const [make, setMake] = useState('');
    const [model, setModel] = useState('');
    const [year, setYear] = useState('');
    const [odometer, setOdometer] = useState('');
    const [color, setColor] = useState('');
    const [searchTerm, setSearchTerm] = useState('');
    const [showAddNoteForm, setShowAddNoteForm] = useState(false);
    const navigate = useNavigate();

    var bp = require('./Path.js');

    useEffect(() => {
        const fetchCarInfo = async () => {
            try {
                const response = await fetch(bp.buildPath('api/getcarinfo'), {
                    method: 'POST',
                    body: JSON.stringify({ carId: parseInt(carId) }),
                    headers: { 'Content-Type': 'application/json' },
                });

                const res = await response.json();
                if (res.error.length > 0) {
                    setError("API Error: " + res.error);
                } else {
                    setCar(res.car);
                    setMake(res.car.make);
                    setModel(res.car.model);
                    setYear(res.car.year);
                    setOdometer(res.car.odometer);
                    setColor(res.car.color);
                }
            } catch (e) {
                setError(e.toString());
            }
        };

        const fetchCarNotes = async () => {
            try {
                const response = await fetch(bp.buildPath('api/getcarnotes'), {
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
            setError("Vehicle information is not available");
            return;
        }

        try {
            const response = await fetch(bp.buildPath('api/addnote'), {
                method: 'POST',
                body: JSON.stringify({
                    carId: parseInt(carId),
                    note,
                    type,
                    miles,
                    dateCreated: new Date().toISOString()
                }),
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setError("API Error: " + res.error);
            } else {
                fetchNotes();
                setNote('');
                setType('');
                setMiles('');
                //setShowAddNoteForm(false); // Hide form after adding the note
            }
        } catch (e) {
            setError(e.toString());
        }
    };

    const fetchNotes = async () => {
        try {
            const response = await fetch(bp.buildPath('api/getcarnotes'), {
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
            const response = await fetch(bp.buildPath('api/deletenote'), {
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

    const editNote = (noteId, currentNote, currentType, currentMiles) => {
        setEditNoteId(noteId);
        setEditNoteContent(currentNote);
        setEditNoteType(currentType);
        setEditNoteMiles(currentMiles);
    };

    const updateNote = async () => {
        try {
            const response = await fetch(bp.buildPath('api/updatenote'), {
                method: 'POST',
                body: JSON.stringify({
                    carId: parseInt(carId),
                    noteId: editNoteId,
                    note: editNoteContent,
                    type: editNoteType,
                    miles: editNoteMiles,
                    dateCreated: new Date().toISOString()
                }),
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();
            if (res.error.length > 0) {
                setError("API Error: " + res.error);
            } else {
                fetchNotes();
                setEditNoteId(null);
                setEditNoteContent('');
                setEditNoteType('');
                setEditNoteMiles('');
            }
        } catch (e) {
            setError(e.toString());
        }
    };

    const saveCarChanges = async () => {
        try {
            const userId = JSON.parse(localStorage.getItem('user_data')).id;
            const obj = { userId, carId: parseInt(carId), make, model, year, odometer, color };
            const js = JSON.stringify(obj);

            const response = await fetch(bp.buildPath('api/updatecar'), {
                method: 'POST',
                body: js,
                headers: { 'Content-Type': 'application/json' },
            });

            const res = await response.json();

            if (res.error.length > 0) {
                setError("API Error:" + res.error);
            } else {
                setError('');
                setEditMode(false);
                setCar({ ...car, make, model, year, odometer, color });
            }
            onCarInfoUpdated();
        } catch (e) {
            setError(e.toString());
        }
    };

    const formatDate = (dateString) => {
        const options = { year: 'numeric', month: 'long', day: 'numeric' };
        return new Date(dateString).toLocaleDateString(undefined, options);
    };

    const handleSearchChange = (e) => {
        setSearchTerm(e.target.value);
    };

    const filteredNotes = notes.filter((note) =>
        note.note.toLowerCase().includes(searchTerm.toLowerCase()) ||
        note.type.toLowerCase().includes(searchTerm.toLowerCase()) ||
        note.miles.toLowerCase().includes(searchTerm.toLowerCase()) ||
        formatDate(note.dateCreated).toLowerCase().includes(searchTerm.toLowerCase())
    );

    return (
        <div className="car-info-container">
            <h2>Vehicle Information</h2>
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
                        <label>Color: </label>
                        {editMode ? (
                            <input type="text" value={color} onChange={(e) => setColor(e.target.value)} />
                        ) : (
                            <span>{car.color}</span>
                        )}
                    </div>
                    {editMode ? (
                        <div>
                            <button onClick={saveCarChanges}>Save Changes</button>
                            <button onClick={() => setEditMode(false)}>Cancel</button>
                        </div>
                    ) : (
                        <button onClick={() => setEditMode(true)}>Edit</button>
                    )}
                </div>
            ) : (
                <p>Loading...</p>
            )}

            <div className="notes-section">
                <h2>Vehicle Notes:</h2>
                <button onClick={() => setShowAddNoteForm(!showAddNoteForm)}>
                    {showAddNoteForm ? 'Hide Add Note Form' : 'Create New Note'}
                </button>
                {showAddNoteForm && (
                    <div className="note-form">
                        <label>
                            Service Type:
                            <input
                                type="text"
                                value={type}
                                onChange={(e) => setType(e.target.value)}
                                placeholder="Service Type"
                            />
                        </label>
                        <label>
                            Miles:
                            <input
                                type="text"
                                value={miles}
                                onChange={(e) => setMiles(e.target.value)}
                                placeholder="Miles"
                            />
                        </label>
                        <label>
                            Note:
                            <textarea
                                value={note}
                                onChange={(e) => setNote(e.target.value)}
                                placeholder="Add a note"
                            ></textarea>
                        </label>
                        <button onClick={addNote}>Add Note</button>
                    </div>
                )}
                <input
                    type="text"
                    value={searchTerm}
                    onChange={handleSearchChange}
                    placeholder="Search notes..."
                />
                <div>
                    {filteredNotes.map((note) => (
                        <div key={note.noteId}>
                            {editNoteId === note.noteId ? (
                                <div className="edit-note-form">
                                    <label>
                                        Type:
                                        <input
                                            type="text"
                                            value={editNoteType}
                                            onChange={(e) => setEditNoteType(e.target.value)}
                                            placeholder="Type"
                                        />
                                    </label>
                                    <label>
                                        Miles:
                                        <input
                                            type="text"
                                            value={editNoteMiles}
                                            onChange={(e) => setEditNoteMiles(e.target.value)}
                                            placeholder="Miles"
                                        />
                                    </label>
                                    <label>
                                        Note:
                                        <textarea
                                            value={editNoteContent}
                                            onChange={(e) => setEditNoteContent(e.target.value)}
                                        ></textarea>
                                    </label>
                                    <button onClick={updateNote}>Update Note</button>
                                    <button onClick={() => setEditNoteId(null)}>Cancel</button>
                                </div>
                            ) : (
                                <div className="note">
                                    <p>Type: {note.type} | Miles: {note.miles} | Note: {note.note} | {formatDate(note.dateCreated)}</p>
                                    <button onClick={() => editNote(note.noteId, note.note, note.type, note.miles)}>Edit</button>
                                    <button onClick={() => deleteNote(note.noteId)}>Delete</button>
                                </div>
                            )}
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
}

export default CarInfo;
