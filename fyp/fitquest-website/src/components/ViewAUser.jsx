import React, { useState, useEffect } from 'react';
import Swal from 'sweetalert2';
import '../styles/Styles.css';
import { fetchUserFeedback } from '../services/feedbackService';

const parseToArray = (data) => {
  if (!data) return [];
  if (Array.isArray(data)) return data;
  try {
    return JSON.parse(data);
  } catch {
    return [data];
  }
};

const ViewAUser = ({ user, onClose, handleSuspendToggle }) => {
  const [isEditing, setIsEditing] = useState(false);
  const [editedUser, setEditedUser] = useState({ ...user });
  const [feedbackData, setFeedbackData] = useState(null);
  const [localSuspended, setLocalSuspended] = useState(user?.isSuspended || false);

  const avatarPath = user?.avatar_url ? `/${user.avatar_url}` : '/assets/avatars/free/free1.png';
  const [bgPath, setBgPath] = useState(
    user?.background_url ? `/${user.background_url}` : '/assets/background/bg1.jpg'
  );

  useEffect(() => {
    setEditedUser({ ...user });
    setLocalSuspended(user?.isSuspended || false);
  }, [user]);

  useEffect(() => {
    const getFeedback = async () => {
      try {
        const feedback = await fetchUserFeedback(user.id);
        setFeedbackData(feedback);
      } catch (err) {
        console.error('Failed to load feedback:', err);
      }
    };
    if (user) {
      getFeedback();
    }
  }, [user]);

  if (!user) return null;

  const handleSave = async () => {
    const fieldsToCheck = ['first_name', 'last_name', 'dob', 'email', 'account', 'level'];
    const hasChanged = fieldsToCheck.some(field => editedUser[field] !== user[field]);

    if (!hasChanged) {
      await Swal.fire({
        title: 'No changes detected',
        text: 'You haven’t modified any details.',
        icon: 'info',
        confirmButtonText: 'OK',
        buttonsStyling: false,
        customClass: { confirmButton: 'confirm-btn' }
      });
      return;
    }

    const result = await Swal.fire({
      title: 'Save changes?',
      text: 'Are you sure you want to update this user\'s details?',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: 'Yes, save',
      cancelButtonText: 'Cancel',
      buttonsStyling: false,
      customClass: {
        confirmButton: 'confirm-btn',
        cancelButton: 'cancel-btn'
      }
    });

    if (result.isConfirmed) {
      console.log('Saved user:', editedUser);
      setIsEditing(false);

      await Swal.fire({
        title: 'Success',
        text: 'User details have been updated.',
        icon: 'success',
        confirmButtonText: 'OK',
        buttonsStyling: false,
        customClass: { confirmButton: 'confirm-btn' }
      });
    }
  };

  const likedFeatures = parseToArray(feedbackData?.liked_features);
  const problems = parseToArray(feedbackData?.problems);

  const onSuspendClick = async () => {
    await handleSuspendToggle(user);
    setLocalSuspended(prev => !prev); // Flip the local state so button label changes instantly
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div
        className="modal-content user-modal-split"
        onClick={(e) => e.stopPropagation()}
      >
        <button className="modal-close" onClick={onClose}>✕</button>

        {/* LEFT PANEL */}
        <div className="user-info-panel">
          <div className="avatar-stack">
            <div
              className="avatar-bg"
              style={{ backgroundImage: `url(${bgPath})` }}
            />
            <img
              src={avatarPath}
              onError={(e) => e.currentTarget.src = '/assets/avatars/free/free1.png'}
              alt="User Avatar"
              className="avatar-img"
            />
          </div>

          <h2>{user.username}</h2>
          <p><strong>First Name:</strong> {isEditing ? (
            <input
              type="text"
              value={editedUser.first_name}
              onChange={(e) => setEditedUser({ ...editedUser, first_name: e.target.value})} />
            ) : user.first_name}</p>
          <p><strong>Last Name:</strong> {isEditing ? (
            <input  
              type="text"
              value={editedUser.last_name}
              onChange={(e) => setEditedUser({ ...editedUser, last_name: e.target.value})} />
            ) : user.last_name}</p>
          <p><strong>Date of Birth:</strong> {isEditing ? (
            <input 
              type="date"
              value={editedUser.dob}
              onChange={(e) => setEditedUser({ ...editedUser, dob: e.target.value})}
            />
          ) : user.dob} </p>
          <p><strong>Email:</strong> {isEditing ? (
            <input  
              type="text"
              value={editedUser.email}
              onChange={(e) => setEditedUser({ ...editedUser, email: e.target.value})} />
            ) : user.email}</p>
          <p><strong>Account:</strong> {isEditing ? (
            <input  
              type="text"
              value={editedUser.account}
              onChange={(e) => setEditedUser({ ...editedUser, account: e.target.value})} />
            ) : user.account}</p>
          <p><strong>Level:</strong> {isEditing ? (
            <input  
              type="text"
              value={editedUser.level}
              onChange={(e) => setEditedUser({ ...editedUser, level: e.target.value})} />
            ) : user.level}</p>

          {isEditing ? (
            <div className="button-row">
              <button 
                className="confirm-btn" 
                onClick={handleSave}>Save</button>
              <button
                className="cancel-btn"
                onClick={() => {
                  setEditedUser({ ...user });
                  setIsEditing(false);
                }}>Cancel</button>
            </div>
          ) : (
            <div className='button-row center'>
              <button className="edit-btn" onClick={() => setIsEditing(true)}>Edit</button>
              <button
                className={localSuspended ? 'unsuspend-btn' : 'suspend-btn'}
                onClick={onSuspendClick}
              >
                {localSuspended ? 'Unsuspend' : 'Suspend'}
              </button>
            </div>
          )}
        </div>

        {/* RIGHT PANEL */}
        <div className="user-preferences-panel">
          <div className="prefs-feedback-container">
            
            {/* Preferences */}
            <div className="preferences-block">
              <h3>User Preferences</h3>
              <ul>
                <li><strong>Workout Frequency:</strong> {user.preferences.workout_frequency}</li>
                <li><strong>Fitness Goal:</strong> {user.preferences.fitness_goal}</li>
                <li><strong>Workout Time:</strong> {user.preferences.workout_time}</li>
                <li><strong>Fitness Level:</strong> {user.preferences.fitness_level}</li>
                <li><strong>Injury:</strong> {user.preferences.injury}</li>
              </ul>
            </div>

            {/* Feedback */}
            <div className="feedback-block">
              <h3>What Users Liked</h3>
              {likedFeatures.length > 0 ? (
                <ul>
                  {likedFeatures.map((item, index) => (
                    <li key={`like-${index}`}>{item}</li>
                  ))}
                </ul>
              ) : (
                <p>No features liked</p>
              )}

              <h3>What Users Didn't Like</h3>
              {problems.length > 0 ? (
                <ul>
                  {problems.map((problem, index) => (
                    <li key={`problem-${index}`}>{problem}</li>
                  ))}
                </ul>
              ) : (
                <p>No issues reported</p>
              )}
            </div>

          </div>
        </div>

      </div>
    </div>
  );
};

export default ViewAUser;
