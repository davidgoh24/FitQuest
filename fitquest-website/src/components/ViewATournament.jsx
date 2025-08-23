import React, { useState, useEffect } from 'react';
import '../styles/Styles.css';
import { useNavigate } from 'react-router-dom';
import { fetchAllExercises } from '../services/exerciseService';
import { updateTournament } from '../services/tournamentService';

const ViewATournament = ({ tournament, onClose, onUpdate }) => {
  const navigate = useNavigate();
  const [isEditing, setIsEditing] = useState(false);
  const [editedTournament, setEditedTournament] = useState({ ...tournament });
  const [exercises, setExercises] = useState([]);

  useEffect(() => {
    fetchAllExercises().then(setExercises).catch(() => {});
  }, []);

  if (!tournament) return null;

  const handleSave = async () => {
    try {
      await updateTournament(tournament.id, editedTournament);
      if (onUpdate) onUpdate(); 
      setIsEditing(false);
    } catch (err) {
      console.error('Failed to update tournament', err);
    }
  };

  return (
    <div className="view-tournament-modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <button className="modal-close" onClick={onClose}>✕</button>
        <h2 className="pixel-font">{isEditing ? 'Edit Tournament' : 'View Tournament'}</h2>

        <label>Title</label>
        {isEditing ? (
          <input
            type="text"
            value={editedTournament.title}
            onChange={(e) => setEditedTournament({ ...editedTournament, title: e.target.value })}
          />
        ) : (
          <p>{tournament.title}</p>
        )}

        <label>Description</label>
        {isEditing ? (
          <textarea
            value={editedTournament.description}
            rows={4}
            onChange={(e) => setEditedTournament({ ...editedTournament, description: e.target.value })}
          />
        ) : (
          <p>{tournament.description}</p>
        )}

        <label>Date</label>
        <div className="date-group-row">
          <span>Start date</span>
          <div className="date-time-inputs">
            {isEditing ? (
              <>
                <input
                  type="date"
                  value={editedTournament.startDate?.split('T')[0] || ''}
                  onChange={(e) => setEditedTournament({ ...editedTournament, startDate: e.target.value })}
                />
                <input
                  type="time"
                  value={editedTournament.startTime || '00:00'}
                  onChange={(e) => setEditedTournament({ ...editedTournament, startTime: e.target.value })}
                />
              </>
            ) : (
              <p>{new Date(tournament.startDate).toLocaleDateString()} {tournament.startTime || '00:00'}</p>
            )}
          </div>
        </div>

        <div className="date-group-row">
          <span>End date</span>
          <div className="date-time-inputs">
            {isEditing ? (
              <>
                <input
                  type="date"
                  value={editedTournament.endDate?.split('T')[0] || ''}
                  onChange={(e) => setEditedTournament({ ...editedTournament, endDate: e.target.value })}
                />
                <input
                  type="time"
                  value={editedTournament.endTime || '00:00'}
                  onChange={(e) => setEditedTournament({ ...editedTournament, endTime: e.target.value })}
                />
              </>
            ) : (
              <p>{new Date(tournament.endDate).toLocaleDateString()} {tournament.endTime || '00:00'}</p>
            )}
          </div>
        </div>

        <label>Target Exercise</label>
        {isEditing ? (
          <select
            value={editedTournament.target_exercise_pattern || ''}
            onChange={(e) =>
              setEditedTournament({ ...editedTournament, target_exercise_pattern: e.target.value })
            }
          >
            <option value="">-- Select an Exercise --</option>
            {exercises.map((ex) => (
              <option key={ex.exercise_id} value={ex.exercise_name}>
                {ex.exercise_name}
              </option>
            ))}
          </select>
        ) : (
          <p>{tournament.target_exercise_pattern || 'N/A'}</p>
        )}

        <label>Rewards (XP / Tokens)</label>
        <div className="form-row-3col">
          {['first', 'second', 'other'].map((pos) => (
            <div key={pos} className="form-group-col">
              <span>{pos.charAt(0).toUpperCase() + pos.slice(1)} Place</span>
              {isEditing ? (
                <div className="reward-row">
                  <input
                    type="number"
                    className="reward-input"
                    value={editedTournament[`reward_xp_${pos}`] ?? ''}
                    onChange={(e) =>
                      setEditedTournament({
                        ...editedTournament,
                        [`reward_xp_${pos}`]: e.target.value === '' ? null : Number(e.target.value)
                      })
                    }
                  />
                  <span>XP</span>
                  <input
                    type="number"
                    className="reward-input"
                    value={editedTournament[`reward_tokens_${pos}`] ?? ''}
                    onChange={(e) =>
                      setEditedTournament({
                        ...editedTournament,
                        [`reward_tokens_${pos}`]: e.target.value === '' ? null : Number(e.target.value)
                      })
                    }
                  />
                  <span>Tokens</span>
                </div>
              ) : (
                <p>
                  {tournament[`reward_xp_${pos}`]} XP / {tournament[`reward_tokens_${pos}`]} Tokens
                </p>
              )}
            </div>
          ))}
        </div>

        <div className="button-row">
          {isEditing ? (
            <>
              <button
                className="cancel-btn"
                onClick={() => {
                  setEditedTournament({ ...tournament });
                  setIsEditing(false);
                }}
              >
                Cancel
              </button>
              <button
                className="confirm-btn"
                onClick={handleSave}
              >
                Save
              </button>
            </>
          ) : (
            <button className="edit-btn" onClick={() => setIsEditing(true)}>
              Edit
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default ViewATournament;
