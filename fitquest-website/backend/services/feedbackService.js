const FeedbackModel = require('../models/feedbackModel');

function timeSince(date) {
  const seconds = Math.floor((new Date() - date) / 1000);
  const intervals = [
    { label: "year", seconds: 31536000 },
    { label: "month", seconds: 2592000 },
    { label: "week", seconds: 604800 },
    { label: "day", seconds: 86400 },
    { label: "hour", seconds: 3600 },
    { label: "minute", seconds: 60 }
  ];
  for (const i of intervals) {
    const count = Math.floor(seconds / i.seconds);
    if (count > 0) return `${count} ${i.label}${count > 1 ? 's' : ''} ago`;
  }
  return "Just now";
}

class FeedbackService {
  static async getUserFeedback(userId) {
    return await FeedbackModel.findByUserId(userId);
  }  
  static async getAllFeedbacks(filter) {
    return await FeedbackModel.findAllWithUser(filter);
  }

  static async setFeedbackStatus(id, status) {
    await FeedbackModel.updateStatus(id, status);
  }

  static async getFeedbackSummary(limit) {
    // Ratings
    const [ratingRows] = await FeedbackModel.getRatingsData();
    const ratingsCount = {
      5: Number(ratingRows[0].star5) || 0,
      4: Number(ratingRows[0].star4) || 0,
      3: Number(ratingRows[0].star3) || 0,
      2: Number(ratingRows[0].star2) || 0,
      1: Number(ratingRows[0].star1) || 0
    };

    // Liked features
    const [likedRows] = await FeedbackModel.getLikedFeaturesRows();
    const likedCount = {};
    likedRows.forEach(row => {
      if (row.feature) likedCount[row.feature] = (likedCount[row.feature] || 0) + 1;
    });
    const likedFeatures = Object.entries(likedCount)
      .map(([feature, count]) => ({ feature, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 3);

    // Issues
    const [issuesRows] = await FeedbackModel.getIssuesRows();
    const issuesCount = {};
    issuesRows.forEach(row => {
      if (row.feature) issuesCount[row.feature] = (issuesCount[row.feature] || 0) + 1;
    });
    const issues = Object.entries(issuesCount)
      .map(([feature, count]) => ({ feature, count }))
      .sort((a, b) => b.count - a.count)
      .slice(0, 3);

    const [reviewRows] = await FeedbackModel.getRecentReviews(limit);
    console.log('reviews');
    console.log(reviewRows);
    const reviews = reviewRows.map(r => ({
      username: r.username,
      level: r.level || 1,
      rating: Number(r.rating),
      message: r.message,
      date: timeSince(new Date(r.created_at))
    }));
    console.log('feedback')

    return {
      averageRating: Number(ratingRows[0].averageRating) || 0,
      ratingsCount,
      likedFeatures,
      issues,
      reviews
    };
  }
}

module.exports = FeedbackService;
