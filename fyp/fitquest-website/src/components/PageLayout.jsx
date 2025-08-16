import React, { useState } from 'react';
import SideBar from '../components/SideBar';
import TopBar from './TopBar';
import './PageLayout.css';
import '../styles/Styles.css';

const PageLayout = ({ children, hideSidebar = false }) => {
  const [searchTerm, setSearchTerm] = useState('');

  return (
    <div>
      <TopBar searchTerm={searchTerm} onSearch={setSearchTerm} />
      <div >
        {!hideSidebar && <SideBar />}
        <main className="admin-main">
          {children}
        </main>
      </div>
    </div>
  );
};

export default PageLayout;
