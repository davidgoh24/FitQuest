import React, { useEffect, useRef, useState } from 'react';
import { Routes, Route, useNavigate } from 'react-router-dom';
import './ADashboard.css';

import PageLayout from '../components/PageLayout.jsx';
import { fetchDashboardStats } from '../services/userService';
import { fetchFeedbackSummary } from '../services/feedbackService';

import AllUsersPage from './ViewAllUsers';
import AllTournamentsPage from './ViewAllTournaments';
import AllFeedbacksPage from './ViewAllFeedbacks';

const ADashboard = () => {
  const manageSectionRef = useRef(null);
  const [isVisible, setIsVisible] = useState(false);
  const navigate = useNavigate();

  const [stats, setStats] = useState({ total: 0, active: 0, premium: 0 });
  const [loading, setLoading] = useState(true);

  const [feedback, setFeedback] = useState({
    averageRating: 0,
    ratingsCount: {},
    likedFeatures: [],
    issues: [],
    reviews: []
  });
  const [feedbackLoading, setFeedbackLoading] = useState(true);

  useEffect(() => {
    const observer = new IntersectionObserver(([entry]) => {
      if (entry.isIntersecting) setIsVisible(true);
    }, { threshold: 0.1 });

    if (manageSectionRef.current) {
      observer.observe(manageSectionRef.current);
    }

    return () => {
      if (manageSectionRef.current) {
        observer.unobserve(manageSectionRef.current);
      }
    };
  }, []);

  useEffect(() => {
    fetchDashboardStats()
      .then(data => setStats(data))
      .catch(() => setStats({ total: '-', active: '-', premium: '-' }))
      .finally(() => setLoading(false));

    fetchFeedbackSummary()
      .then(data => setFeedback(data))
      .catch(() => setFeedback({ averageRating: 0, ratingsCount: {}, likedFeatures: [], issues: [], reviews: [] }))
      .finally(() => setFeedbackLoading(false));
  }, []);

  const renderStars = (rating) => {
    return [...Array(5)].map((_, i) => {
      const diff = rating - i;
      let starChar = '☆';
      if (diff >= 1) starChar = '★';
      else if (diff >= 0.5) starChar = '⯨';
      return (
        <span
          key={i}
          style={{
            color: starChar === '☆' ? '#ccc' : '#ffc107',
            fontSize: '1.2rem',
            marginRight: '2px',
          }}
        >
          {starChar}
        </span>
      );
    });
  };

  return (
    <PageLayout>
      <section className="hero-section">
        <div className="hero-left-column">
          <h1 className="pixel-font">From Goals to Glory,</h1>
          <h2 className="pixel-font">One Quest at a Time.</h2>
          <div className="search-bar-container">
            <input className="search-bar" type="text" placeholder="Search everything on FitQuest" />
            <button className="search-icon-btn">
              <img src="/icon-search.png" alt="Search" />
            </button>
          </div>
          <img src="/icon-trophy.png" alt="Trophy" className="hero-trophy" />
        </div>

        <div className="hero-feature-column">
          <div className="hero-feature-card" onClick={() => navigate("/All-Users")}>
            <img src="/icon-totalUsers.png" alt="All Users" />
            <span>All Users</span>
          </div>
          <div className="hero-feature-card" onClick={() => navigate("/All-Tournaments")}>
            <img src="/icon-tournament.png" alt="All Tournaments" />
            <span>All Tournaments</span>
          </div>
          <div className="hero-feature-card" onClick={() => navigate("/All-Feedbacks")}>
            <img src="/icon-feedback.png" alt="All Feedbacks" />
            <span>All Feedbacks</span>
          </div>
        </div>
      </section>

      <div className="dashboard-content">
        <div className="stat-section-wrapper">
          <h2 className="stat-section-title">Your Step, Your Journey</h2>
          <section className="stat-overview-section">
            <div className="mini-stat-card">
              <img src="/icon-totalUsers.png" alt="Users" />
              <div>
                <h3>{loading ? '...' : stats.total}</h3>
                <p>Total Users</p>
              </div>
            </div>
            <div className="mini-stat-card">
              <img src="/icon-activeUsers.png" alt="Active Users" />
              <div>
                <h3>{loading ? '...' : stats.active}</h3>
                <p>Active Users</p>
              </div>
            </div>
            <div className="mini-stat-card">
              <img src="/icon-premium.png" alt="Premium Users" />
              <div>
                <h3>{loading ? '...' : stats.premium}</h3>
                <p>Premium Users</p>
              </div>
            </div>
          </section>
        </div>
      </div>

      {/* Customer Feedback Section */}
      <div className="customer-feedback-section">
        <h2 className="feedback-title">Customers Feedback</h2>
        <div className="feedback-wrapper">
          {/* Left Score Box */}
          <div className="feedback-score-box">
            <div className="average-score">
              {feedbackLoading ? '...' : feedback.averageRating.toFixed(2)}
            </div>
            <div className="rating-bars">
              {[5, 4, 3, 2, 1].map((star) => (
                <div className="rating-bar-row" key={star}>
                  <div className="star-label">{star} Stars</div>
                  <div className="bar-container">
                    <div
                      className="bar-fill"
                      style={{
                        width: feedbackLoading
                          ? '0%'
                          : `${(feedback.ratingsCount[star] || 0) /
                              Math.max(...Object.values(feedback.ratingsCount || {1:1})) * 100}%`
                      }}
                    ></div>
                  </div>
                  <div className="bar-value">
                    {feedbackLoading ? '...' : (feedback.ratingsCount[star] || 0)}
                  </div>
                </div>
              ))}
            </div>

            <div className="feedback-tags">
              <p><strong>What Customers Like</strong></p>
              {feedbackLoading
                ? <p>Loading...</p>
                : feedback.likedFeatures.map(f => (
                    <button key={f.feature} className="feedback-tag">{f.feature.trim()}</button>
                  ))}
              <p style={{ marginTop: '1rem' }}><strong>FitQuest in Development</strong></p>
              {feedbackLoading
                ? <p>Loading...</p>
                : feedback.issues.map(i => (
                    <button key={i.feature} className="feedback-tag warning">{i.feature.trim()}</button>
                  ))}
            </div>
          </div>

          {/* Right Recent Reviews */}
          <div className="feedback-reviews-box">
            <div className="reviews-header">
              <h3>Recent Reviews</h3>
              <button className="view-all-btn" onClick={() => navigate("/All-Feedbacks")}>
                View All Feedbacks
              </button>
            </div>
            <div className="review-scroll-container">
              {feedbackLoading
                ? <p>Loading reviews...</p>
                : feedback.reviews.map((rev, idx) => (
                    <div className="review-entry" key={idx}>
                      <p>
                        <strong>{rev.username} (Lvl. {rev.level})</strong><br />
                        {renderStars(rev.rating)}
                      </p>
                      <p>{rev.message}</p>
                      <span className="review-date">{rev.date}</span>
                    </div>
                  ))}
            </div>
          </div>
        </div>
      </div>
    </PageLayout>
  );
};

export default function AdminRoutes() {
  return (
    <Routes>
      <Route path="/" element={<ADashboard />} />
      <Route path="/All-Users" element={<AllUsersPage />} />
      <Route path="/All-Tournaments" element={<AllTournamentsPage />} />
      <Route path="/All-Feedbacks" element={<AllFeedbacksPage />} />
    </Routes>
  );
}
