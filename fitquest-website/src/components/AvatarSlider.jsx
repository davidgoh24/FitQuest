import React, { useState } from 'react';
import '../styles/Styles.css';

const AvatarSlider = ({ avatars, onSelect }) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  const prevIndex = (currentIndex - 1 + avatars.length) % avatars.length;
  const nextIndex = (currentIndex + 1) % avatars.length;

  const handlePrev = () => {
    setCurrentIndex(prevIndex);
  };

  const handleNext = () => {
    setCurrentIndex(nextIndex);
  };

  const visibleAvatars = [
    { ...avatars[prevIndex], position: 'avatar-left' },
    { ...avatars[currentIndex], position: 'avatar-center' },
    { ...avatars[nextIndex], position: 'avatar-right' },
  ];

  return (
    <div className="slider-container">
      <button className="slider-nav left" onClick={handlePrev}>❮</button>

      <div className="slider-view">
        {visibleAvatars.map((avatar) => (
          <div
            key={avatar.id}
            className={`avatar-slide ${avatar.position}`}
            onClick={() => onSelect(avatar.id)}
          >
            <div className="avatar-card">
              <img src={avatar.image} alt={avatar.name} className="avatar-slider-image" />
              <button className="delete-btn" onClick={(e) => {
                e.stopPropagation();
                console.log("Delete clicked:", avatar.id);
              }}>
                Delete
              </button>
            </div>
          </div>
        ))}
      </div>

      <button className="slider-nav right" onClick={handleNext}>❯</button>
    </div>
  );
};

export default AvatarSlider;
