import React, { useEffect, useState } from 'react';
import './ViewASubscription.css';
import '../pages/ViewAllUsers.css';
import { fetchUserSubscriptions } from '../services/subscriptionHistoryService';

const ViewASubscription = ({ user, onClose }) => {
  const [history, setHistory] = useState([]);
  const [userDetails, setUserDetails] = useState(null);

  useEffect(() => {
    if (user?.user_id) {
      fetchUserSubscriptions(user.user_id)
        .then(data => {
          setHistory(data);
          if (data.length > 0) {
            const first = data[0];
            setUserDetails({
              firstName: first.firstName || '',
              lastName: first.lastName || '',
              username: first.username || '',
              dob: first.dob ? new Date(first.dob).toLocaleDateString() : '',
              email: first.email || '',
              role: first.role || '',
            });
          }
        })
        .catch(() => {
          setHistory([]);
          setUserDetails(null);
        });
    }
  }, [user]);

  if (!user) return null;

  return (
    <div className="modal-overlay">
      <div className="subscription-modal">
        <h3 className="modal-username">{userDetails?.username || user.username}</h3>
        <p className="modal-subtitle">Premium<br /><span className="modal-level">{userDetails?.email || user.email}</span></p>

        <div className="modal-section">
          <h4>Personal Details</h4> <hr />
          <div className="field-grid">
            <div className="field-label">First Name</div>
            <div className="field-value">{userDetails?.firstName || '-'}</div>

            <div className="field-label">Last Name</div>
            <div className="field-value">{userDetails?.lastName || '-'}</div>

            <div className="field-label">Username</div>
            <div className="field-value">@{userDetails?.username || '-'}</div>

            <div className="field-label">Date of Birth</div>
            <div className="field-value">{userDetails?.dob || '-'}</div>

            <div className="field-label">Email</div>
            <div className="field-value">{userDetails?.email || '-'}</div>
          </div>
        </div>

        <div className="modal-section">
          <h4>Account Details</h4> <hr />
          <div className="field-grid">
            <div className="field-label">Account</div>
            <div className="field-value">{userDetails?.role || 'Premium'}</div>
            <div className="field-label">Plan</div>
            <div className="field-value">{user.plan}</div>
            <div className="field-label">Start</div>
            <div className="field-value">{user.joined}</div>
            <div className="field-label">End</div>
            <div className="field-value">{user.expiry}</div>
            <div className="field-label">Last Payment</div>
            <div className="field-value">{user.price}</div>
          </div>
        </div>

        <div className="modal-section">
          <h4>Transaction History</h4>
          <hr />
          {history.length > 0 ? (
            history.map((h, i) => (
              <div key={i} className="transaction-row">
                <span>{new Date(h.created_at).toLocaleString()}</span>
                <span className="paid-tag">{h.method === 'money' ? 'Paid' : 'Tokens'}</span>
                <span className="card-text">
                  {h.method === 'money'
                    ? `$${Number(h.amount || 0).toFixed(2)}`
                    : `${h.tokens_used || 0} Tokens`}
                </span>
              </div>
            ))
          ) : (
            <div className="transaction-row">No records</div>
          )}
        </div>

        <button className="ok-button" onClick={onClose}>OK</button>
      </div>
    </div>
  );
};

export default ViewASubscription;
