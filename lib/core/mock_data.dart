import '../models/models.dart';

// ─── Mock Skills ───────────────────────────────────────────────
class MockSkills {
  static const coding = Skill(
    id: 'skill_coding',
    name: 'Python Programming',
    category: 'Technology',
    emoji: '💻',
    level: 3,
    hourlyCredits: 1.0,
  );

  static const guitar = Skill(
    id: 'skill_guitar',
    name: 'Guitar Lessons',
    category: 'Music',
    emoji: '🎸',
    level: 2,
    hourlyCredits: 1.0,
  );

  static const yoga = Skill(
    id: 'skill_yoga',
    name: 'Yoga Instruction',
    category: 'Wellness',
    emoji: '🧘',
    level: 3,
    hourlyCredits: 1.0,
  );

  static const cooking = Skill(
    id: 'skill_cooking',
    name: 'Italian Cooking',
    category: 'Culinary',
    emoji: '🍝',
    level: 2,
    hourlyCredits: 1.0,
  );

  static const photography = Skill(
    id: 'skill_photo',
    name: 'Photography',
    category: 'Creative',
    emoji: '📸',
    level: 3,
    hourlyCredits: 1.0,
  );

  static const spanish = Skill(
    id: 'skill_spanish',
    name: 'Spanish Language',
    category: 'Languages',
    emoji: '🇪🇸',
    level: 2,
    hourlyCredits: 1.0,
  );

  static const design = Skill(
    id: 'skill_design',
    name: 'UI/UX Design',
    category: 'Technology',
    emoji: '🎨',
    level: 3,
    hourlyCredits: 1.0,
  );

  static const fitness = Skill(
    id: 'skill_fitness',
    name: 'Personal Training',
    category: 'Wellness',
    emoji: '💪',
    level: 2,
    hourlyCredits: 1.0,
  );

  static const piano = Skill(
    id: 'skill_piano',
    name: 'Piano Lessons',
    category: 'Music',
    emoji: '🎹',
    level: 2,
    hourlyCredits: 1.0,
  );

  static const writing = Skill(
    id: 'skill_writing',
    name: 'Copywriting',
    category: 'Creative',
    emoji: '✍️',
    level: 3,
    hourlyCredits: 1.0,
  );

  static const flutter = Skill(
    id: 'skill_flutter',
    name: 'Flutter Dev',
    category: 'Technology',
    emoji: '📱',
    level: 3,
    hourlyCredits: 1.0,
  );

  static const meditation = Skill(
    id: 'skill_meditation',
    name: 'Meditation',
    category: 'Wellness',
    emoji: '🌿',
    level: 2,
    hourlyCredits: 1.0,
  );

  static List<Skill> all = [
    coding, guitar, yoga, cooking, photography,
    spanish, design, fitness, piano, writing,
    flutter, meditation,
  ];
}

// ─── Mock Users ────────────────────────────────────────────────
class MockUsers {
  static final currentUser = UserModel(
    id: 'user_me',
    name: 'Alex Rivera',
    email: 'alex@timeloop.app',
    avatarUrl: null,
    bio: 'Full-stack dev by day, aspiring musician by night. Love connecting with creative souls!',
    location: 'San Francisco, CA',
    rating: 4.8,
    reviewCount: 23,
    completedSwaps: 31,
    skillsOffered: [MockSkills.coding, MockSkills.flutter, MockSkills.writing],
    skillsNeeded: [MockSkills.guitar, MockSkills.yoga, MockSkills.photography],
    walletBalance: 12.5,
    joinedAt: DateTime(2024, 3, 15),
    isOnline: true,
    availability: ['Mon', 'Wed', 'Fri', 'Sat'],
  );

  static final sarah = UserModel(
    id: 'user_sarah',
    name: 'Sarah Chen',
    email: 'sarah@timeloop.app',
    avatarUrl: null,
    bio: 'Professional guitarist & music teacher. Also passionate about tech — learning to code!',
    location: 'San Francisco, CA',
    rating: 4.9,
    reviewCount: 47,
    completedSwaps: 58,
    skillsOffered: [MockSkills.guitar, MockSkills.piano, MockSkills.meditation],
    skillsNeeded: [MockSkills.coding, MockSkills.flutter, MockSkills.design],
    walletBalance: 8.0,
    joinedAt: DateTime(2023, 11, 5),
    isOnline: true,
    availability: ['Tue', 'Thu', 'Sat', 'Sun'],
  );

  static final marcus = UserModel(
    id: 'user_marcus',
    name: 'Marcus Johnson',
    email: 'marcus@timeloop.app',
    avatarUrl: null,
    bio: 'Certified yoga instructor & wellness coach. Here to swap skills and grow together.',
    location: 'Oakland, CA',
    rating: 4.7,
    reviewCount: 35,
    completedSwaps: 42,
    skillsOffered: [MockSkills.yoga, MockSkills.fitness, MockSkills.meditation],
    skillsNeeded: [MockSkills.coding, MockSkills.writing, MockSkills.photography],
    walletBalance: 15.5,
    joinedAt: DateTime(2024, 1, 20),
    isOnline: false,
    availability: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
  );

  static final luna = UserModel(
    id: 'user_luna',
    name: 'Luna Vasquez',
    email: 'luna@timeloop.app',
    avatarUrl: null,
    bio: 'Award-winning photographer & visual storyteller. Let\'s create something beautiful!',
    location: 'Berkeley, CA',
    rating: 4.9,
    reviewCount: 52,
    completedSwaps: 64,
    skillsOffered: [MockSkills.photography, MockSkills.design, MockSkills.cooking],
    skillsNeeded: [MockSkills.coding, MockSkills.spanish, MockSkills.yoga],
    walletBalance: 6.5,
    joinedAt: DateTime(2023, 8, 10),
    isOnline: true,
    availability: ['Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
  );

  static final james = UserModel(
    id: 'user_james',
    name: 'James Park',
    email: 'james@timeloop.app',
    avatarUrl: null,
    bio: 'Native Spanish speaker, language tutor. Learning guitar and exploring tech.',
    location: 'San Jose, CA',
    rating: 4.6,
    reviewCount: 28,
    completedSwaps: 33,
    skillsOffered: [MockSkills.spanish, MockSkills.cooking, MockSkills.writing],
    skillsNeeded: [MockSkills.guitar, MockSkills.flutter, MockSkills.fitness],
    walletBalance: 9.0,
    joinedAt: DateTime(2024, 2, 14),
    isOnline: true,
    availability: ['Mon', 'Wed', 'Sat'],
  );

  static final priya = UserModel(
    id: 'user_priya',
    name: 'Priya Nair',
    email: 'priya@timeloop.app',
    avatarUrl: null,
    bio: 'UX designer with 8 years at top tech companies. Passionate about mindful living.',
    location: 'San Francisco, CA',
    rating: 5.0,
    reviewCount: 19,
    completedSwaps: 22,
    skillsOffered: [MockSkills.design, MockSkills.photography, MockSkills.meditation],
    skillsNeeded: [MockSkills.coding, MockSkills.cooking, MockSkills.guitar],
    walletBalance: 11.0,
    joinedAt: DateTime(2024, 4, 1),
    isOnline: false,
    availability: ['Tue', 'Thu', 'Sat', 'Sun'],
  );

  static List<UserModel> all = [sarah, marcus, luna, james, priya];
}

// ─── Mock Matches ──────────────────────────────────────────────
class MockMatches {
  static List<SkillMatch> getForUser(UserModel user) {
    return [
      SkillMatch(
        user: MockUsers.sarah,
        theyOffer: MockSkills.guitar,
        youNeed: MockSkills.guitar,
        matchScore: 0.96,
        matchReasons: [
          'Perfect skill match',
          '0.8 km away',
          'Both available Saturday',
          '4.9★ rated',
        ],
        distanceKm: 0.8,
      ),
      SkillMatch(
        user: MockUsers.marcus,
        theyOffer: MockSkills.yoga,
        youNeed: MockSkills.yoga,
        matchScore: 0.88,
        matchReasons: [
          'Exact skill match',
          '3.2 km away',
          'Available Mon & Wed',
          'Expert level yoga',
        ],
        distanceKm: 3.2,
      ),
      SkillMatch(
        user: MockUsers.luna,
        theyOffer: MockSkills.photography,
        youNeed: MockSkills.photography,
        matchScore: 0.82,
        matchReasons: [
          'Photography expert',
          '5.1 km away',
          'Available weekends',
          '52 completed swaps',
        ],
        distanceKm: 5.1,
      ),
      SkillMatch(
        user: MockUsers.priya,
        theyOffer: MockSkills.design,
        youNeed: MockSkills.design,
        matchScore: 0.79,
        matchReasons: [
          'Top-rated designer',
          '2.4 km away',
          'Both available Sunday',
          'Wants Flutter skills',
        ],
        distanceKm: 2.4,
      ),
    ];
  }
}

// ─── Mock Bookings ─────────────────────────────────────────────
class MockBookings {
  static List<Booking> getForUser(String userId) {
    final now = DateTime.now();
    return [
      Booking(
        id: 'booking_1',
        requesterId: userId,
        providerId: MockUsers.sarah.id,
        requesterName: MockUsers.currentUser.name,
        providerName: MockUsers.sarah.name,
        skill: MockSkills.guitar,
        status: SwapStatus.confirmed,
        scheduledAt: now.add(const Duration(days: 2, hours: 3)),
        durationMinutes: 60,
        creditsAmount: 1.0,
        notes: 'Would love to start with basic chords!',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      Booking(
        id: 'booking_2',
        requesterId: MockUsers.marcus.id,
        providerId: userId,
        requesterName: MockUsers.marcus.name,
        providerName: MockUsers.currentUser.name,
        skill: MockSkills.coding,
        status: SwapStatus.completed,
        scheduledAt: now.subtract(const Duration(days: 3)),
        durationMinutes: 90,
        creditsAmount: 1.5,
        createdAt: now.subtract(const Duration(days: 5)),
        requesterRating: 5.0,
        providerRating: 4.0,
      ),
      Booking(
        id: 'booking_3',
        requesterId: userId,
        providerId: MockUsers.luna.id,
        requesterName: MockUsers.currentUser.name,
        providerName: MockUsers.luna.name,
        skill: MockSkills.photography,
        status: SwapStatus.pending,
        scheduledAt: now.add(const Duration(days: 5)),
        durationMinutes: 60,
        creditsAmount: 1.0,
        notes: 'Portrait photography session in the park',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
      Booking(
        id: 'booking_4',
        requesterId: MockUsers.james.id,
        providerId: userId,
        requesterName: MockUsers.james.name,
        providerName: MockUsers.currentUser.name,
        skill: MockSkills.flutter,
        status: SwapStatus.completed,
        scheduledAt: now.subtract(const Duration(days: 7)),
        durationMinutes: 120,
        creditsAmount: 2.0,
        createdAt: now.subtract(const Duration(days: 9)),
        requesterRating: 4.5,
        providerRating: 5.0,
      ),
      Booking(
        id: 'booking_5',
        requesterId: userId,
        providerId: MockUsers.marcus.id,
        requesterName: MockUsers.currentUser.name,
        providerName: MockUsers.marcus.name,
        skill: MockSkills.yoga,
        status: SwapStatus.disputed,
        scheduledAt: now.subtract(const Duration(days: 10)),
        durationMinutes: 60,
        creditsAmount: 1.0,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }
}

// ─── Mock Transactions ─────────────────────────────────────────
class MockTransactions {
  static List<Transaction> getForUser(String userId) {
    final now = DateTime.now();
    return [
      Transaction(
        id: 'tx_1',
        type: TransactionType.earned,
        amount: 1.5,
        description: 'Python lesson — Marcus',
        counterpartName: 'Marcus Johnson',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      Transaction(
        id: 'tx_2',
        type: TransactionType.spent,
        amount: 1.0,
        description: 'Guitar lesson booking',
        counterpartName: 'Sarah Chen',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      Transaction(
        id: 'tx_3',
        type: TransactionType.earned,
        amount: 2.0,
        description: 'Flutter coaching — James',
        counterpartName: 'James Park',
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Transaction(
        id: 'tx_4',
        type: TransactionType.bonus,
        amount: 3.0,
        description: 'Welcome bonus credits',
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Transaction(
        id: 'tx_5',
        type: TransactionType.spent,
        amount: 1.0,
        description: 'Photography session',
        counterpartName: 'Luna Vasquez',
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Transaction(
        id: 'tx_6',
        type: TransactionType.refund,
        amount: 1.0,
        description: 'Dispute refund',
        counterpartName: 'Marcus Johnson',
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Transaction(
        id: 'tx_7',
        type: TransactionType.earned,
        amount: 1.0,
        description: 'Writing workshop — Priya',
        counterpartName: 'Priya Nair',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }
}

// ─── Mock Conversations ────────────────────────────────────────
class MockConversations {
  static List<Conversation> getForUser(String userId) {
    final now = DateTime.now();
    return [
      Conversation(
        id: 'conv_sarah',
        otherUserId: MockUsers.sarah.id,
        otherUserName: MockUsers.sarah.name,
        otherUserOnline: true,
        lastMessage: 'See you Saturday at 3pm! 🎸',
        lastMessageAt: now.subtract(const Duration(minutes: 15)),
        unreadCount: 2,
        messages: [
          ChatMessage(
            id: 'msg_1',
            senderId: MockUsers.sarah.id,
            text: 'Hey Alex! I got your swap request.',
            sentAt: now.subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'msg_2',
            senderId: userId,
            text: 'Hi Sarah! Yes, I\'d love to learn guitar from you. I can help you with Python in return!',
            sentAt: now.subtract(const Duration(hours: 1, minutes: 50)),
          ),
          ChatMessage(
            id: 'msg_3',
            senderId: MockUsers.sarah.id,
            text: 'That sounds perfect! Saturday at 3pm works for me.',
            sentAt: now.subtract(const Duration(hours: 1, minutes: 30)),
          ),
          ChatMessage(
            id: 'msg_4',
            senderId: userId,
            text: 'Amazing! I\'ll confirm the booking now.',
            sentAt: now.subtract(const Duration(hours: 1, minutes: 20)),
          ),
          ChatMessage(
            id: 'msg_5',
            senderId: MockUsers.sarah.id,
            text: 'See you Saturday at 3pm! 🎸',
            sentAt: now.subtract(const Duration(minutes: 15)),
          ),
        ],
      ),
      Conversation(
        id: 'conv_marcus',
        otherUserId: MockUsers.marcus.id,
        otherUserName: MockUsers.marcus.name,
        otherUserOnline: false,
        lastMessage: 'Thanks for the great Python session!',
        lastMessageAt: now.subtract(const Duration(days: 3, hours: 2)),
        unreadCount: 0,
        messages: [
          ChatMessage(
            id: 'msg_6',
            senderId: MockUsers.marcus.id,
            text: 'Thanks for the great Python session!',
            sentAt: now.subtract(const Duration(days: 3, hours: 2)),
          ),
          ChatMessage(
            id: 'msg_7',
            senderId: userId,
            text: 'My pleasure! Your progress is really impressive.',
            sentAt: now.subtract(const Duration(days: 3, hours: 1)),
          ),
        ],
      ),
      Conversation(
        id: 'conv_luna',
        otherUserId: MockUsers.luna.id,
        otherUserName: MockUsers.luna.name,
        otherUserOnline: true,
        lastMessage: 'The park near the lake has great lighting!',
        lastMessageAt: now.subtract(const Duration(hours: 6)),
        unreadCount: 1,
        messages: [
          ChatMessage(
            id: 'msg_8',
            senderId: userId,
            text: 'Hi Luna! I\'d love a portrait photography session.',
            sentAt: now.subtract(const Duration(hours: 7)),
          ),
          ChatMessage(
            id: 'msg_9',
            senderId: MockUsers.luna.id,
            text: 'The park near the lake has great lighting!',
            sentAt: now.subtract(const Duration(hours: 6)),
          ),
        ],
      ),
    ];
  }
}

// ─── Mock Reviews ──────────────────────────────────────────────
class MockReviews {
  static List<Review> getForUser(String userId) {
    final now = DateTime.now();
    return [
      Review(
        id: 'rev_1',
        reviewerId: MockUsers.marcus.id,
        reviewerName: MockUsers.marcus.name,
        rating: 5.0,
        comment: 'Alex is an incredible teacher! Explained complex Python concepts with clarity. Would swap again!',
        createdAt: now.subtract(const Duration(days: 3)),
        skill: MockSkills.coding,
      ),
      Review(
        id: 'rev_2',
        reviewerId: MockUsers.james.id,
        reviewerName: MockUsers.james.name,
        rating: 4.5,
        comment: 'Super patient and knowledgeable about Flutter. Helped me get my first app running!',
        createdAt: now.subtract(const Duration(days: 7)),
        skill: MockSkills.flutter,
      ),
      Review(
        id: 'rev_3',
        reviewerId: MockUsers.priya.id,
        reviewerName: MockUsers.priya.name,
        rating: 5.0,
        comment: 'Great writing tips and genuine feedback on my portfolio copy. Highly recommend!',
        createdAt: now.subtract(const Duration(days: 14)),
        skill: MockSkills.writing,
      ),
    ];
  }
}

// ─── Mock Disputes ─────────────────────────────────────────────
class MockDisputes {
  static List<Dispute> getForUser(String userId) {
    final now = DateTime.now();
    return [
      Dispute(
        id: 'dispute_1',
        bookingId: 'booking_5',
        complainantId: userId,
        complainantName: MockUsers.currentUser.name,
        respondentName: MockUsers.marcus.name,
        reason: DisputeReason.noShow,
        status: DisputeStatus.resolved,
        description: 'Marcus did not show up for the scheduled yoga session without prior notice.',
        createdAt: now.subtract(const Duration(days: 9)),
        resolution: 'Full refund of 1.0 time credit issued after review.',
        refundAmount: 1.0,
      ),
    ];
  }
}
