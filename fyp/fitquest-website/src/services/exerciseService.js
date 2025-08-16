export async function fetchAllExercises() {
    const res = await fetch('https://fyp-25-s2-08-admin.onrender.com/admin/exercises', {
      credentials: 'include'
    });
    if (!res.ok) throw new Error('Failed to fetch exercises');
    return res.json();
  }
  