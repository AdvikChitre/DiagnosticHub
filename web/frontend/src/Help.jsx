import React from 'react';

const Help = () => {
    return (
        <div style={{ color: '#EF476F', height: '100vh', overflowY: 'auto', padding: '20px' }}>
            <div style={{ backgroundColor: '#f9f9f9', border: '1px solid #ccc', borderRadius: '4px', padding: '20px', marginBottom: '20px' }}>
                <h2>Usage Guide</h2>
                <p>TODO</p>
            </div>
            <div style={{ backgroundColor: '#e9e9e9', border: '1px solid #ccc', borderRadius: '4px', padding: '20px' }}>
                <h2>Relink Libraries</h2>
                <p>
                    To comply with the LGPL distribution licence whilst keeping code proprietary, 
                    <br /> all users must have access to 'shared object' files so they can change underlying libraries
                </p>
                <a href="/path/to/objectFile.zip" download style={{ textDecoration: 'none', display: 'block', width: 'fit-content', margin: '0 auto' }}>
                    <button style={{
                        display: 'flex',
                        alignItems: 'center',
                        backgroundColor: '#007bff',
                        color: '#fff',
                        border: 'none',
                        borderRadius: '4px',
                        padding: '10px 20px',
                        cursor: 'pointer'
                    }}>
                        <svg xmlns="http://www.w3.org/2000/svg" style={{ marginRight: '8px' }} width="16" height="16" fill="currentColor" viewBox="0 0 16 16">
                            <path d="M.5 9.9v4.6a.5.5 0 0 0 .5.5h14a.5.5 0 0 0 .5-.5V9.9l-7.5 7.5-7.5-7.5z"/>
                            <path d="M7.5 1v9h1V1h-1z"/>
                        </svg>
                        Download Object File ZIP
                    </button>
                </a>
            </div>
        </div>
    );
};

export default Help;