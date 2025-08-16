import React, { useState, useEffect, useRef } from 'react';
import './Subscriptions.css';
import { PieChart, Pie, Cell } from 'recharts';
import PageLayout from '../components/PageLayout';
import ViewASubscription from '../components/ViewASubscription';
import { fetchAllSubscriptions } from '../services/subscriptionHistoryService';

const basePlans = [
  { name: 'Monthly Plan', key: 'monthly', color: '#D2B3DB', price: 2.99, border: '#c09ee3', tooltipX: 240, tooltipY: 5, tokens: 4000 },
  { name: 'Yearly Plan', key: 'yearly', color: '#ffcb05', price: 19.99, border: '#d6bb60', tooltipX: -20, tooltipY: 5, tokens: 19000 },
  { name: 'Lifetime Plan', key: 'lifetime', color: '#00113d', price: 49.0, border: '#333', tooltipX: 200, tooltipY: 180, tokens: 99000 }
];

const Subscriptions = () => {
  const [hoveredPlan, setHoveredPlan] = useState(null);
  const [selectedPlan, setSelectedPlan] = useState(null);
  const [premiumUsers, setPremiumUsers] = useState([]);
  const [selectedTab, setSelectedTab] = useState('All');
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const chartRef = useRef(null);

  useEffect(() => {
    const planFilter = selectedTab === 'All' ? 'All' : selectedTab;
    fetchAllSubscriptions(planFilter, searchTerm)
      .then(rows => {
        const mapped = rows.map(r => ({
          user_id: r.user_id,
          username: r.username,
          email: r.email,
          plan: r.plan ? r.plan.charAt(0).toUpperCase() + r.plan.slice(1) : '',
          joined: new Date(r.start_date).toLocaleString(),
          expiry: new Date(r.end_date).toLocaleString(),
          price: r.method === 'money' ? `$${Number(r.amount || 0).toFixed(2)}` : `${r.tokens_used || 0} Tokens`
        }));
        setPremiumUsers(mapped);
      })
      .catch(() => setPremiumUsers([]));
  }, [selectedTab, searchTerm]);

  useEffect(() => {
    const handleClickOutside = (event) => {
      if (chartRef.current && !chartRef.current.contains(event.target)) {
        setHoveredPlan(null);
        setSelectedPlan(null);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const filteredUsers = premiumUsers.filter((user) => {
    const planMatch = selectedTab === 'All' || (user.plan && user.plan.toLowerCase() === selectedTab.toLowerCase());
    const s = searchTerm.toLowerCase();
    const searchMatch = user.username?.toLowerCase().includes(s) || user.email?.toLowerCase().includes(s);
    return planMatch && searchMatch;
  });

  const planTabCounts = {
    All: premiumUsers.length,
    Lifetime: premiumUsers.filter((u) => u.plan?.toLowerCase() === 'lifetime').length,
    Yearly: premiumUsers.filter((u) => u.plan?.toLowerCase() === 'yearly').length,
    Monthly: premiumUsers.filter((u) => u.plan?.toLowerCase() === 'monthly').length,
    Trial: premiumUsers.filter((u) => u.plan?.toLowerCase() === 'trial').length,
  };

  const dynamicPlanData = basePlans.map(plan => ({
    ...plan,
    value: premiumUsers.filter(u => u.plan?.toLowerCase() === plan.key).length
  }));

  const activeTooltip = dynamicPlanData.find(p => p.name === hoveredPlan);

  return (
    <PageLayout>
      <div className="user-content" style={{ position: 'relative' }}>
        <h1 className="header-title">Subscriptions</h1>
        <div className="top-section">
          <div className="chart-container wide-chart center-chart" ref={chartRef}>
            <PieChart width={190} height={190}>
              <Pie
                data={dynamicPlanData}
                cx={90}
                cy={90}
                innerRadius={60}
                outerRadius={90}
                dataKey="value"
                onClick={(e) => {
                  setSelectedPlan(e.name);
                }}
                isAnimationActive={false}
              >
                {dynamicPlanData.map((entry, index) => (
                  <Cell
                    key={`cell-${index}`}
                    fill={entry.color}
                    stroke={entry.border}
                    strokeWidth={0.8}
                    cursor="pointer"
                    onMouseEnter={() => setHoveredPlan(entry.name)}
                  />
                ))}
              </Pie>
            </PieChart>
            {hoveredPlan && activeTooltip && (
              <div
                className="custom-tooltip"
                style={{
                  top: `${activeTooltip.tooltipY}px`,
                  left: `${activeTooltip.tooltipX}px`,
                }}
              >
                <p><strong>{activeTooltip.name}</strong></p>
                <p>{activeTooltip.tokens} Tokens</p>
                <p>${activeTooltip.price}</p>
              </div>
            )}
          </div>

          <div className="plans-widget full-height">
            {dynamicPlanData.map((plan) => (
              <div
                key={plan.name}
                className={`plan-card equal-height ${selectedPlan === plan.name ? 'highlight-' + plan.name.replace(' ', '-').toLowerCase() : ''}`}
                onClick={() => setSelectedPlan(plan.name)}
                onMouseEnter={() => setHoveredPlan(plan.name)}
              >
                <div className="plan-card-row">
                  <div className="plan-card-left">
                    <p className="plan-name">{plan.name}</p>
                    <p className="plan-info">{plan.tokens} Tokens</p>
                  </div>
                  <p className="plan-price">
                    ${plan.price}{plan.name === 'Monthly Plan' ? '/month' : plan.name === 'Yearly Plan' ? '/year' : '/forever'}
                  </p>
                </div>
              </div>
            ))}
          </div>

          <div className="benefits-box full-height">
            <h4>Premium Benefits</h4>
            <ul>
              <li>100% Ads-free experience</li>
              <li>Exclusive avatar experience</li>
              <li>Auto-suggested plan with AI</li>
              <li>Step-by-step HD video tutorial</li>
              <li>Priority support and faster updates</li>
            </ul>
          </div>
        </div>

        <div className="premium-users-section">
          <div className="user-header">
            <h2>Premium Users</h2>
            <div className="header-row">
              <div className="user-tabs-container">
                {['All', 'Lifetime', 'Yearly', 'Monthly', 'Trial'].map((tab) => (
                  <div
                    key={tab}
                    className={`user-tab ${selectedTab === tab ? 'active' : ''}`}
                    onClick={() => setSelectedTab(tab)}
                  >
                    {tab} <span className='tab-count'> ({planTabCounts[tab]}) </span>
                  </div>
                ))}
              </div>
              <div className="search-bar-container">
                <input
                  type="text"
                  placeholder="Search users by name or email..."
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

          <table className="users-table">
            <thead>
              <tr>
                <th>No.</th>
                <th>Username</th>
                <th>Email</th>
                <th>Type</th>
                <th>Start Date</th>
                <th>End Date</th>
                <th>Price</th>
              </tr>
            </thead>
            <tbody>
              {filteredUsers.map((user, index) => (
                <tr key={index} onClick={() => setSelectedUser(user)} style={{ cursor:'pointer'}}>
                  <td>{index + 1}</td>
                  <td>{user.username}</td>
                  <td>{user.email}</td>
                  <td>{user.plan}</td>
                  <td>{user.joined}</td>
                  <td>{user.expiry}</td>
                  <td>{user.price}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </div>

      {selectedUser && (
        <ViewASubscription user={selectedUser} onClose={() => setSelectedUser(null)} />
      )}
    </PageLayout>
  );
};

export default Subscriptions;
