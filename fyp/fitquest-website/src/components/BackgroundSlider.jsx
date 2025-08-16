import React, { useState, useEffect } from 'react';
import '../styles/Styles.css';

const dummyBackgrounds = [
  { id: 'b1', name: 'Beach', image: '/bg-beach.jpeg' },
  { id: 'b2', name: 'Bird', image: '/bg-bird.jpg' },
  { id: 'b3', name: 'Forest', image: '/bg-forest.jpg' },
  { id: 'b4', name: 'Vampire', image: '/bg-vampire.jpg' },
  { id: 'b5', name: 'Night', image: '/bg-night.png' },
  { id: 'b6', name: 'Pink', image: '/bg-pink.jpg' },
];

const BackgroundSlider = ({ selectedBackground, onSelect, onChangeIndex }) => {
  const [currentIndex, setCurrentIndex] = useState(0);

  const prevIndex = (currentIndex - 1 + dummyBackgrounds.length) % dummyBackgrounds.length;
  const nextIndex = (currentIndex + 1) % dummyBackgrounds.length;

  useEffect(() => {
    onChangeIndex(dummyBackgrounds[currentIndex]); // Notify parent of currently centered item
  }, [currentIndex, onChangeIndex]);

  const handlePrev = () => {
    setCurrentIndex(prevIndex);
  };

  const handleNext = () => {
    setCurrentIndex(nextIndex);
  };

  const visibleBackgrounds = [
    { ...dummyBackgrounds[prevIndex], position: 'avatar-left' },
    { ...dummyBackgrounds[currentIndex], position: 'avatar-center' },
    { ...dummyBackgrounds[nextIndex], position: 'avatar-right' },
  ];

  return (
    <div className="slider-container">
      <button className="slider-nav left" onClick={handlePrev}>❮</button>

      <div className="slider-view">
        {visibleBackgrounds.map((bg) => (
          <div
            key={bg.id}
            className={`avatar-slide ${bg.position}`}
            onClick={() => onSelect(bg.id)}
          >
            <div className="avatar-card">
              <img src={bg.image} alt={bg.name} className="avatar-slider-image" />
            </div>
          </div>
        ))}
      </div>

      <button className="slider-nav right" onClick={handleNext}>❯</button>
    </div>
  );
};

export default BackgroundSlider;
