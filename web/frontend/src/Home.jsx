import React, { useState, useEffect } from 'react';
import { SERVER_URL } from './main.jsx';
import './App.css';

function Home() {
    const [devices, setDevices] = useState([]);
    const [error, setError] = useState(null);

    // Disable scoll
    document.body.style.overflow = 'hidden';

    const loadPage = () => {
        // Check auth
        const token = localStorage.getItem('jwtToken');
        if (!token) {
            window.location.href = '/api/login';
            return;
        }

        // Fetch devices
        fetch(`${SERVER_URL}/api/wearables`, {
            headers: {
                'Authorization': `Bearer ${token}`,
            },
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Error fetching devices');
                }
                console.log('Response:', response);
                return response.json();
            })
            .then(data => setDevices(data.wearables))
            .catch(err => setError(err.message));
    };

    // Load on start
    useEffect(() => {
        loadPage();
    }, []);

    function LogoutButton() {
        function logout() {
            localStorage.removeItem('jwtToken');
            window.location.href = '/api/login';
        }
        return (
            <button onClick={logout} style={{ position: 'fixed', top: '10px', right: '10px' }}>
                Log Out
            </button>
        );
    }

    function selectDevice(device) {
        localStorage.setItem('selectedDeviceName', device.name);
        localStorage.setItem('selectedDeviceID', device.id);
        window.location.href = '/device';
    }

    function addDevice() {
        const overlay = document.createElement('div');
        overlay.style.position = 'fixed';
        overlay.style.top = 0;
        overlay.style.left = 0;
        overlay.style.width = '100%';
        overlay.style.height = '100%';
        overlay.style.backgroundColor = 'rgba(0, 0, 0, 0.5)';
        overlay.style.display = 'flex';
        overlay.style.alignItems = 'center';
        overlay.style.justifyContent = 'center';
        overlay.style.zIndex = 1000;

        const container = document.createElement('div');
        container.style.background = 'white';
        container.style.padding = '20px';
        container.style.borderRadius = '8px';
        container.style.display = 'flex';
        container.style.flexDirection = 'column';
        container.style.alignItems = 'center';

        // Text input
        const input = document.createElement('input');
        input.type = 'text';
        input.placeholder = 'Enter device name';
        input.style.marginBottom = '10px';
        input.style.borderRadius = '5px';

        const btnContainer = document.createElement('div');
        btnContainer.style.display = 'flex';
        btnContainer.style.width = '100%';
        btnContainer.style.justifyContent = 'space-between';

        // Cancel
        const cancelButton = document.createElement('button');
        cancelButton.textContent = 'Cancel';
        cancelButton.onclick = () => {
            document.body.removeChild(overlay);
        };

        // Confirm
        const confirmButton = document.createElement('button');
        confirmButton.textContent = 'Confirm';
        confirmButton.onclick = () => {
            console.log('New device name:', input.value);
            const nameRequest = { name: input.value };
            const token = localStorage.getItem('jwtToken');

            fetch(`${SERVER_URL}/api/wearable/add`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`,
            },
            body: JSON.stringify(nameRequest)
            })
            .then(response => {
                if (!response.ok) {
                throw new Error('Error adding device');
                }
                return response.json();
            })
            .then(data => {
                console.log('Device added successfully:', data.message);
                loadPage()
            })
            .catch(err => {
                console.error(err);
                alert('Failed to add device');
            })
            .finally(() => {
                // Remove the overlay after confirmation
                document.body.removeChild(overlay);
            });
        };

        btnContainer.appendChild(cancelButton);
        btnContainer.appendChild(confirmButton);
        container.appendChild(input);
        container.appendChild(btnContainer);
        overlay.appendChild(container);
        document.body.appendChild(overlay);
    }

    return (
        <>
            <h1>Devices</h1>
            <LogoutButton />
            {error && <p>{error}</p>}
            {devices.length > 0 ? (
                <ul style={{ listStyle: 'none', padding: 0 }}>
                    {devices.map((device, index) => (
                        <li key={index} style={{ marginBottom: '10px' }}>
                            <button onClick={() => selectDevice(device)}>
                                {device.name}
                            </button>
                        </li>
                    ))}
                </ul>
            ) : (
                <p>No devices found.</p>
            )}
            <div style={{ marginTop: '20px', justifyContent: 'center', display: 'flex' }}>
                <button
                    onClick={addDevice}
                    style={{
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'center',
                        fontSize: '32px',
                        width: '50px',
                        height: '50px',
                        borderRadius: '50%',
                        border: 'none',
                    }}
                >
                    +
                </button>
            </div>
        </>
    );
}

export default Home;