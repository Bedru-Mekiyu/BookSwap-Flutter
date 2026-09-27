/**
 * BookSwap Comprehensive Database Seeding Script
 * 
 * Supports two modes:
 *  1. Direct MongoDB Mode (default if MONGO_URI is set or local mongo is up):
 *     Directly connects via Mongoose and inserts/upserts demo users and books.
 *  2. REST API Mode (triggered with --remote, --api, or when MONGO_URI is unreachable):
 *     Authenticates against the running BookSwap API (default: https://bookswap-backend-eygy.onrender.com)
 *     and registers users and creates all curated books.
 * 
 * Usage:
 *   node seed.js               # Auto-detects (tries direct DB, falls back to API)
 *   node seed.js --remote      # Forces REST API mode against live Render backend
 *   node seed.js --local       # Forces direct MongoDB connection
 */

const dotenv = require('dotenv');
dotenv.config();

const API_BASE = process.env.API_URL || 'https://bookswap-backend-eygy.onrender.com';
const MONGO_URI = process.env.MONGODB_URL || process.env.MONGO_URI || 'mongodb://localhost:27017/bookswap';

// Seed User Profiles
const SEED_USERS = [
  {
    name: 'BookSwap Admin',
    email: 'admin@bookswap.com',
    password: 'AdminPassword123!',
    role: 'admin',
    profilePic: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300&auto=format&fit=crop&q=80',
  },
  {
    name: 'Demo Reader',
    email: 'reader@bookswap.com',
    password: 'Password123!',
    role: 'user',
    profilePic: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=300&auto=format&fit=crop&q=80',
  },
  {
    name: 'Elena Vance',
    email: 'collector@bookswap.com',
    password: 'Password123!',
    role: 'user',
    profilePic: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=300&auto=format&fit=crop&q=80',
  },
  {
    name: 'Marcus Aurelius',
    email: 'bookworm@bookswap.com',
    password: 'Password123!',
    role: 'user',
    profilePic: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=300&auto=format&fit=crop&q=80',
  },
];

// Curated 18 Books with verified, high-resolution covers and rich details
const SEED_BOOKS = [
  {
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    genre: 'Fiction',
    language: 'English',
    edition: 'Scribner Classic Edition',
    photo: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&auto=format&fit=crop&q=80',
    description: 'A masterpiece of American literature capturing the glittering decadence of the Jazz Age, obsessed love, and the elusive American Dream in 1920s Long Island.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'Dune',
    author: 'Frank Herbert',
    genre: 'Sci-Fi',
    language: 'English',
    edition: '50th Anniversary Deluxe Edition',
    photo: 'https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=600&auto=format&fit=crop&q=80',
    description: 'Set on the desert planet Arrakis, Dune is the story of the boy Paul Atreides, heir to a noble family tasked with ruling an inhospitable world where the only valuable commodity is the spice melange.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    genre: 'Fiction',
    language: 'English',
    edition: '60th Anniversary Edition',
    photo: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&auto=format&fit=crop&q=80',
    description: 'A gripping, heart-wrenching tale of coming-of-age in a South poisoned by virulent prejudice, viewed through the eyes of a young girl whose father risks everything for justice.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: '1984',
    author: 'George Orwell',
    genre: 'Sci-Fi',
    language: 'English',
    edition: 'Signet Classics Edition',
    photo: 'https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=600&auto=format&fit=crop&q=80',
    description: 'A chilling prophecy about totalitarian future where Big Brother is constantly watching, history is rewritten daily, and independent thought is punishable by death.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'The Hobbit',
    author: 'J.R.R. Tolkien',
    genre: 'Fantasy',
    language: 'English',
    edition: 'Illustrated Collector Edition',
    photo: 'https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=600&auto=format&fit=crop&q=80',
    description: 'Bilbo Baggins is a hobbit who enjoys a comfortable and unambitious life, until Gandalf the wizard and a company of thirteen dwarves whisk him off on a perilous quest to raid the treasure hoard of Smaug.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'Atomic Habits',
    author: 'James Clear',
    genre: 'Self-Help',
    language: 'English',
    edition: '1st Hardcover Edition',
    photo: 'https://images.unsplash.com/photo-1499750310107-5fef28a66643?w=600&auto=format&fit=crop&q=80',
    description: 'A proven, revolutionary system for getting 1% better every single day. Clear draws on ideas from biology, psychology, and neuroscience to create an easy-to-understand guide for making good habits inevitable.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
    author: 'Robert C. Martin',
    genre: 'Technology',
    language: 'English',
    edition: 'Prentice Hall 1st Edition',
    photo: 'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=600&auto=format&fit=crop&q=80',
    description: 'Even bad code can function. But if code isn’t clean, it can bring a development organization to its knees. Master principles of formatting, refactoring, meaningful naming, and testing.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'Pride and Prejudice',
    author: 'Jane Austen',
    genre: 'Classics',
    language: 'English',
    edition: 'Penguin Classics Edition',
    photo: 'https://images.unsplash.com/photo-1543002588-bfa74002ed7e?w=600&auto=format&fit=crop&q=80',
    description: 'The witty and sparkling romantic duel between the spirited Elizabeth Bennet and the proud, wealthy Mr. Darcy in early 19th-century England.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'The Alchemist',
    author: 'Paulo Coelho',
    genre: 'Fiction',
    language: 'English',
    edition: '25th Anniversary Edition',
    photo: 'https://images.unsplash.com/photo-1476275466078-4007374efbbe?w=600&auto=format&fit=crop&q=80',
    description: 'The magical story of Santiago, an Andalusian shepherd boy who journeys from Spain to the Egyptian desert in search of a treasure buried near the Pyramids.',
    ownerEmail: 'collector@bookswap.com',
  },
  {
    title: 'Sapiens: A Brief History of Humankind',
    author: 'Yuval Noah Harari',
    genre: 'Non-Fiction',
    language: 'English',
    edition: 'Harper Perennial Edition',
    photo: 'https://images.unsplash.com/photo-1457369804613-52c61a468e7d?w=600&auto=format&fit=crop&q=80',
    description: 'From examining the role of evolving humans in the global ecosystem to charting the rise of modern capitalism, Harari takes readers on an unforgettable journey through human history.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'The Da Vinci Code',
    author: 'Dan Brown',
    genre: 'Mystery',
    language: 'English',
    edition: 'Special Illustrated Edition',
    photo: 'https://images.unsplash.com/photo-1509021436665-8f07dbf5bf1d?w=600&auto=format&fit=crop&q=80',
    description: 'While in Paris, Harvard symbologist Robert Langdon is awakened by an urgent phone call: the elderly curator of the Louvre has been murdered, leaving behind baffling symbols.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'Thinking, Fast and Slow',
    author: 'Daniel Kahneman',
    genre: 'Non-Fiction',
    language: 'English',
    edition: 'Farrar, Straus and Giroux 1st Edition',
    photo: 'https://images.unsplash.com/photo-1589829085413-56de8ae18c73?w=600&auto=format&fit=crop&q=80',
    description: 'Nobel Memorial Prize winner Daniel Kahneman reveals the two systems that drive human thought: System 1 is fast and emotional; System 2 is slower and more logical.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'The Pragmatic Programmer',
    author: 'David Thomas & Andrew Hunt',
    genre: 'Technology',
    language: 'English',
    edition: '20th Anniversary Edition',
    photo: 'https://images.unsplash.com/photo-1555066931-4365d14bab8c?w=600&auto=format&fit=crop&q=80',
    description: 'Filled with classic and modern software engineering philosophies, career guidance, and practical techniques to write adaptable and maintainable code.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'The Silent Patient',
    author: 'Alex Michaelides',
    genre: 'Mystery',
    language: 'English',
    edition: 'Celadon Books 1st Edition',
    photo: 'https://images.unsplash.com/photo-1474932430478-367dbb6832c1?w=600&auto=format&fit=crop&q=80',
    description: 'Alicia Berenson’s life is seemingly perfect. Then, without warning, she shoots her husband five times in the face and never utters another word.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'Brave New World',
    author: 'Aldous Huxley',
    genre: 'Sci-Fi',
    language: 'English',
    edition: 'Harper Perennial Modern Classics',
    photo: 'https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=600&auto=format&fit=crop&q=80',
    description: 'A darkly satirical vision of a utopian society in which psychological conditioning and somatic drugs maintain harmony at the cost of human freedom and emotion.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'Designing Data-Intensive Applications',
    author: 'Martin Kleppmann',
    genre: 'Technology',
    language: 'English',
    edition: 'O’Reilly 1st Edition',
    photo: 'https://images.unsplash.com/photo-1526374965328-7f61d4dc18c5?w=600&auto=format&fit=crop&q=80',
    description: 'The definitive architectural guide to data storage, replication, partitioning, transactions, stream processing, and building scalable modern systems.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'The Midnight Library',
    author: 'Matt Haig',
    genre: 'Fantasy',
    language: 'English',
    edition: 'Viking 1st Edition',
    photo: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=600&auto=format&fit=crop&q=80',
    description: 'Between life and death there is a library where the shelves go on forever. Every book provides a chance to try another life you could have lived and see what would have happened.',
    ownerEmail: 'bookworm@bookswap.com',
  },
  {
    title: 'Sherlock Holmes: Complete Novels',
    author: 'Arthur Conan Doyle',
    genre: 'Mystery',
    language: 'English',
    edition: 'Vintage Classics Collector Edition',
    photo: 'https://images.unsplash.com/photo-1463320726281-696a485928c7?w=600&auto=format&fit=crop&q=80',
    description: 'The essential collection of Arthur Conan Doyle’s legendary detective novels, including A Study in Scarlet, The Sign of Four, and The Hound of the Baskervilles.',
    ownerEmail: 'bookworm@bookswap.com',
  },
];

// Helper: HTTP Request with native fetch
async function apiRequest(endpoint, method = 'GET', body = null, token = null) {
  const headers = { 'Content-Type': 'application/json' };
  if (token) headers['Authorization'] = `Bearer ${token}`;

  const res = await fetch(`${API_BASE}${endpoint}`, {
    method,
    headers,
    body: body ? JSON.stringify(body) : null,
  });

  const data = await res.json().catch(() => null);
  return { status: res.status, ok: res.ok, data };
}

// REST API Seeding Runner
async function seedViaAPI() {
  console.log(`\n🌐 Running Seed via REST API: ${API_BASE}\n`);

  // 1. Health check
  try {
    const health = await apiRequest('/health');
    if (!health.ok) {
      throw new Error(`Health check returned status ${health.status}`);
    }
    console.log(`✅ Backend is reachable (uptime: ${health.data?.uptime?.toFixed(1) || 'ok'}s)`);
  } catch (err) {
    console.error(`❌ Could not connect to API at ${API_BASE}:`, err.message);
    process.exit(1);
  }

  // 2. Register/Login Users
  const userTokens = {};
  for (const user of SEED_USERS) {
    if (user.role === 'admin') {
      // Check admin status
      const adminStatus = await apiRequest('/api/auth/admin-status');
      if (adminStatus.data?.isAdminRegistered) {
        // Try login
        const loginRes = await apiRequest('/api/auth/admin-login', 'POST', {
          email: user.email,
          password: user.password,
        });
        if (loginRes.ok) {
          userTokens[user.email] = loginRes.data.token;
          console.log(`🔑 Admin '${user.name}' logged in successfully.`);
        } else {
          console.log(`⚠️ Admin already registered, skipping signup.`);
        }
      } else {
        const signupRes = await apiRequest('/api/auth/admin-signup', 'POST', {
          name: user.name,
          email: user.email,
          password: user.password,
        });
        if (signupRes.ok) {
          userTokens[user.email] = signupRes.data.token;
          console.log(`👤 Admin '${user.name}' registered successfully.`);
        }
      }
    } else {
      // Regular User: try register, or login if already exists
      const regRes = await apiRequest('/api/auth/register', 'POST', {
        name: user.name,
        email: user.email,
        password: user.password,
      });

      if (regRes.ok) {
        userTokens[user.email] = regRes.data.token;
        console.log(`👤 User '${user.name}' (${user.email}) registered.`);
      } else {
        // Try login
        const loginRes = await apiRequest('/api/auth/login', 'POST', {
          email: user.email,
          password: user.password,
        });
        if (loginRes.ok) {
          userTokens[user.email] = loginRes.data.token;
          console.log(`🔑 User '${user.name}' (${user.email}) logged in.`);
        } else {
          console.error(`❌ Could not authenticate user '${user.name}':`, loginRes.data?.message);
        }
      }
    }
  }

  // 3. Fetch existing books to avoid duplicate creations
  const authEmail = Object.keys(userTokens).find((e) => userTokens[e]);
  const token = userTokens[authEmail];

  const existingRes = await apiRequest('/api/books/book', 'GET', null, token);
  const existingBooks = existingRes.data?.Books || [];
  const existingTitles = new Map(existingBooks.map((b) => [b.title.toLowerCase().trim(), b]));

  console.log(`\n📚 Found ${existingBooks.length} existing book(s) in catalog.`);

  let createdCount = 0;
  let updatedCount = 0;

  for (const bookData of SEED_BOOKS) {
    const ownerToken = userTokens[bookData.ownerEmail] || token;
    const existing = existingTitles.get(bookData.title.toLowerCase().trim());

    if (!existing) {
      // Add new book
      const addRes = await apiRequest('/api/books/book', 'POST', {
        title: bookData.title,
        author: bookData.author,
        genre: bookData.genre,
        language: bookData.language,
        edition: bookData.edition,
        description: bookData.description,
        photo: bookData.photo,
      }, ownerToken);

      if (addRes.ok) {
        createdCount++;
        console.log(`  ➕ Added: "${bookData.title}" [${bookData.genre}]`);
      } else {
        console.error(`  ❌ Failed to add "${bookData.title}":`, addRes.data?.message);
      }
    } else {
      // If photo is missing or blank, update with the verified image URL
      if (!existing.photo || existing.photo.trim() === '') {
        const updateRes = await apiRequest(`/api/books/book/${existing._id}`, 'PUT', {
          photo: bookData.photo,
          description: bookData.description,
          genre: bookData.genre,
          language: bookData.language,
          edition: bookData.edition,
        }, ownerToken);

        if (updateRes.ok) {
          updatedCount++;
          console.log(`  🔄 Updated cover/details: "${bookData.title}"`);
        }
      } else {
        console.log(`  ✓ Already up-to-date: "${bookData.title}"`);
      }
    }
  }

  console.log(`\n🎉 Seeding Completed!`);
  console.log(`   - New Books Created: ${createdCount}`);
  console.log(`   - Existing Books Updated: ${updatedCount}`);
  console.log(`   - Total Curated Books in Catalog: ${existingBooks.length + createdCount}`);
  printCredentialSummary();
}

// Direct Mongoose Seeding Runner
async function seedViaMongoose() {
  console.log(`\n🔌 Running Seed via direct Mongoose connection: ${MONGO_URI}\n`);
  const mongoose = require('mongoose');
  const User = require('./models/user');
  const Book = require('./models/books');

  try {
    await mongoose.connect(MONGO_URI, { serverSelectionTimeoutMS: 5000 });
    console.log('✅ Connected to MongoDB directly.');
  } catch (err) {
    console.warn(`⚠️ Direct MongoDB connection failed (${err.message}).`);
    console.log('🔄 Switching to REST API seeding mode automatically...');
    return await seedViaAPI();
  }

  // 1. Upsert Users
  const userMap = {};
  for (const u of SEED_USERS) {
    let existing = await User.findOne({ email: u.email });
    if (!existing) {
      existing = new User({
        name: u.name,
        email: u.email,
        password: u.password,
        role: u.role,
        profilePic: u.profilePic,
      });
      await existing.save();
      console.log(`👤 Created user: ${u.name} (${u.role})`);
    } else {
      console.log(`✓ User already exists: ${u.name} (${u.email})`);
    }
    userMap[u.email] = existing._id;
  }

  // 2. Upsert Books
  let added = 0;
  let updated = 0;
  for (const b of SEED_BOOKS) {
    const ownerId = userMap[b.ownerEmail] || userMap['collector@bookswap.com'];
    let existingBook = await Book.findOne({ title: new RegExp(`^${b.title.trim()}$`, 'i') });

    if (!existingBook) {
      existingBook = new Book({
        title: b.title,
        author: b.author,
        genre: b.genre,
        language: b.language,
        edition: b.edition,
        description: b.description,
        photo: b.photo,
        owner: ownerId,
      });
      await existingBook.save();
      added++;
      console.log(`  ➕ Added: "${b.title}" [${b.genre}]`);
    } else {
      let needsSave = false;
      if (!existingBook.photo || existingBook.photo.trim() === '') {
        existingBook.photo = b.photo;
        needsSave = true;
      }
      if (!existingBook.description) {
        existingBook.description = b.description;
        needsSave = true;
      }
      if (needsSave) {
        await existingBook.save();
        updated++;
        console.log(`  🔄 Updated: "${b.title}"`);
      } else {
        console.log(`  ✓ Already up-to-date: "${b.title}"`);
      }
    }
  }

  console.log(`\n🎉 Direct Seeding Complete! Added: ${added}, Updated: ${updated}`);
  await mongoose.disconnect();
  printCredentialSummary();
}

function printCredentialSummary() {
  console.log('\n======================================================');
  console.log('          🔑 READY-TO-USE USER CREDENTIALS            ');
  console.log('======================================================');
  console.log('1. Demo Reader Account (Main BookSwap catalog browser)');
  console.log('   - Email:    reader@bookswap.com');
  console.log('   - Password: Password123!');
  console.log('   - Purpose:  Browse books, search, and send swap requests\n');
  console.log('2. Book Collector Account (Book owner)');
  console.log('   - Email:    collector@bookswap.com');
  console.log('   - Password: Password123!');
  console.log('   - Purpose:  Owns catalog books, accepts/rejects trade requests\n');
  console.log('3. Platform Admin Account (Admin dashboard & moderation)');
  console.log('   - Email:    admin@bookswap.com');
  console.log('   - Password: AdminPassword123!');
  console.log('   - Purpose:  Access /admin_auth, manage users & all books\n');
  console.log('======================================================\n');
}

// Entry point
const isRemoteFlag = process.argv.includes('--remote') || process.argv.includes('--api');
const isLocalFlag = process.argv.includes('--local');

if (isRemoteFlag) {
  seedViaAPI().catch(console.error);
} else if (isLocalFlag) {
  seedViaMongoose().catch(console.error);
} else {
  // Auto mode: Check if direct Mongo works, otherwise use API
  seedViaMongoose().catch(() => seedViaAPI().catch(console.error));
}
