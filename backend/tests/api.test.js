const request = require('supertest');
const mongoose = require('mongoose');
const { MongoMemoryServer } = require('mongodb-memory-server');
const app = require('../app');
const User = require('../models/user');
const Book = require('../models/books');
const Trade = require('../models/trade');

let mongoServer;
let userToken;
let userId;
let bookId;
let secondUserToken;

beforeAll(async () => {
  mongoServer = await MongoMemoryServer.create();
  const uri = mongoServer.getUri();
  await mongoose.connect(uri);
});

afterAll(async () => {
  await mongoose.disconnect();
  await mongoServer.stop();
});

describe('BookSwap Backend API Test Suite', () => {
  describe('Health and Root Endpoint', () => {
    it('GET / should return welcome message', async () => {
      const res = await request(app).get('/');
      expect(res.status).toBe(200);
      expect(res.text).toContain('Book Swap API is running');
    });

    it('GET /health should return 200 ok and uptime', async () => {
      const res = await request(app).get('/health');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('ok');
    });
  });

  describe('Authentication Flow', () => {
    it('POST /api/auth/register should register a user successfully with role "user"', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({
          name: 'Alice Reader',
          email: 'alice@example.com',
          password: 'Password123!',
          role: 'admin', // attempting privilege escalation
        });

      expect(res.status).toBe(200);
      expect(res.body.token).toBeDefined();
      expect(res.body.user).toBeDefined();
      expect(res.body.user.role).toBe('user'); // privilege escalation prevented
      userToken = res.body.token;
      userId = res.body.userId;
    });

    it('POST /api/auth/register should reject duplicate email', async () => {
      const res = await request(app)
        .post('/api/auth/register')
        .send({
          name: 'Alice Reader 2',
          email: 'alice@example.com',
          password: 'AnotherPassword!',
        });

      expect(res.status).toBe(400);
      expect(res.body.message).toContain('already exists');
    });

    it('POST /api/auth/login should log in successfully', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'alice@example.com',
          password: 'Password123!',
        });

      expect(res.status).toBe(200);
      expect(res.body.token).toBeDefined();
      expect(res.body.user.email).toBe('alice@example.com');
    });

    it('POST /api/auth/login should reject invalid password with 401', async () => {
      const res = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'alice@example.com',
          password: 'WrongPassword!',
        });

      expect(res.status).toBe(401);
      expect(res.body.message).toContain('Invalid');
    });

    it('GET /api/auth/me should return current user profile', async () => {
      const res = await request(app)
        .get('/api/auth/me')
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.user.email).toBe('alice@example.com');
      expect(res.body.user.password).toBeUndefined();
    });

    it('PUT /api/auth/change-password should change password and allow subsequent login without double hashing', async () => {
      const changeRes = await request(app)
        .put('/api/auth/change-password')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          oldPassword: 'Password123!',
          newPassword: 'BrandNewPassword456!',
        });

      expect(changeRes.status).toBe(200);
      expect(changeRes.body.message).toContain('successfully');

      // Verify login works with the NEW password
      const newLoginRes = await request(app)
        .post('/api/auth/login')
        .send({
          email: 'alice@example.com',
          password: 'BrandNewPassword456!',
        });

      expect(newLoginRes.status).toBe(200);
      expect(newLoginRes.body.token).toBeDefined();
      userToken = newLoginRes.body.token; // Update token
    });
  });

  describe('Books CRUD Flow', () => {
    it('POST /api/books/book should add a book and generate QR code without scope crash', async () => {
      const res = await request(app)
        .post('/api/books/book')
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          title: 'The Great Gatsby',
          author: 'F. Scott Fitzgerald',
          genre: 'Classic',
          description: 'A novel set in the Jazz Age.',
        });

      expect(res.status).toBe(201);
      expect(res.body.book).toBeDefined();
      expect(res.body.book.title).toBe('The Great Gatsby');
      expect(res.body.qrCode).toBeDefined();
      expect(res.body.qrCode).toMatch(/^data:image\/png;base64,/);
      bookId = res.body.book._id;
    });

    it('GET /api/books/book should list books', async () => {
      const res = await request(app)
        .get('/api/books/book')
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(Array.isArray(res.body.Books)).toBe(true);
      expect(res.body.Books.length).toBeGreaterThan(0);
    });

    it('GET /api/books/book/:id should retrieve single book', async () => {
      const res = await request(app)
        .get(`/api/books/book/${bookId}`)
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.Book._id).toBe(bookId);
    });

    it('PUT /api/books/book/:id should update book info', async () => {
      const res = await request(app)
        .put(`/api/books/book/${bookId}`)
        .set('Authorization', `Bearer ${userToken}`)
        .send({
          description: 'Updated description for Jazz Age classic.',
        });

      expect(res.status).toBe(200);
      expect(res.body.updatedBook.description).toContain('Updated description');
    });
  });

  describe('Trades Flow & Parameter Handling', () => {
    let secondUserId;
    let tradeId;

    beforeAll(async () => {
      const user2Res = await request(app)
        .post('/api/auth/register')
        .send({
          name: 'Bob Swapper',
          email: 'bob@example.com',
          password: 'BobPassword123!',
        });
      secondUserToken = user2Res.body.token;
      secondUserId = user2Res.body.userId;
    });

    it('POST /api/trades/trade should initiate a trade request', async () => {
      const res = await request(app)
        .post('/api/trades/trade')
        .set('Authorization', `Bearer ${secondUserToken}`)
        .send({
          requestedBookId: bookId,
          notes: 'Would love to swap for this classic!',
        });

      expect(res.status).toBe(201);
      expect(res.body._id).toBeDefined();
      expect(res.body.status).toBe('pending');
      tradeId = res.body._id;
    });

    it('PUT /api/trades/trade/:id/accept should allow book owner to accept trade', async () => {
      const res = await request(app)
        .put(`/api/trades/trade/${tradeId}/accept`)
        .set('Authorization', `Bearer ${userToken}`); // Owner is Alice

      expect(res.status).toBe(200);
      expect(res.body.message).toContain('accepted');
    });

    it('PUT /api/trades/trade/:id/complete should complete trade using fixed route parameter', async () => {
      const res = await request(app)
        .put(`/api/trades/trade/${tradeId}/complete`)
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.status).toBe('completed');
    });
  });

  describe('Cleanup', () => {
    it('DELETE /api/books/book/:id should allow the new owner to delete the swapped book', async () => {
      const res = await request(app)
        .delete(`/api/books/book/${bookId}`)
        .set('Authorization', `Bearer ${secondUserToken}`); // Bob is the new owner after completed swap

      expect(res.status).toBe(200);
      expect(res.body.message).toContain('deleted');
    });
  });
});
