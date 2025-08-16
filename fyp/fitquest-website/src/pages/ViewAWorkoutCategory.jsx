import React from 'react';
import { useParams } from 'react-router-dom';
import '../styles/Styles.css';

const allWorkoutData = {
  strength: [
    { id: 'w1', title: 'Goblet Squat', duration: '6 mins', image: '/goblet-squat.jpg' }, 
    { id: 'w2', title: 'Weighted Lunges', duration: '7 mins', image: '/lunges.webp' },
    { id: 'w3', title: 'Deadlifts', duration: '5 mins', image: '/deadlift.webp' },
  ],
  yoga: [
    { id: 'y1', title: 'Morning Flow', duration: '10 mins', image: '/yoga-flow.jpg' },
    { id: 'y2', title: 'Sun Salutations', duration: '8 mins', image: '/sun-salute.jpg' },
    { id: 'y3', title: 'Balance Practice', duration: '7 mins', image: '/yoga-balance.jpg' },
    { id: 'y4', title: 'Evening Stretch', duration: '9 mins', image: '/evening-stretch.jpg' },
  ],
  core: [
    { id: 'c1', title: 'Plank Burnout', duration: '4 mins', image: '/plank.jpg' },
    { id: 'c2', title: 'Russian Twists', duration: '5 mins', image: '/twists.jpg' },
    { id: 'c3', title: 'Sit Ups Blast', duration: '6 mins', image: '/situps.jpg' },
    { id: 'c4', title: 'Mountain Climbers', duration: '5 mins', image: '/climbers.jpg' },
  ],
};

const ViewAWorkoutCategory = () => {
  const { categoryId } = useParams();

  const workouts = allWorkoutData[categoryId] || [];
  const categoryTitle = {
    strength: 'Strength Training',
    yoga: 'Home Yoga',
    core: 'Core Training',
  }[categoryId] || 'Workout';

  const handleEdit = (workoutId) => {
    console.log('Edit workout:', workoutId);
  };

  return (
    <div className="all-workouts-container">
      <header>
        <img src="/white-logo.png" alt="FitQuest Logo" className="logo" />
        <nav><a href="/dashboard">Dashboard</a></nav>
      </header>

      <div className="page-title-with-search">
        <h2>{categoryTitle}</h2>
      </div>

      <div className="set-grid">
        {workouts.map(workout => (
          <div className="workout-card" key={workout.id}>
            <img src={workout.image} alt={workout.title} className="workout-card-image" />
            <div className="workout-card-body">
              <h4 className="workout-card-title">{workout.title}</h4>
              <p className="workout-card-duration">Duration: {workout.duration}</p>
              <button className="edit-btn" onClick={() => handleEdit(workout.id)}>Edit</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
};

export default ViewAWorkoutCategory;