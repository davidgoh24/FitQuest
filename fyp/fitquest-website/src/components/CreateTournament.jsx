import React, { useState, useEffect } from 'react';
import '../styles/Styles.css';
import './CreateTournament.css';
import { useNavigate } from 'react-router-dom';
import { createTournament } from '../services/tournamentService';
import { fetchAllExercises } from '../services/exerciseService';

const CreateTournament = () => {
  const navigate = useNavigate();
  const [exercises, setExercises] = useState([]);

  const [formData, setFormData] = useState({
    title: '',
    description: '',
    startDate: '',
    endDate: '',
    features: [],
    target_exercise_pattern: '',
    reward_xp_first: 200,
    reward_xp_second: 100,
    reward_xp_other: 50,
    reward_tokens_first: 200,
    reward_tokens_second: 100,
    reward_tokens_other: 20
  });

  useEffect(() => {
    fetchAllExercises()
      .then(setExercises)
      .catch(err => console.error('Failed to fetch exercises:', err));
  }, []);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await createTournament(formData);
      navigate('/All-Tournaments');
    } catch (err) {
      console.error('Failed to create tournament', err);
    }
  };

  return (
    <div className="admin-container">
      <div className="user-content">
        <div className="create-tournament-content">
          <div className="user-header-row">
            <h2>Create New Tournament</h2>
          </div>

          <form className="create-tournament-form" onSubmit={handleSubmit}>
            <label>Title*</label>
            <input
              type="text"
              name="title"
              value={formData.title}
              onChange={handleChange}
              required
            />

            <label>Description*</label>
            <textarea
              name="description"
              value={formData.description}
              onChange={handleChange}
              rows={4}
              required
            />

            <label>Start Date*</label>
            <input
              type="datetime-local"
              name="startDate"
              value={formData.startDate}
              onChange={handleChange}
              required
            />

            <label>End Date*</label>
            <input
              type="datetime-local"
              name="endDate"
              value={formData.endDate}
              onChange={handleChange}
              required
            />

            <label>Target Exercise Pattern*</label>
            <select
              name="target_exercise_pattern"
              value={formData.target_exercise_pattern}
              onChange={handleChange}
              required
            >
              <option value="">-- Select an Exercise --</option>
              {exercises.map(ex => (
                <option key={ex.exercise_id} value={ex.exercise_name}>
                  {ex.exercise_name}
                </option>
              ))}
            </select>

            <h3>Reward XP</h3>
            <label>1st Place XP</label>
            <input type="number" name="reward_xp_first" value={formData.reward_xp_first} onChange={handleChange} />
            <label>2nd Place XP</label>
            <input type="number" name="reward_xp_second" value={formData.reward_xp_second} onChange={handleChange} />
            <label>Other Places XP</label>
            <input type="number" name="reward_xp_other" value={formData.reward_xp_other} onChange={handleChange} />

            <h3>Reward Tokens</h3>
            <label>1st Place Tokens</label>
            <input type="number" name="reward_tokens_first" value={formData.reward_tokens_first} onChange={handleChange} />
            <label>2nd Place Tokens</label>
            <input type="number" name="reward_tokens_second" value={formData.reward_tokens_second} onChange={handleChange} />
            <label>Other Places Tokens</label>
            <input type="number" name="reward_tokens_other" value={formData.reward_tokens_other} onChange={handleChange} />

            <div className="button-row">
              <button
                className="cancel-btn"
                type="button"
                onClick={() => navigate('/All-Tournaments')}
              >
                Cancel
              </button>
              <button className="create-btn" type="submit">
                Create
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};

export default CreateTournament;
