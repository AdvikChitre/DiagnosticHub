import { useState } from 'react';
import * as React from 'react';
import './App.css';
import Graph from './Graph.jsx';  // Adjust the path if Graph.jsx is located elsewhere

function App() {
  const hostUrl = 'http://192.168.1.230:3001';

  const fallbackStudy = "08:A6:F7:64:55:A6";
  const [studies, setStudies] = useState([fallbackStudy]);
  const [selectedStudy, setSelectedStudy] = useState(fallbackStudy);

  // React.useEffect(() => {
  //   fetch(`${hostUrl}/api/studies`)
  //     .then(response => response.json())
  //     .then(studyIds => {
  //       if (Array.isArray(studyIds) && studyIds.length > 0) {
  //         setStudies(studyIds);
  //         setSelectedStudy(studyIds[0]); // Set the first study as the default selection
  //       } else {
  //         setStudies([]);
  //       }
  //     })
  //     .catch(error => console.error('Error fetching study data:', error));
  // }, []);

  const handleChange = (event) => {
    setSelectedStudy(event.target.value);
  };

  return (
    <>
      <div style={{ marginBottom: '20px' }}>
        <select
          value={selectedStudy}
          onChange={handleChange}
          style={{
            padding: '10px',
            borderRadius: '8px',
            border: '1px solid #ccc',
            outline: 'none'
          }}
        >
          {studies.map((study) => (
            <option key={study} value={study}>
              {study}
            </option>
          ))}
        </select>
      </div>
      <div style={{
        width: '1300px',
        height: '400px',
        backgroundColor: '#f0f0f0',
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        borderRadius: '10px'
      }}>
        <Graph studyId={selectedStudy} />
      </div>
    </>
  );
}

export default App;
