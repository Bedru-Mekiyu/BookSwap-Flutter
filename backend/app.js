const express = require("express")
const mongoose = require("mongoose")
const dotenv = require('dotenv');
const cors = require('cors');
const path = require('path');

const fs = require('fs');

dotenv.config();

const uploadsDir = path.join(__dirname, 'uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const authRouter = require("./routes/authRoutes");
const bookRouter = require("./routes/bookRoutes");
const tradeRouter = require("./routes/tradeRoutes");

const app = express();

app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use('/uploads', express.static(uploadsDir));

app.use('/api/auth', authRouter);
app.use('/api/books', bookRouter);
app.use('/api/trades', tradeRouter);

app.get('/', (req, res) => {
  res.send('📚 Book Swap API is running...');
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', uptime: process.uptime() });
});

// Centralized error handling
app.use((err, req, res, next) => {
  console.error('Unhandled Server Error:', err);
  res.status(err.status || 500).json({
    message: err.message || 'Internal server error',
  });
});

const PORT = process.env.PORT || 4000;
const MONGO_URI = process.env.MONGODB_URL || process.env.MONGO_URI || 'mongodb://localhost:27017/bookswap';

if (require.main === module) {
  mongoose
    .connect(MONGO_URI)
    .then(() => {
      console.log('✅ MongoDB connected');
      app.listen(PORT, () => {
        console.log(`🚀 Server listening on port ${PORT}`);
      });
    })
    .catch((err) => {
      console.error('❌ MongoDB connection failed:', err.message);
      if (err.message.includes('ENOTFOUND') && MONGO_URI.includes('cluster0.mongodb.net')) {
        console.error('💡 Tip: "cluster0.mongodb.net" is an example placeholder. In MongoDB Atlas, each cluster has a unique identifier, like "cluster0.abcde.mongodb.net". Please update your MONGO_URI environment variable on Render with your actual cluster URI.');
      }
      process.exit(1);
    });
}

module.exports = app;