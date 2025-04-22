import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom'
import './index.css'
import Home from './Home.jsx'
import Auth from './Auth.jsx'
import Device from './Device.jsx'

// Set the server IP for global usage
const SERVER_IP = 'localhost';
const SERVER_PORT = 3000;
export const SERVER_URL = `http://${SERVER_IP}:${SERVER_PORT}`;

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <BrowserRouter>
      <Routes>
        <Route path="/login" element={<Auth />} />
        <Route path="/home" element={<Home />} />
        <Route path="/device" element={<Device />} />
        <Route path="*" element={<Navigate to="/login" replace />} />
      </Routes>
    </BrowserRouter>
  </StrictMode>,
)
