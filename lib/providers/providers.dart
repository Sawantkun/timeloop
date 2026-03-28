import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import '../models/models.dart';

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
  final fs.FirebaseFirestore _db = fs.FirebaseFirestore.instance;

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
  final fs.FirebaseFirestore _db = fs.FirebaseFirestore.instance;

  double _balance = 0;
  List<Transaction> _transactions = [];
  bool _isLoading = false;
  String? _userId;

  double get balance => _balance;
  List<Transaction> get transactions => _transactions;
  bool get isLoading => _isLoading;

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _load(userId);
  }

  void clear() {
    _balance = 0;
    _transactions = [];
    _userId = null;
    notifyListeners();
  }

  Future<void> _load(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Load balance from user doc
      final userDoc = await _db.collection('users').doc(userId).get();
      _balance = (userDoc.data()?['walletBalance'] as num?)?.toDouble() ?? 0.0;

      // Load transactions subcollection
      final snap = await _db
          .collection('users').doc(userId).collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();
      _transactions = snap.docs.map((d) => Transaction.fromJson(d.data())).toList();
    } catch (e) {
      debugPrint('WalletProvider._load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCredits(double amount, String description) async {
    if (_userId == null) return;
    _isLoading = true;
    notifyListeners();
    _balance += amount;
    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.earned,
      amount: amount,
      description: description,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);
    _isLoading = false;
    notifyListeners();
    // Write to Firestore
    await _db.collection('users').doc(_userId).update({'walletBalance': _balance});
    await _db.collection('users').doc(_userId)
        .collection('transactions').doc(tx.id).set(tx.toJson());
  }

  Future<bool> spendCredits(double amount, String description, String counterpartName) async {
    if (_balance < amount || _userId == null) return false;
    _isLoading = true;
    notifyListeners();
    _balance -= amount;
    final tx = Transaction(
      id: 'tx_${DateTime.now().millisecondsSinceEpoch}',
      type: TransactionType.spent,
      amount: amount,
      description: description,
      counterpartName: counterpartName,
      createdAt: DateTime.now(),
    );
    _transactions.insert(0, tx);
    _isLoading = false;
    notifyListeners();
    await _db.collection('users').doc(_userId).update({'walletBalance': _balance});
    await _db.collection('users').doc(_userId)
        .collection('transactions').doc(tx.id).set(tx.toJson());
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
  final fs.FirebaseFirestore _db = fs.FirebaseFirestore.instance;

  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _userId;

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

  List<Booking> get disputed => _bookings.where((b) => b.status == SwapStatus.disputed).toList();

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _load(userId);
  }

  void clear() {
    _bookings = [];
    _userId = null;
    notifyListeners();
  }

  Future<void> _load(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      // Fetch bookings where user is requester or provider (two queries, merged)
      final asRequester = await _db.collection('bookings')
          .where('requesterId', isEqualTo: userId).get();
      final asProvider = await _db.collection('bookings')
          .where('providerId', isEqualTo: userId).get();
      final seen = <String>{};
      _bookings = [
        ...asRequester.docs,
        ...asProvider.docs,
      ]
          .where((d) => seen.add(d.id))
          .map((d) => Booking.fromJson(d.data()))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('BookingsProvider._load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Booking?> createBooking({
    required String requesterId,
    required String requesterName,
    required String providerId,
    required String providerName,
    required Skill skill,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    final booking = Booking(
      id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
      requesterId: requesterId,
      providerId: providerId,
      requesterName: requesterName,
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

    await _db.collection('bookings').doc(booking.id).set(booking.toJson());
    return booking;
  }

  Future<void> updateStatus(String bookingId, SwapStatus status) async {
    final idx = _bookings.indexWhere((b) => b.id == bookingId);
    if (idx == -1) return;
    _bookings[idx] = _bookings[idx].copyWith(status: status);
    notifyListeners();
    await _db.collection('bookings').doc(bookingId).update({'status': status.name});
  }
}

// ─── Chat Provider ─────────────────────────────────────────────
class ChatProvider extends ChangeNotifier {
  final fs.FirebaseFirestore _db = fs.FirebaseFirestore.instance;

  List<Conversation> _conversations = [];
  bool _isLoading = false;
  String? _userId;

  List<Conversation> get conversations => _conversations;
  bool get isLoading => _isLoading;
  int get totalUnread => _conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void init(String userId) {
    if (_userId == userId) return;
    _userId = userId;
    _load(userId);
  }

  void clear() {
    _conversations = [];
    _userId = null;
    notifyListeners();
  }

  Future<void> _load(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      final snap = await _db
          .collection('users').doc(userId).collection('conversations')
          .orderBy('lastMessageAt', descending: true)
          .get();
      _conversations = await Future.wait(snap.docs.map((d) async {
        final conv = Conversation.fromJson(d.data());
        final convId = _conversationId(userId, conv.otherUserId);
        final msgSnap = await _db
            .collection('conversations').doc(convId).collection('messages')
            .orderBy('sentAt')
            .get();
        final msgs = msgSnap.docs.map((m) => ChatMessage.fromJson(m.data())).toList();
        return conv.copyWith(messages: msgs);
      }));
    } catch (e) {
      debugPrint('ChatProvider._load error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Deterministic conversation ID for two users
  String _conversationId(String uid1, String uid2) {
    final sorted = [uid1, uid2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  Conversation? getConversation(String otherUserId) {
    try {
      return _conversations.firstWhere((c) => c.otherUserId == otherUserId);
    } catch (_) {
      return null;
    }
  }

  Future<void> sendMessage(String conversationId, String senderId, String text) async {
    if (_userId == null) return;
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;

    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      text: text,
      sentAt: DateTime.now(),
      isRead: true,
    );

    _conversations[idx] = _conversations[idx].copyWith(
      messages: [..._conversations[idx].messages, msg],
      lastMessage: text,
      lastMessageAt: DateTime.now(),
    );
    notifyListeners();

    final otherUserId = _conversations[idx].otherUserId;
    final convDocId = _conversationId(_userId!, otherUserId);

    // Write message to shared conversation
    await _db.collection('conversations').doc(convDocId)
        .collection('messages').doc(msg.id).set(msg.toJson());

    // Update both users' conversation index
    final convData = _conversations[idx].toJson();
    await _db.collection('users').doc(_userId)
        .collection('conversations').doc(otherUserId).set(convData);
    // Update other user's copy (swap perspective)
    final otherConvData = {
      ...convData,
      'otherUserId': _userId,
      'otherUserName': convData['otherUserName'], // will be overwritten below
      'unreadCount': fs.FieldValue.increment(1),
    };
    await _db.collection('users').doc(otherUserId)
        .collection('conversations').doc(_userId).set(otherConvData, fs.SetOptions(merge: true));
  }

  void markAsRead(String conversationId) {
    if (_userId == null) return;
    final idx = _conversations.indexWhere((c) => c.id == conversationId);
    if (idx == -1) return;
    _conversations[idx] = _conversations[idx].copyWith(unreadCount: 0);
    notifyListeners();
    final otherUserId = _conversations[idx].otherUserId;
    _db.collection('users').doc(_userId)
        .collection('conversations').doc(otherUserId)
        .update({'unreadCount': 0}).catchError((_) {});
  }

  Conversation startConversation(UserModel other) {
    final existing = getConversation(other.id);
    if (existing != null) return existing;

    final conv = Conversation(
      id: other.id,
      otherUserId: other.id,
      otherUserName: other.name,
      otherUserAvatar: other.avatarUrl,
      otherUserOnline: other.isOnline,
      lastMessage: '',
      lastMessageAt: DateTime.now(),
      unreadCount: 0,
      messages: [],
    );
    _conversations.insert(0, conv);
    notifyListeners();

    // Persist in background
    if (_userId != null) {
      _db.collection('users').doc(_userId)
          .collection('conversations').doc(other.id)
          .set(conv.toJson()).catchError((_) {});
    }
    return conv;
  }
}
