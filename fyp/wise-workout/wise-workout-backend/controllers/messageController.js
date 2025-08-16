const MessageService = require('../services/messageService');

exports.sendMessage = async (req, res) => {
  const senderId = req.user.id;
  const { receiverId, content } = req.body;

  if (!receiverId || !content) {
    return res.status(400).json({ message: 'Receiver and content required' });
  }

  await MessageService.sendMessage(senderId, receiverId, content);
  res.json({ message: 'Message sent' });
};

exports.getConversation = async (req, res) => {
  const userId1 = req.user.id;
  const userId2 = req.params.userId;

  const conversation = await MessageService.getConversation(userId1, userId2);
  res.json({
    myUserId: userId1,
    messages: conversation
  });
};
exports.markAsRead = async (req, res) => {
  const userId = req.user.id;
  const { friendId } = req.body;
  if (!friendId) return res.status(400).json({ message: 'Missing friendId' });
  await MessageService.markAsRead(friendId, userId); 
  res.json({ message: 'Messages marked as read' });
};

exports.getUnreadCounts = async (req, res) => {
  const userId = req.user.id;
  const counts = await MessageService.getUnreadCounts(userId);
  res.json(counts);
};

