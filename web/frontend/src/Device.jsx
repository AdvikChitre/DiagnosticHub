import { useState, useEffect } from 'react';
import { SERVER_URL } from './main.jsx';

const Device = () => {
    const deviceID = JSON.parse(localStorage.getItem('selectedDeviceID'));
    const [device, setDevice] = useState({
        name: '',
        description: '',
        image_url: '',
        video_url: '',
        forwarding_address: 'http://localhost',
        forwarding_port: 8080,
        record_type: 'automatic',
        is_enabled: false,
        created_at: ''
    });

    // Questions state
    const [questions, setQuestions] = useState([]);
    const [hoveredQuestionId, setHoveredQuestionId] = useState(null);
    const [showAddModal, setShowAddModal] = useState(false);
    const [newQuestion, setNewQuestion] = useState("");
    const [showEditModal, setShowEditModal] = useState(false);
    const [editingQuestion, setEditingQuestion] = useState({ id: null, text: "" });

    const fetchDeviceOptions = async () => {
        if (!deviceID) {
            console.error('No device ID found');
            return;
        }
        try {
            const token = localStorage.getItem('jwtToken');
            const deviceRequest = { wearableID: deviceID };
            const response = await fetch(`${SERVER_URL}/api/wearables/get`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify(deviceRequest)
            });
            if (!response.ok) {
                throw new Error('Error fetching device option information');
            }
            const data = await response.json();            
            setDevice(data.data);
        } catch (error) {
            console.error('Failed to fetch device option information:', error);
        }
    };

    const fetchQuestions = async () => {
        if (!deviceID) return;
        try {
            const token = localStorage.getItem('jwtToken');
            const response = await fetch(`${SERVER_URL}/api/wearables/questions/${deviceID}`, {
                method: 'GET',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`
                }
            });
            if (!response.ok) {
                throw new Error('Error fetching questions');
            }
            const data = await response.json();
            setQuestions(data.questions);
        } catch (error) {
            console.error('Failed to fetch questions:', error);
        }
    };

    useEffect(() => {
        fetchDeviceOptions();
        fetchQuestions();
    }, [deviceID]);

    const handleChange = (e) => {
        const { name, type, value, checked } = e.target;
        setDevice(prevDevice => ({
            ...prevDevice,
            [name]: type === 'checkbox' ? checked : value
        }));
    };

    const handleSubmit = async (e) => {
        e.preventDefault();
        if (!deviceID) {
            console.error('No device ID found');
            return;
        }
        const token = localStorage.getItem('jwtToken');
        const payload = {
            wearableID: deviceID,
            name: device.name,
            description: device.description,
            image_url: device.image_url,
            video_url: device.video_url,
            forwarding_address: device.forwarding_address,
            forwarding_port: parseInt(device.forwarding_port, 10),
            record_type: device.record_type,
            is_enabled: device.is_enabled,
        };
    
        try {
            const response = await fetch(`${SERVER_URL}/api/wearables/update`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify(payload)
            });
    
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Error updating wearable');
            }
    
            const data = await response.json();
            console.log('Wearable updated successfully:', data.message);
        } catch (error) {
            console.error('Failed to update wearable:', error);
        }
    };

    // Handle adding a new question
    const handleAddQuestion = async () => {
        if (!deviceID || !newQuestion) return;
        try {
            const token = localStorage.getItem('jwtToken');
            const response = await fetch(`${SERVER_URL}/api/wearables/questions/add`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify({ wearableID: deviceID, question_text: newQuestion })
            });
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Error adding question');
            }
            const data = await response.json();
            const addedQuestion = { id: data.questionID, question: newQuestion };
            setQuestions(prev => [...prev, addedQuestion]);
            setNewQuestion("");
            setShowAddModal(false);
        } catch (error) {
            console.error('Failed to add question:', error);
        }
    };

    // Handle editing a question
    const handleUpdateQuestion = async () => {
        if (!editingQuestion.id || !editingQuestion.text) return;
        try {
            const token = localStorage.getItem('jwtToken');
            const response = await fetch(`${SERVER_URL}/api/wearables/questions/update`, {
                method: 'PUT',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify({
                    questionId: editingQuestion.id,
                    editedQuestion: editingQuestion.text
                })
            });
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Error updating question');
            }
            setQuestions(prev => prev.map(q => 
                q.id === editingQuestion.id ? { ...q, question: editingQuestion.text } : q
            ));
            setEditingQuestion({ id: null, text: "" });
            setShowEditModal(false);
        } catch (error) {
            console.error('Failed to update question:', error);
        }
    };

    // Handle deleting a question
    const handleDeleteQuestion = async (questionId) => {
        try {
            const token = localStorage.getItem('jwtToken');
            const response = await fetch(`${SERVER_URL}/api/wearables/questions/delete`, {
                method: 'DELETE',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify({ questionId })
            });
            if (!response.ok) {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Error deleting question');
            }
            setQuestions(prev => prev.filter(q => q.id !== questionId));
        } catch (error) {
            console.error('Failed to delete question:', error);
        }
    };

    // Styles
    const rowStyle = {
        display: 'flex',
        alignItems: 'center',
        marginBottom: '15px'
    };

    const leftColStyle = {
        flex: 1,
        textAlign: 'center'
    };

    const rightColStyle = {
        flex: 1,
        textAlign: 'center'
    };

    const inputStyle = { borderRadius: '7px', padding: '5px', width: '80%' };

    // Container flex style for two columns
    const containerStyle = {
        display: 'flex',
        padding: '20px'
    };

    // Questions list styles
    const questionsListStyle = {
        maxHeight: '400px',
        overflowY: 'scroll',
        border: '1px solid #ccc',
        padding: '10px'
    };

    const questionItemStyle = {
        padding: '8px',
        borderBottom: '1px solid #eee',
        position: 'relative'
    };

    const buttonStyle = {
        marginLeft: '5px'
    };

    const modalOverlayStyle = {
        position: 'fixed',
        top: 0,
        left: 0,
        right: 0,
        bottom: 0,
        backgroundColor: 'rgba(0,0,0,0.5)',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center'
    };

    const modalContentStyle = {
        backgroundColor: 'white',
        padding: '20px',
        borderRadius: '10px',
        minWidth: '300px'
    };

    return (
        <div>
            <h1 style={{ textAlign: 'center', marginBottom: '20px' }}>Device Configuration</h1>
            <div style={containerStyle}>
                {/* Left column with device form */}
                <div style={{ flex: 1, marginRight: '20px' }}>
                    <form onSubmit={handleSubmit}>
                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="name">Name</label>
                            </div>
                            <div style={rightColStyle}>
                                <input
                                    id="name"
                                    type="text"
                                    name="name"
                                    value={device.name}
                                    onChange={handleChange}
                                    style={inputStyle}
                                />
                            </div>
                        </div>

                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="description">Description</label>
                            </div>
                            <div style={rightColStyle}>
                                <textarea
                                    id="description"
                                    name="description"
                                    value={device.description}
                                    onChange={handleChange}
                                    style={{ ...inputStyle, verticalAlign: 'top' }}
                                />
                            </div>
                        </div>

                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="image_url">Image URL</label>
                            </div>
                            <div style={rightColStyle}>
                                <input
                                    id="image_url"
                                    type="text"
                                    name="image_url"
                                    value={device.image_url}
                                    onChange={handleChange}
                                    style={inputStyle}
                                />
                            </div>
                        </div>

                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="video_url">Video URL</label>
                            </div>
                            <div style={rightColStyle}>
                                <input
                                    id="video_url"
                                    type="text"
                                    name="video_url"
                                    value={device.video_url}
                                    onChange={handleChange}
                                    style={inputStyle}
                                />
                            </div>
                        </div>

                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="forwarding_address">Forwarding Address</label>
                            </div>
                            <div style={rightColStyle}>
                                <input
                                    id="forwarding_address"
                                    type="text"
                                    name="forwarding_address"
                                    value={device.forwarding_address}
                                    onChange={handleChange}
                                    style={inputStyle}
                                />
                            </div>
                        </div>

                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="forwarding_port">Forwarding Port</label>
                            </div>
                            <div style={rightColStyle}>
                                <input
                                    id="forwarding_port"
                                    type="number"
                                    name="forwarding_port"
                                    value={device.forwarding_port}
                                    onChange={handleChange}
                                    style={inputStyle}
                                />
                            </div>
                        </div>

                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="record_type">Record Type</label>
                            </div>
                            <div style={rightColStyle}>
                                <select
                                    id="record_type"
                                    name="record_type"
                                    value={device.record_type}
                                    onChange={handleChange}
                                    style={inputStyle}
                                >
                                    <option value="automatic">Automatic</option>
                                    <option value="manual">Manual</option>
                                </select>
                            </div>
                        </div>

                        <div style={rowStyle}>
                            <div style={leftColStyle}>
                                <label htmlFor="is_enabled">Enabled</label>
                            </div>
                            <div style={rightColStyle}>
                                <input
                                    id="is_enabled"
                                    type="checkbox"
                                    name="is_enabled"
                                    checked={device.is_enabled}
                                    onChange={handleChange}
                                />
                            </div>
                        </div>

                        <div style={{ textAlign: 'center', marginTop: '20px' }}>
                            <button type="submit">Update</button>
                        </div>
                    </form>
                </div>

                {/* Right column with questions list */}
                <div style={{ flex: 1 }}>
                    <h2 style={{ textAlign: 'center' }}>Questions</h2>
                    <div style={questionsListStyle}>
                        {questions.map((q) => (
                            <div
                                key={q.id}
                                style={questionItemStyle}
                                onMouseEnter={() => setHoveredQuestionId(q.id)}
                                onMouseLeave={() => setHoveredQuestionId(null)}
                            >
                                {q.question}
                                {hoveredQuestionId === q.id && (
                                    <span style={{ position: 'absolute', right: '5px' }}>
                                        <button
                                            style={buttonStyle}
                                            onClick={() => {
                                                setEditingQuestion({ id: q.id, text: q.question });
                                                setShowEditModal(true);
                                            }}
                                        >
                                            Edit
                                        </button>
                                        <button
                                            style={buttonStyle}
                                            onClick={() => handleDeleteQuestion(q.id)}
                                        >
                                            Delete
                                        </button>
                                    </span>
                                )}
                            </div>
                        ))}
                    </div>
                    <div style={{ textAlign: 'center', marginTop: '10px' }}>
                        <button onClick={() => setShowAddModal(true)}>Add Question</button>
                    </div>
                </div>
            </div>

            {/* Add Question Modal */}
            {showAddModal && (
                <div style={modalOverlayStyle}>
                    <div style={modalContentStyle}>
                        <h3>Add Question</h3>
                        <textarea
                            rows="3"
                            style={{ width: '100%', padding: '5px' }}
                            value={newQuestion}
                            onChange={(e) => setNewQuestion(e.target.value)}
                        />
                        <div style={{ marginTop: '10px', textAlign: 'right' }}>
                            <button onClick={() => setShowAddModal(false)} style={buttonStyle}>
                                Cancel
                            </button>
                            <button onClick={handleAddQuestion} style={buttonStyle}>
                                Add
                            </button>
                        </div>
                    </div>
                </div>
            )}

            {/* Edit Question Modal */}
            {showEditModal && (
                <div style={modalOverlayStyle}>
                    <div style={modalContentStyle}>
                        <h3>Edit Question</h3>
                        <textarea
                            rows="3"
                            style={{ width: '100%', padding: '5px' }}
                            value={editingQuestion.text}
                            onChange={(e) =>
                                setEditingQuestion(prev => ({ ...prev, text: e.target.value }))
                            }
                        />
                        <div style={{ marginTop: '10px', textAlign: 'right' }}>
                            <button onClick={() => setShowEditModal(false)} style={buttonStyle}>
                                Cancel
                            </button>
                            <button onClick={handleUpdateQuestion} style={buttonStyle}>
                                Save
                            </button>
                        </div>
                    </div>
                </div>
            )}
        </div>
    );
};

export default Device;
