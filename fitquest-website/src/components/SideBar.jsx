import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import './SideBar.css';
import '../pages/ViewAllUsers.css';

const SideBar = () => {
  const [open, setOpen] = useState(true); // Sidebar always visible
  const [showLogoutConfirm, setShowLogoutConfirm] = useState(false);
  const navigate = useNavigate();

  const handleLogoutClick = () => {
    setShowLogoutConfirm(true);
  };

  const handleLogout = () => {
    localStorage.clear();
    navigate('/');
  };

  return (
    <>
      <div className='sidebar-container'>
        <nav className="sidebar-nav">
          <Link to="/dashboard">Dashboard</Link>
          <Link to="/All-Users">All Users</Link>
          <Link to="/All-Tournaments">All Tournaments</Link>
          <Link to="/All-Feedbacks">All Feedbacks</Link>
          <Link to="/Subcriptions">Subcriptions</Link>

          <div className="sidebar-logout">
            <button className="sidebar-nav-link" onClick={handleLogoutClick}>
              <img src="/icon-logout.png" alt="Logout Icon" className="logout-icon" />
              Logout
            </button>
          </div>

        </nav>
      </div>

     {showLogoutConfirm && (
        <div className="modal-overlay" onClick={() => setShowLogoutConfirm(false)}>
          <div className="logout-confirm-modal" onClick={(e) => e.stopPropagation()}>
            <p>Are you sure you want to logout?</p>
            <div className="button-row">
              <button className="cancel-btn" onClick={() => setShowLogoutConfirm(false)}>
                Cancel
              </button>
              <button className="suspend-btn" onClick={handleLogout}> {/* This matches the Cancel button styling */}
                Logout
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default SideBar;
