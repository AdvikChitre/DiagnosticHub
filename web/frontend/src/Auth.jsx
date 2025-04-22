import React, { useState, useEffect } from 'react';
import { SERVER_URL } from './main.jsx';

const Auth = () => {
    const [name, setName] = useState('');
    const [password, setPassword] = useState('');
    const [errorMessage, setErrorMessage] = useState('');

    const isTokenValid = (token) => {
        try {
            const payloadBase64 = token.split('.')[1];
            const payload = JSON.parse(atob(payloadBase64));
            if (payload.exp && payload.exp * 1000 > Date.now()) {
                return true;
            }
        } catch (error) {
            console.error('Invalid token:', error);
        }
        return false;
    };

    useEffect(() => {
        const token = localStorage.getItem('jwtToken');
        if (token && isTokenValid(token)) {
            window.location.href = '/home';
        }
    }, []);

    // Disable scrolling when the Auth component is mounted.
    useEffect(() => {
        const originalStyle = window.getComputedStyle(document.body).overflow;
        document.body.style.overflow = 'hidden';
        return () => {
            document.body.style.overflow = originalStyle;
        };
    }, []);

    const hashPassword = async (password) => {
        const encoder = new TextEncoder();
        const data = encoder.encode(password);
        const hashBuffer = await crypto.subtle.digest('SHA-256', data);
        const hashArray = Array.from(new Uint8Array(hashBuffer));
        const hashHex = hashArray.map(b => b.toString(16).padStart(2, '0')).join('');
        return hashHex;
    };

    const handleLogin = async () => {
        try {
            const hashedPassword = await hashPassword(password);
            const loginRequest = { name, password: hashedPassword };
            console.log('Login request:', loginRequest);
            
            const response = await fetch(`${SERVER_URL}/api/login`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(loginRequest)
            });
            
            if (response.ok) {
                console.log('Login successful');
                const { token } = await response.json();
                localStorage.setItem('jwtToken', token);
                localStorage.setItem('name', name);
                window.location.href = '/home';
            } else {
                console.error('Login failed');
                setErrorMessage('Incorrect username or password');
                setTimeout(() => {
                    setErrorMessage('');
                }, 5000);
            }
        } catch (error) {
            console.error('Error during login:', error);
            setErrorMessage('Incorrect username or password');
            setTimeout(() => {
                setErrorMessage('');
            }, 5000);
        }
    };

    const handleKeyDown = (event) => {
        if (event.key === 'Enter') {
            handleLogin();
        }
    };

    const inputStyle = {
        fontSize: '1.2rem',
        width: '250px',
        padding: '10px',
        borderRadius: '10px'
    };

    const buttonStyle = {
        fontSize: '1.2rem',
        padding: '10px 20px'
    };

    const errorStyle = {
        color: 'red',
        fontSize: '1rem'
    };

    return (
        <div style={{
            display: 'flex', 
            flexDirection: 'column', 
            alignItems: 'center', 
            gap: '15px',
            padding: '20px'
        }}>
            <input 
                type="text" 
                placeholder="Company" 
                value={name} 
                onChange={(e) => setName(e.target.value)}
                onKeyDown={handleKeyDown}
                style={inputStyle}
            />
            <input 
                type="password" 
                placeholder="Password" 
                value={password} 
                onChange={(e) => setPassword(e.target.value)}
                onKeyDown={handleKeyDown}
                style={inputStyle}
            />
            <button onClick={handleLogin} style={buttonStyle}>Login</button>
            {errorMessage && <div style={errorStyle}>{errorMessage}</div>}
        </div>
    );
};

export default Auth;