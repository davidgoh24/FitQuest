export async function fetchAllTournaments() {
    const res = await fetch('https://fyp-25-s2-08-admin.onrender.com/admin/tournaments', {
      credentials: 'include'
    });
    if (!res.ok) throw new Error('Failed to fetch tournaments');
    return res.json();
  }
  
  export async function createTournament(tournamentData) {
    const res = await fetch('https://fyp-25-s2-08-admin.onrender.com/admin/tournaments', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify(tournamentData)
    });
    if (!res.ok) throw new Error('Failed to create tournament');
    return res.json();
  }
  
  export async function updateTournament(id, tournamentData) {
    const res = await fetch(`https://fyp-25-s2-08-admin.onrender.com/admin/tournaments/${id}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      credentials: 'include',
      body: JSON.stringify(tournamentData)
    });
    if (!res.ok) throw new Error('Failed to update tournament');
    return res.json();
  }
  