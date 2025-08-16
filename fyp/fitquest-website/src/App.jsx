import { BrowserRouter as Router, Routes, Route } from 'react-router-dom'; 
import LoginPage from './pages/LoginPage';
import ADashboard from './pages/ADashboard';
import AllUsersPage from './pages/ViewAllUsers';
import ViewAUser from './components/ViewAUser';
import ViewAllWorkoutCategories from './pages/ViewAllWorkoutCategories';
import ViewAWorkoutCategory from './pages/ViewAWorkoutCategory';
import ViewAllFeedbacks from './pages/ViewAllFeedbacks';
import ViewAllTournaments from './pages/ViewAllTournaments';
import ViewATournament from './components/ViewATournament';
import CreateTournament from './components/CreateTournament';
import Subscriptions from './pages/Subscriptions';

import PageLayout from '../src/components/PageLayout';

const App = () => {
  return (
    <Router>
      <Routes>
        <Route path="/" element={<LoginPage />} />

        {/* Admin pages wrapped in shared layout */}
        <Route path="/dashboard" element={<PageLayout> hideSidebar={true} <ADashboard /></PageLayout>} />
        <Route path="/All-Users" element={<PageLayout><AllUsersPage /></PageLayout>} />
        <Route path="/users/:id" element={<PageLayout><ViewAUser /></PageLayout>} />
        <Route path="/All-Workouts" element={<PageLayout><ViewAllWorkoutCategories /></PageLayout>} />
        <Route path="/admin/workouts/:categoryId" element={<PageLayout><ViewAWorkoutCategory /></PageLayout>} />
        <Route path="/All-Feedbacks" element={<PageLayout><ViewAllFeedbacks /></PageLayout>} />
        <Route path="/All-Tournaments" element={<PageLayout><ViewAllTournaments /></PageLayout>} />
        <Route path="/create-tournament" element={<PageLayout><CreateTournament /></PageLayout>} />
        <Route path="/View-Tournament" element={<PageLayout><ViewATournament /></PageLayout>} />
        <Route path="/Subcriptions" element={<PageLayout><Subscriptions/></PageLayout>}/>
      </Routes>
    </Router>
  );
};

export default App;
