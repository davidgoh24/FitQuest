import React, { useState, useEffect } from 'react';
import './ViewAllTournaments.css';
import ViewATournament from '../components/ViewATournament';
import PageLayout from '../components/PageLayout';
import { fetchAllTournaments } from '../services/tournamentService';

const ViewAllTournaments = () => {
  const [tournaments, setTournaments] = useState([]);
  const [selectedTournament, setSelectedTournament] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedTab, setSelectedTab] = useState('All');
  const [isEditing, setIsEditing] = useState(false);

  const loadTournaments = async () => {
    try {
      const data = await fetchAllTournaments();
      setTournaments(data);
    } catch (err) {
      console.error('Error fetching tournaments:', err);
    }
  };

  useEffect(() => {
    loadTournaments();
  }, []);

  const filteredTournaments = tournaments.filter((t) => {
    const matchesSearch = t.title.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesTab =
      selectedTab === 'All' ||
      (selectedTab === 'Ongoing' && new Date(t.endDate) > new Date()) ||
      (selectedTab === 'Completed' && new Date(t.endDate) <= new Date());
    return matchesSearch && matchesTab;
  });

  return (
    <PageLayout>
      <div className="admin-container">
        <div className="user-content">
          <div className="user-header-row">
            <h2>All Tournaments</h2>
            <div className="header-row">
              <div className="search-bar-container">
                <input
                  className="search-bar"
                  type="text"
                  placeholder="Search tournaments..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
                <button className="search-icon-btn">
                  <img src="/icon-search.png" alt="Search" />
                </button>
              </div>
            </div>
          </div>

          <div className="tab-and-create-row">
            <div className="user-tabs-container">
              {['All', 'Ongoing', 'Completed'].map((tab) => (
                <div
                  key={tab}
                  className={`user-tab ${selectedTab === tab ? 'active' : ''}`}
                  onClick={() => setSelectedTab(tab)}
                >
                  {tab}
                </div>
              ))}
            </div>
            <button
              className="create-btn"
              onClick={() => window.location.href = '/create-tournament'}
            >
              + Create New Tournament
            </button>
          </div>

          <table className="tournament-table">
            <thead>
              <tr>
                <th>No.</th>
                <th>Tournament</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Status</th>
                <th>Manage</th>
              </tr>
            </thead>
            <tbody>
              {filteredTournaments.map((tour, index) => (
                <tr key={tour.id} onClick={() => setSelectedTournament(tour)}>
                  <td>{index + 1}</td>
                  <td>{tour.title}</td>
                  <td>{new Date(tour.startDate).toLocaleString()}</td>
                  <td>{new Date(tour.endDate).toLocaleString()}</td>
                  <td>
                    <span className={`badge ${new Date(tour.endDate) > new Date() ? 'ongoing' : 'completed'}`}>
                      {new Date(tour.endDate) > new Date() ? 'Ongoing' : 'Completed'}
                    </span>
                  </td>
                  <td>
                    <button
                      className="edit-btn"
                      onClick={(e) => {
                        e.stopPropagation();
                        setSelectedTournament(tour);
                        setIsEditing(false);
                      }}
                    >
                      View
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>

          {selectedTournament && (
            <div className="tournament-modal-overlay" onClick={() => setSelectedTournament(null)}>
              <div className="tournament-modal-content" onClick={(e) => e.stopPropagation()}>
                <ViewATournament
                  tournament={selectedTournament}
                  onClose={() => setSelectedTournament(null)}
                  isEditing={isEditing}
                  setIsEditing={setIsEditing}
                  onUpdate={loadTournaments}
                />
              </div>
            </div>
          )}
        </div>
      </div>
    </PageLayout>
  );
};

export default ViewAllTournaments;
