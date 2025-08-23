import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import '../styles/Styles.css';

const workoutCategories = [
  {
    id: 'strength',
    name: 'Strength Training',
    image: '/workout-strength.jpg',
    duration: '8 Minutes',
    level: 'Advanced',
  },
  {
    id: 'yoga',
    name: 'Home Yoga',
    image: '/workout-yoga.webp',
    duration: '8 Minutes',
    level: 'Advanced',
  },
  {
    id: 'core',
    name: 'Core Training',
    image: '/workout-core.jpg',
    duration: '8 Minutes',
    level: 'Advanced',
  },
];

const ViewAllWorkoutCategories = () => {
  const [searchTerm, setSearchTerm] = useState('');
  const navigate = useNavigate();

  const filteredCategories = workoutCategories.filter(cat =>
    cat.name.toLowerCase().includes(searchTerm.toLowerCase())
  );

  return (
    <div className="all-workouts-container">
      <header>
        <img src="/white-logo.png" alt="FitQuest Logo" className="logo" />
        <nav><a href="/dashboard">Dashboard</a></nav>
      </header>

      <div className="page-title-with-search">
        <h2>Workout Categories</h2>
        <div className="search-bar-container">
          <input
            type="text"
            placeholder="Search categories..."
            className="search-bar"
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
          />
          <button className="search-icon-btn">
            <img src="/icon-search.png" alt="Search" />
          </button>
        </div>
      </div>

      <div className="workout-banner-list">
        {filteredCategories.map(cat => (
          <div
            key={cat.id}
            className="workout-banner"
            onClick={() => navigate(`/admin/workouts/${cat.id}`)}
          >
            <img src={cat.image} alt={cat.name} />
            <div className="banner-overlay">
              <h3>{cat.name}</h3>
              <p>{cat.duration} | {cat.level}</p>
              <button
                className="edit-btn"
                onClick={(e) => {
                  e.stopPropagation();
                  console.log('Edit', cat.id);
                  // TODO: add edit modal or route here
                }}
              >
                Edit
              </button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ViewAllWorkoutCategories;
