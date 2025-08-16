import { useEffect, useState } from "react";
import Login from "../components/Login";
import blackFitQuestLogo from "../assets/BlackLogo.png";
import backgroundImage from "../assets/LoginBackground.png";
import "../styles/Styles.css";
import { checkSession } from "../services/authService";

const LoginPage = () => {
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const verifySession = async () => {
      try {
        const { loggedIn } = await checkSession();
        if (loggedIn) {
          window.location.href = "/dashboard";
          return;
        }
      } finally {
        setTimeout(() => setLoading(false), 1000);
      }
    };
    verifySession();
  }, []);

  const handleLoginSuccess = (email) => {
    localStorage.setItem("mail:", email);
    window.location.href = "/dashboard";
  };

  if (loading) {
    return (
      <div className="fitquest-loading-page">
        <div className="spinner"></div>
        <h2 className="pixel-font">Checking session...</h2>
      </div>
    );
  }

  return (
    <div className="fitquest-login-page">
      <div className="fitquest-left-panel">
        <h1 className="pixel-font">
          From Goals to Glory,<br />One Quest at a Time.
        </h1>
      </div>

      <div className="fitquest-right-panel">
        <div className="fitquest-login-card">
          <img
            src={blackFitQuestLogo}
            alt="FitQuest Logo"
            className="fitquest-logo"
          />
          <h2>Log In</h2>
          <Login onLoginSuccess={handleLoginSuccess} />
        </div>
      </div>

      <img
        src={backgroundImage}
        alt="LogIn Page"
        className="fitquest-login-page-background"
      />
    </div>
  );
};

export default LoginPage;
