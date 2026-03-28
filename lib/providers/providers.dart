import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../core/mock_data.dart';

// ─── Theme Provider ────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;
  bool get isDark => _mode == ThemeMode.dark;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('theme_mode') ?? 'system';
    _mode = saved == 'dark'
        ? ThemeMode.dark
        : saved == 'light'
            ? ThemeMode.light
            : ThemeMode.system;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', mode == ThemeMode.dark ? 'dark' : 'light');
    notifyListeners();
  }
}

// ─── Auth Provider ─────────────────────────────────────────────
enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(fb_auth.User? user) async {
    if (user == null) {
      _currentUser = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromJson(doc.data()!);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message ?? 'Invalid email or password.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);
      final user = UserModel(
        id: cred.user!.uid,
        name: name,
        email: email,
        bio: '',
        location: '',
        rating: 0.0,
        reviewCount: 0,
        completedSwaps: 0,
        skillsOffered: [],
        skillsNeeded: [],
        walletBalance: 5.0,
        joinedAt: DateTime.now(),
        availability: [],
      );
      await _db.collection('users').doc(user.id).set(user.toJson());
      _currentUser = user;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.message ?? 'Signup failed.';
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (_) {
      return false;
    }
  }

  void updateUser(UserModel user) {
    _currentUser = user;
    notifyListeners();
  }
}

// ─── Wallet Provider ───────────────────────────────────────────
class WalletProvider extends ChangeNotifier {
  double _balance = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  void init(String userId) {
    _balance = MockUsers.currentUser.walletBalance;
    _transactions = MockTransactions.getForUser(userId);
    notifyListeners();
  }

  Future<void> addCredits(double amount, String description) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _balance += amount;
    _transactions.insert(
      0,
      Transaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.earned,
        amount: amount,
        description: description,
        createdAt: DateTime.now(),
      ),
    );
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> spendCredits(double amount, String description, String counterpartName) async {
    if (_balance < amount) return false;
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 500));
    _balance -= amount;
    _transactions.insert(
      0,
      Transaction(
        id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
        type: TransactionType.spent,
        amount: amount,
        description: description,
        counterpartName: counterpartName,
        createdAt: DateTime.now(),
      ),
    );
    _isLoading = false;
    notifyListeners();
    return true;
  }

  List<double> get weeklyData {
    final now = DateTime.now();
    return List.generate(7, (i) {
      final day = now.subtract(Duration(days: 6 - i));
      return _transactions
          .where((t) => t.createdAt.day == day.day && t.isCredit)
          .fold(0.0, (sum, t) => sum + t.amount);
    });
  }
}

// ─── Bookings Provider ─────────────────────────────────────────
class BookingsProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;

  List<Booking> get upcoming => _bookings
      .where((b) => b.scheduledAt.isAfter(DateTime.now()) &&
          (b.status == SwapStatus.confirmed || b.status == SwapStatus.pending))
      .toList()
    ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  List<Booking> get past => _bookings
      .where((b) => b.status == SwapStatus.completed || b.status == SwapStatus.cancelled)
      .toList()
    ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

  List<Booking> get disputed => _bookings
      .where((b) => b.status == SwapStatus.disputed)
      .toList();

  void init(String userId) {
    _bookings = MockBookings.getForUser(userId);
    notifyListeners();
  }

  Future<Booking?> createBooking({
    required String providerId,
    required String providerName,
    required Skill skill,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));

    final booking = Booking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      requesterId: MockUsers.currentUser.id,
      providerId: providerId,
      requesterName: MockUsers.currentUser.name,
      providerName: providerName,
      skill: skill,
      status: SwapStatus.pending,
      scheduledAt: scheduledAt,
      durationMinutes: durationMinutes,
      creditsAmount: durationMinutes / 60.0,
      notes: notes,
      createdAt: DateTime.now(),
    );

    _bookings.insert(0, booking);
    _isLoading = false;
    notifyListeners();
    return booking;
  }

  Future<void> updateStatus(String bookingId, SwapStatus status) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;
    _bookings[idx] = Booking(
      id: _bookings[idx].id,
      requesterId: _bookings[idx].requesterId,
      providerId: _bookings[idx].providerId,
      requesterName: _bookings[idx].requesterName,
      providerName: _bookings[idx].providerName,
      skill: _bookings[idx].skill,
      status: status,
      scheduledAt: _bookings[idx].scheduledAt,
      durationMinutes: _bookings[idx].durationMinutes,
      creditsAmount: _bookings[idx].creditsAmount,
      notes: _bookings[idx].notes,
      createdAt: _bookings[idx].createdAt,
    );
    notifyListeners();
  }
}

// ─── Chat Provider ─────────────────────────────────────────────
class ChatProvider extends ChangeNotifier {
  List<Conversation> _conversations = [];
  bool _isLoading = false;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  int get totalUnread => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void init(String userId) {
    _conversations = MockConversations.getForUser(userId);
    notifyListeners();
  }

  Conversation? getConversation(String otherUserId) {
    try {
      return _conversations.firstWhere((c) => c.otherUserId == otherUserId);
    } catch (_) {
      return null;
    }
  }

  Future<void> sendMessage(String conversationId, String senderId, String text) async {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      text: text,
      sentAt: DateTime.now(),
      isRead: false,
    );

    final updated = _conversations[idx].copyWith(
      messages: [..._conversations[idx].messages, msg],
      lastMessage: text,
      lastMessageAt: DateTime.now(),
    );
    _conversations[idx] = updated;
    notifyListeners();

    // Simulate reply after delay
    await Future.delayed(const Duration(seconds: 2));
    _simulateReply(conversationId, _conversations[idx].otherUserId);
  }

  void _simulateReply(String conversationId, String senderId) {
    final replies = [
      'Sounds great! 😊',
      'Perfect, I\'ll be there!',
      'That works for me.',
      'Looking forward to it!',
      'Can\'t wait to learn from you!',
    ];
    final reply = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      text: replies[DateTime.now().millisecond % replies.length],
      sentAt: DateTime.now(),
      isRead: false,
    );

    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    _conversations[idx] = _conversations[idx].copyWith(
      messages: [..._conversations[idx].messages, reply],
      lastMessage: reply.text,
      lastMessageAt: reply.sentAt,
      unreadCount: _conversations[idx].unreadCount + 1,
    );
    notifyListeners();
  }

  void markAsRead(String conversationId) {
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
    notifyListeners();
  }

  Conversation startConversation(UserModel other) {
    final existing = getConversation(other.id);
    if (existing != null) return existing;

    final conv = Conversation(
      id: 'conv_${other.id}',
      otherUserId: other.id,
      otherUserName: other.name,
      otherUserAvatar: other.avatarUrl,
      otherUserOnline: other.isOnline,
      lastMessage: 'Start a conversation...',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      messages: [],
    );
    _conversations.insert(0, conv);
    notifyListeners();
    return conv;
  }
}
