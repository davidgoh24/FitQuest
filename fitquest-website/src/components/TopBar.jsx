// components/TopBar.jsx
import React, {useState} from 'react';
import '../styles/Styles.css';
import './TopBar.css';

const TopBar = ({ searchTerm, onSearch }) => {

    const [SearchTerm, setSearchTerm] = useState('');
    
  return (
    <div className="top-bar">
      <img src="white-logo.png" alt="FitQuest Logo" className="topbar-logo" />
    </div>
  );
};

export default TopBar;
