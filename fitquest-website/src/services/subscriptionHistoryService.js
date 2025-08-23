export async function fetchAllSubscriptions(plan = 'All', search = '') {
    const query = new URLSearchParams();
    if (plan && plan !== 'All') query.append('plan', plan);
    if (search) query.append('search', search);
  
    const res = await fetch(`https://fyp-25-s2-08-admin.onrender.com/admin/subscriptions?${query.toString()}`, {
      credentials: 'include'
    });
    if (!res.ok) throw new Error('Failed to fetch subscriptions');
    return res.json();
  }
  
  export async function fetchUserSubscriptions(userId) {
    const res = await fetch(`https://fyp-25-s2-08-admin.onrender.com/admin/subscriptions/${userId}`, {
      credentials: 'include'
    });
    if (!res.ok) throw new Error('Failed to fetch user subscriptions');
    return res.json();
  }
  