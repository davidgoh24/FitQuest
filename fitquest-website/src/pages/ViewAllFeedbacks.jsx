import React, { useState, useEffect } from 'react';
import './ViewAllFeedbacks.css';
import PageLayout from '../components/PageLayout';
import { fetchFeedbacks, updateFeedbackStatus } from '../services/feedbackService';

const tabList = ['All', 'Pending', 'Accepted', 'Rejected'];

const renderStars = (rating) => {
  return [...Array(5)].map((_, i) => {
    const diff = (rating || 0) - i;
    let cls = 'empty';
    if (diff >= 1) cls = '';
    else if (diff >= 0.5) cls = 'half';
    const char = cls === 'half' ? '⯨' : '★';
    return <span key={i} className={`star ${cls}`}>{char}</span>;
  });
};

const ViewAllFeedbacks = () => {
  const [feedbacks, setFeedbacks] = useState([]);
  const [loading, setLoading] = useState(true);
  const [selectedTab, setSelectedTab] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const [showConfirm, setShowConfirm] = useState(null);
  const [modalFeedback, setModalFeedback] = useState(null);

  useEffect(() => {
    setLoading(true);
    fetchFeedbacks({ status: selectedTab, search: searchTerm })
      .then(setFeedbacks)
      .finally(() => setLoading(false));
  }, [selectedTab, searchTerm]);

  const statusCounts = tabList.reduce((acc, tab) => {
    if (tab === 'All') acc[tab] = feedbacks.length;
    else acc[tab] = feedbacks.filter(fb => fb.status && fb.status.toLowerCase() === tab.toLowerCase()).length;
    return acc;
  }, {});

  const handleStatusChange = async (id, action) => {
    setLoading(true);
    await updateFeedbackStatus({ id, status: action === 'publish' ? 'accepted' : 'rejected' });
    setShowConfirm(null);
    const updated = await fetchFeedbacks({ status: selectedTab, search: searchTerm });
    setFeedbacks(updated);
    setLoading(false);
  };

  return (
    <PageLayout>
      <div className="all-users-container">
        <div className="user-content">
          <div className="user-header">
            <h2>All Feedbacks</h2>
            <div className="header-row">
              <div className="user-tabs-container">
                {tabList.map((tab) => (
                  <div
                    key={tab}
                    className={`user-tab ${selectedTab === tab ? 'active' : ''}`}
                    onClick={() => setSelectedTab(tab)}
                  >
                    {tab} <span className="tab-count">({statusCounts[tab] || 0})</span>
                  </div>
                ))}
              </div>
              <div className="search-bar-container">
                <input
                  type="text"
                  placeholder="Search feedback by email or words ..."
                  className="search-bar"
                  value={searchTerm}
                  onChange={e => setSearchTerm(e.target.value)}
                />
                <button className="search-icon-btn">
                  <img src="/icon-search.png" alt="Search" />
                </button>
              </div>
            </div>
          </div>
          <table className="users-table">
            <thead>
              <tr>
                <th>Username</th>
                <th>Email</th>
                <th>Submitted Date</th>
                <th>Status</th>
                <th>Manage</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr><td colSpan={5}>Loading...</td></tr>
              ) : feedbacks.length === 0 ? (
                <tr><td colSpan={5}>No feedback found.</td></tr>
              ) : (
                feedbacks.map((fb) => (
                  <tr key={fb.id} onClick={() => setModalFeedback(fb)}>
                    <td>
                      <div className="feedback-user-cell">
                        <span>{fb.username}</span>
                        <div className="star-rating">{renderStars(fb.rating)}</div>
                      </div>
                    </td>
                    <td>{fb.email}</td>
                    <td>{new Date(fb.created_at).toLocaleDateString('en-GB', {
                      day: '2-digit', month: 'short', year: 'numeric'
                    })}</td>
                    <td>
                      <span className={`status-badge ${
                        fb.status === 'accepted' ? 'active' :
                        fb.status === 'rejected' ? 'suspended' : 'pending'}`}>
                        {fb.status ? fb.status.charAt(0).toUpperCase() + fb.status.slice(1) : ''}
                      </span>
                    </td>
                    <td>
                      {fb.status === 'pending' ? (
                        <>
                          <button className="suspend-btn" onClick={e => { e.stopPropagation(); setShowConfirm({ id: fb.id, action: 'reject' }); }}>Reject</button>
                          <button className="confirm-btn" onClick={e => { e.stopPropagation(); setShowConfirm({ id: fb.id, action: 'publish' }); }}>Publish</button>
                        </>
                      ) : (
                        <button className="view-btn" onClick={e => { e.stopPropagation(); setModalFeedback(fb); }}>View</button>
                      )}
                    </td>
                  </tr>
                ))
              )}
            </tbody>
          </table>

          {showConfirm && (
            <div className="modal-overlay" onClick={() => setShowConfirm(null)}>
              <div className="confirm-modal" onClick={e => e.stopPropagation()}>
                <p>Are you sure you want to {showConfirm.action === 'publish' ? 'publish' : 'reject'}?</p>
                <div className="modal-buttons">
                  <button className="cancel-btn" onClick={() => setShowConfirm(null)}>Cancel</button>
                  <button
                    className={showConfirm.action === 'publish' ? 'confirm-btn' : 'suspend-btn'}
                    onClick={() => handleStatusChange(showConfirm.id, showConfirm.action)}
                  >
                    Confirm
                  </button>
                </div>
              </div>
            </div>
          )}

          {modalFeedback && (
            <div className="modal-overlay" onClick={() => setModalFeedback(null)}>
              <div className="feedback-detail-modal" onClick={e => e.stopPropagation()}>
                <button className="modal-close" onClick={() => setModalFeedback(null)}>✕</button>
                <div className="feedback-header">
                  <img src={modalFeedback.avatar || '/icon-avatar1.png'} alt="Avatar" className="feedback-avatar" />
                  <div className="feedback-user-info">
                    <h3>@{modalFeedback.username}</h3>
                    <p className="account-type">{modalFeedback.role}</p>
                  </div>
                  <div className="feedback-status-date">
                    <p className={`feedback-status ${modalFeedback.status}`}>{modalFeedback.status}</p>
                    <p className="submitted-date">
                      {new Date(modalFeedback.created_at).toLocaleDateString('en-GB', {
                        day: '2-digit', month: 'long', year: 'numeric'
                      })}
                    </p>
                  </div>
                </div>
                <div className="feedback-rating-row">
                  <span className="rating-value">{modalFeedback.rating?.toFixed(1)}</span>
                  <div className="star-rating">{renderStars(modalFeedback.rating)}</div>
                </div>
                <p className="feedback-message">{modalFeedback.message}</p>
                <div className="modal-back-btn-container">
                  <button className="modal-back-btn" onClick={() => setModalFeedback(null)}>Back</button>
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </PageLayout>
  );
};

export default ViewAllFeedbacks;
