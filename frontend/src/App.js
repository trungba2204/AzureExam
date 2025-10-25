import React, { useState, useEffect } from 'react';
import './App.css';
import PlayerAssetsReport from './components/PlayerAssetsReport';
import config from './config';

function App() {
  const [reportData, setReportData] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    fetchReportData();
  }, []);

  const fetchReportData = async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await fetch(config.API_BASE_URL + '/api/getassetsbyplayer');
      
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }
      
      const result = await response.json();
      
      if (result.success) {
        setReportData(result.data || []);
      } else {
        throw new Error(result.message || 'Failed to fetch data');
      }
    } catch (err) {
      console.error('Error fetching report data:', err);
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="App">
      <div className="container py-5">
        <header className="text-center mb-5">
          <div className="logo-container mb-4">
            <h1 className="display-4 text-white fw-bold">
              🎮 BATTLE GAME
            </h1>
            <p className="lead text-white-50">Player Assets Management System</p>
          </div>
        </header>

        <main>
          <PlayerAssetsReport 
            data={reportData} 
            loading={loading} 
            error={error}
            onRefresh={fetchReportData}
          />
        </main>

        <footer className="text-center mt-5">
          <p className="text-white-50">
            Developed for Azure Solutions - SET01 Exam
          </p>
        </footer>
      </div>
    </div>
  );
}

export default App;

