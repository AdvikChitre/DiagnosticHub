import React, { useState, useEffect } from 'react';
import {
    LineChart,
    Line,
    XAxis,
    YAxis,
    CartesianGrid,
    Tooltip,
    Legend,
    ResponsiveContainer
} from 'recharts';
import hostUrl from './App.jsx'; // Adjust the import path as necessary

const Graph = ({ studyId }) => {
    console.log('Graph component rendered with studyId:', studyId);
    const [data, setData] = useState(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState(null);
    const hostUrl = 'http://192.168.1.230:3001'

    useEffect(() => {
        if (!studyId) {
            setData(null);
            return;
        }

        setLoading(true);
        setError(null);

        fetch(`${hostUrl}/api/study/${studyId}`)
            .then((response) => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then((fetchedData) => {
                // expecting fetchedData to be an array of objects where each object has "timestamp" and "data"
                setData(fetchedData.data);
                setLoading(false);
            })
            .catch((err) => {
                setError(err);
                setLoading(false);
            });
        console.log(data);
    }, [studyId]);

    return (
        <div
            style={{
                width: '100%',
                height: '400px',
                backgroundColor: '#f0f0f0',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                borderRadius: '10px'
            }}
        >
            {loading ? (
                <p>Loading...</p>
            ) : error ? (
                <p>Error: {error.message}</p>
            ) : data ? (
                <ResponsiveContainer width="100%" height="100%">
                    <LineChart data={data}>
                        <CartesianGrid strokeDasharray="3 3" />
                        <XAxis 
                            dataKey="timestamp"
                            tickFormatter={(tick) => {
                                const date = new Date(tick);
                                return date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' });
                            }}
                        />
                        <YAxis domain={[-12, 12]} />
                        <Tooltip 
                            labelFormatter={(label) => {
                                const date = new Date(label);
                                return date.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit', second: '2-digit' });
                            }}
                        />
                        <Legend />
                        <Line type="monotone" dataKey="data" stroke="#8884d8" activeDot={{ r: 8 }} />
                    </LineChart>
                </ResponsiveContainer>
            ) : (
                <p>No data available</p>
            )}
        </div>
    );
};

export default Graph;