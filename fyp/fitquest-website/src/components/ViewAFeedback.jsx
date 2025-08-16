import React from 'react';
import '../styles/Styles.css';

const ViewAFeedback = ({ feedback, onClose }) => {
  if (!feedback) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '700px', padding: '2rem' }}>
        <button className="modal-close" onClick={onClose}>✕</button>

        {/* Header with avatar and username */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1rem' }}>
          <img src={feedback.avatar} alt="avatar" style={{ width: '60px', height: '60px', borderRadius: '50%' }} />
          <div>
            <h3 style={{ margin: 0 }}>@{feedback.username}</h3>
            <p style={{ color: '#888', margin: 0 }}>{feedback.role}</p>
          </div>
        </div>

        {/* Status + Date */}
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '1rem' }}>
          <span className={`badge ${feedback.status.toLowerCase()}`}>{feedback.status}</span>
          <em style={{ fontWeight: 600 }}>{feedback.date}</em>
        </div>

        {/* Feedback Body */}
        <p style={{ lineHeight: '1.6', fontSize: '1rem', whiteSpace: 'pre-wrap' }}>
          {feedback.body}
        </p>
      </div>
    </div>
  );
};

export default ViewAFeedback;
