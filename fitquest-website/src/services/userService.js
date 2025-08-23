export async function fetchDashboardStats() {
  const res = await fetch('https://fyp-25-s2-08-admin.onrender.com/admin/stats', {
    credentials: 'include'
  });
  if (!res.ok) throw new Error('Failed to fetch stats');
  return res.json();
}

export async function fetchAllUsers() {
  const res = await fetch('https://fyp-25-s2-08-admin.onrender.com/admin/users', {
    credentials: 'include'
  });
  if (!res.ok) throw new Error('Failed to fetch users');
  return res.json();
}

export async function suspendUser(userId) {
  const res = await fetch(`https://fyp-25-s2-08-admin.onrender.com/admin/users/${userId}/suspend`, {
    method: 'POST',
    credentials: 'include'
  });
  if (!res.ok) throw new Error('Failed to suspend user');
}

export async function unsuspendUser(userId) {
  const res = await fetch(`https://fyp-25-s2-08-admin.onrender.com/admin/users/${userId}/unsuspend`, {
    method: 'POST',
    credentials: 'include'
  });
  if (!res.ok) throw new Error('Failed to unsuspend user');
}
