import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import '../styles/Styles.css';

const NavigationBar = () => {
  const [open, setOpen] = useState(false);
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.clear();
    navigate('/');
  };

  return (
    <>
      <button onClick={() => setOpen(true)} className="nav-toggle-btn">☰</button>

      {open && (
        <div className="sidebar-overlay" onClick={() => setOpen(false)}>
          <div className="sidebar-menu" onClick={(e) => e.stopPropagation()}>
            <div className="sidebar-header">
              <h3 className="pixel-font">Admin</h3>
              <hr />
            </div>
            <nav className="sidebar-links">
              <Link to="/dashboard" onClick={() => setOpen(false)}>Dashboard</Link>
              <Link to="/All-Users" onClick={() => setOpen(false)}>All Users</Link>
              <Link to="/All-Tournaments" onClick={() => setOpen(false)}>All Tournaments</Link>
              <Link to="/All-Feedbacks" onClick={() => setOpen(false)}>All Feedbacks</Link>
            </nav>
            <div className="sidebar-logout">
              <button onClick={handleLogout}>
                Logout
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default NavigationBar;
