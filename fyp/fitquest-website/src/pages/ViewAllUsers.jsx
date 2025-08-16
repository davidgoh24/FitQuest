import React, { useState, useEffect } from 'react';
import Swal from 'sweetalert2';

import '../styles/Styles.css';
import './ViewAllUsers.css';

import PageLayout from '../components/PageLayout.jsx';
import ViewAUser from '../components/ViewAUser.jsx';
import { fetchAllUsers, suspendUser, unsuspendUser } from '../services/userService';

const ViewAllUsers = () => {
  const [selectedTab, setSelectedTab] = useState('All');
  const [selectedUser, setSelectedUser] = useState(null);
  const [searchTerm, setSearchTerm] = useState('');
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [fetchError, setFetchError] = useState('');

  useEffect(() => {
    setLoading(true);
    setFetchError('');
    fetchAllUsers()
      .then(data => {
        setUsers(data);
        setLoading(false);
      })
      .catch(() => {
        setUsers([]);
        setLoading(false);
        setFetchError('Could not fetch users');
      });
  }, []);

  const filteredUsers = users.filter((user) => {
    if (selectedTab === 'Suspended' && !user.isSuspended) return false;
    if (selectedTab === 'Active' && user.isSuspended) return false;

    const username = user.username || '';
    const email = user.email || '';
    return (
      username.toLowerCase().includes(searchTerm.toLowerCase()) ||
      email.toLowerCase().includes(searchTerm.toLowerCase())
    );
  });

  const userTabCounts = {
    All: users.length,
    Active: users.filter(u => !u.isSuspended).length,
    Suspended: users.filter(u => u.isSuspended).length,
  };

  const handleSuspendToggle = async (user) => {
    const isCurrentlySuspended = user.isSuspended;
    const result = await Swal.fire({
      title: isCurrentlySuspended ? 'Unsuspend this user?' : 'Suspend this user?',
      text: isCurrentlySuspended
        ? 'This will reactivate their account.'
        : 'This will restrict their account access.',
      icon: 'warning',
      showCancelButton: true,
      confirmButtonText: isCurrentlySuspended ? 'Unsuspend' : 'Suspend',
      cancelButtonText: 'Cancel',
      buttonsStyling: false,
      customClass: {
        confirmButton: isCurrentlySuspended ? 'unsuspend-btn' : 'suspend-btn',
        cancelButton: 'cancel-btn',
      }
    });

    if (result.isConfirmed) {
      try {
        if (isCurrentlySuspended) {
          await unsuspendUser(user.id);
        } else {
          await suspendUser(user.id);
        }

        // Update users list
        setUsers((prevUsers) =>
          prevUsers.map((u) =>
            u.id === user.id ? { ...u, isSuspended: !u.isSuspended } : u
          )
        );

        // Update modal user if open
        setSelectedUser((prev) =>
          prev && prev.id === user.id
            ? { ...prev, isSuspended: !prev.isSuspended }
            : prev
        );

        Swal.fire({
          title: 'Success',
          text: `User has been ${isCurrentlySuspended ? 'unsuspended' : 'suspended'}.`,
          icon: 'success',
          confirmButtonText: 'OK',
          buttonsStyling: false,
          customClass: {
            confirmButton: 'confirm-btn',
          },
        });
      } catch {
        Swal.fire({
          title: 'Error',
          text: 'Action failed. Please try again.',
          icon: 'error',
          confirmButtonText: 'OK',
          buttonsStyling: false,
          customClass: {
            confirmButton: 'confirm-btn',
          },
        });
      }
    }
  };

  return (
    <PageLayout>
      <div className="admin-container">
        <div className="user-content">
          <div className="user-header">
            <h2>All Users</h2>
            <div className="header-row">
              <div className="user-tabs-container">
                {['All', 'Active', 'Suspended'].map((tab) => (
                  <div
                    key={tab}
                    className={`user-tab ${selectedTab === tab ? 'active' : ''}`}
                    onClick={() => setSelectedTab(tab)}
                  >
                    {tab} <span className='tab-count'> ({userTabCounts[tab]}) </span>
                  </div>
                ))}
              </div>
              <div className="search-bar-container">
                <input
                  type="text"
                  placeholder="Search feedback by email or words ..."
                  className="search-bar"
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
                <button className="search-icon-btn">
                  <img src="/icon-search.png" alt="Search" />
                </button>
              </div>
            </div>
          </div>
          {loading ? (
            <div className="loading-text">Loading users...</div>
          ) : fetchError ? (
            <div className="error-text">{fetchError}</div>
          ) : (
            <table className="users-table">
              <thead>
                <tr>
                  <th>Username</th>
                  <th>Email</th>
                  <th>Role</th>
                  <th>Level</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody>
                {filteredUsers.length === 0 ? (
                  <tr>
                    <td colSpan="6" className="empty-message">
                      {selectedTab === 'Suspended'
                        ? 'No user is suspended.'
                        : selectedTab === 'Active'
                        ? 'No user is active.'
                        : 'No users found.'}
                    </td>
                  </tr>
                ) : (
                  filteredUsers.map((user) => (
                    <tr key={user.id} onClick={() => setSelectedUser(user)} style={{ cursor: 'pointer' }}>
                      <td>{user.username}</td>
                      <td>{user.email}</td>
                      <td>{user.role}</td>
                      <td>{user.level}</td>
                      <td>
                        <span className={`status-badge ${user.isSuspended ? 'suspended' : 'active'}`}>
                          {user.isSuspended ? 'Suspended' : 'Active'}
                        </span>
                      </td>
                      <td>
                        <button
                          className={`suspend-btn ${user.isSuspended ? 'unsuspend' : 'suspend'}`}
                          onClick={(e) => {
                            e.stopPropagation();
                            handleSuspendToggle(user);
                          }}
                        >
                          {user.isSuspended ? 'Unsuspend' : 'Suspend'}
                        </button>
                        <button
                          className="view-btn"
                          onClick={(e) => {
                            e.stopPropagation();
                            setSelectedUser(user);
                          }}
                        >
                          View
                        </button>
                      </td>
                    </tr>
                  ))
                )}
              </tbody>
            </table>
          )}
          {selectedUser && (
            <div className="user-modal-overlay" onClick={() => setSelectedUser(null)}>
              <ViewAUser
                user={selectedUser}
                onClose={() => setSelectedUser(null)}
                handleSuspendToggle={handleSuspendToggle}
              />
            </div>
          )}
        </div>
      </div>
    </PageLayout>
  );
};

export default ViewAllUsers;
