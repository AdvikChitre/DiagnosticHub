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

    const fetchDeviceOptions = async () => {
        if (!deviceID) {
            console.error('No device ID found');
            return;
        }
        try {
            const token = localStorage.getItem('jwtToken');
            const deviceRequest = { wearableID: deviceID };
            const response = await fetch(`${SERVER_URL}/api/wearable/get`, {
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

    useEffect(() => {
        fetchDeviceOptions();
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
            const response = await fetch(`${SERVER_URL}/api/wearable/update`, {
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

    return (
        <div style={{ padding: '20px' }}>
            <h1 style={{ textAlign: 'center' }}>Device Configuration</h1>
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
    );
};

export default Device;
