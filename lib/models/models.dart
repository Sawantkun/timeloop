import 'package:flutter/material.dart';

// ─── Skill Model ───────────────────────────────────────────────
class Skill {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final int level; // 1=Beginner, 2=Intermediate, 3=Expert
  final double hourlyCredits;

  const Skill({
    required this.id,
    required this.name,
    required this.category,
    required this.emoji,
    required this.level,
    this.hourlyCredits = 1.0,
  });

  String get levelLabel => ['', 'Beginner', 'Intermediate', 'Expert'][level];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'emoji': emoji,
        'level': level,
        'hourlyCredits': hourlyCredits,
      };

  factory Skill.fromJson(Map<String, dynamic> json) => Skill(
        id: json['id'] as String,
        name: json['name'] as String,
        category: json['category'] as String,
        emoji: json['emoji'] as String,
        level: (json['level'] as num).toInt(),
        hourlyCredits: (json['hourlyCredits'] as num?)?.toDouble() ?? 1.0,
      );

  Color get levelColor => [
    Colors.transparent,
    const Color(0xFF10B981),
    const Color(0xFF3B82F6),
    const Color(0xFF7C3AED),
  ][level];
}

// ─── User Model ────────────────────────────────────────────────
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final String bio;
  final String location;
  final double rating;
  final int reviewCount;
  final int completedSwaps;
  final List<Skill> skillsOffered;
  final List<Skill> skillsNeeded;
  final double walletBalance;
  final DateTime joinedAt;
  final bool isOnline;
  final List<String> availability; // e.g. ['Mon', 'Wed', 'Fri']

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    required this.bio,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.completedSwaps,
    required this.skillsOffered,
    required this.skillsNeeded,
    required this.walletBalance,
    required this.joinedAt,
    this.isOnline = false,
    required this.availability,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'bio': bio,
        'location': location,
        'rating': rating,
        'reviewCount': reviewCount,
        'completedSwaps': completedSwaps,
        'skillsOffered': skillsOffered.map((s) => s.toJson()).toList(),
        'skillsNeeded': skillsNeeded.map((s) => s.toJson()).toList(),
        'walletBalance': walletBalance,
        'joinedAt': joinedAt.toIso8601String(),
        'isOnline': isOnline,
        'availability': availability,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: (json['id'] as String?) ?? '',
        name: (json['name'] as String?) ?? '',
        email: (json['email'] as String?) ?? '',
        avatarUrl: json['avatarUrl'] as String?,
        bio: json['bio'] as String? ?? '',
        location: json['location'] as String? ?? '',
        rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
        reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
        completedSwaps: (json['completedSwaps'] as num?)?.toInt() ?? 0,
        skillsOffered: (json['skillsOffered'] as List<dynamic>?)
                ?.map((s) => Skill.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        skillsNeeded: (json['skillsNeeded'] as List<dynamic>?)
                ?.map((s) => Skill.fromJson(s as Map<String, dynamic>))
                .toList() ??
            [],
        walletBalance:
            (json['walletBalance'] as num?)?.toDouble() ?? 0.0,
        joinedAt: json['joinedAt'] != null
            ? DateTime.parse(json['joinedAt'] as String)
            : DateTime.now(),
        isOnline: json['isOnline'] as bool? ?? false,
        availability: List<String>.from(json['availability'] as List? ?? []),
      );

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? avatarUrl,
    String? bio,
    String? location,
    double? rating,
    int? reviewCount,
    int? completedSwaps,
    List<Skill>? skillsOffered,
    List<Skill>? skillsNeeded,
    double? walletBalance,
    DateTime? joinedAt,
    bool? isOnline,
    List<String>? availability,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      completedSwaps: completedSwaps ?? this.completedSwaps,
      skillsOffered: skillsOffered ?? this.skillsOffered,
      skillsNeeded: skillsNeeded ?? this.skillsNeeded,
      walletBalance: walletBalance ?? this.walletBalance,
      joinedAt: joinedAt ?? this.joinedAt,
      isOnline: isOnline ?? this.isOnline,
      availability: availability ?? this.availability,
    );
  }
}

// ─── Transaction Model ─────────────────────────────────────────
enum TransactionType { earned, spent, bonus, refund }

class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final String description;
  final String? counterpartName;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.description,
    this.counterpartName,
    required this.createdAt,
  });

  bool get isCredit => type == TransactionType.earned || type == TransactionType.bonus || type == TransactionType.refund;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'amount': amount,
    'description': description,
    'counterpartName': counterpartName,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: (json['id'] as String?) ?? '',
    type: TransactionType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => TransactionType.earned,
    ),
    amount: (json['amount'] as num?)?.toDouble() ?? 0,
    description: (json['description'] as String?) ?? '',
    counterpartName: json['counterpartName'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );
}

// ─── Booking / Swap Model ──────────────────────────────────────
enum SwapStatus { pending, confirmed, inProgress, completed, cancelled, disputed }

class Booking {
  final String id;
  final String requesterId;
  final String providerId;
  final String requesterName;
  final String providerName;
  final String? requesterAvatar;
  final String? providerAvatar;
  final Skill skill;
  final SwapStatus status;
  final DateTime scheduledAt;
  final int durationMinutes;
  final double creditsAmount;
  final String? notes;
  final DateTime createdAt;
  final double? requesterRating;
  final double? providerRating;

  const Booking({
    required this.id,
    required this.requesterId,
    required this.providerId,
    required this.requesterName,
    required this.providerName,
    this.requesterAvatar,
    this.providerAvatar,
    required this.skill,
    required this.status,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.creditsAmount,
    this.notes,
    required this.createdAt,
    this.requesterRating,
    this.providerRating,
  });

  String get statusLabel {
    switch (status) {
      case SwapStatus.pending: return 'Pending';
      case SwapStatus.confirmed: return 'Confirmed';
      case SwapStatus.inProgress: return 'In Progress';
      case SwapStatus.completed: return 'Completed';
      case SwapStatus.cancelled: return 'Cancelled';
      case SwapStatus.disputed: return 'Disputed';
    }
  }

  Color get statusColor {
    switch (status) {
      case SwapStatus.pending: return const Color(0xFFF59E0B);
      case SwapStatus.confirmed: return const Color(0xFF3B82F6);
      case SwapStatus.inProgress: return const Color(0xFF7C3AED);
      case SwapStatus.completed: return const Color(0xFF10B981);
      case SwapStatus.cancelled: return const Color(0xFF6B7280);
      case SwapStatus.disputed: return const Color(0xFFEF4444);
    }
  }

  Booking copyWith({SwapStatus? status}) => Booking(
    id: id, requesterId: requesterId, providerId: providerId,
    requesterName: requesterName, providerName: providerName,
    requesterAvatar: requesterAvatar, providerAvatar: providerAvatar,
    skill: skill, status: status ?? this.status,
    scheduledAt: scheduledAt, durationMinutes: durationMinutes,
    creditsAmount: creditsAmount, notes: notes, createdAt: createdAt,
    requesterRating: requesterRating, providerRating: providerRating,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'requesterId': requesterId,
    'providerId': providerId,
    'requesterName': requesterName,
    'providerName': providerName,
    'requesterAvatar': requesterAvatar,
    'providerAvatar': providerAvatar,
    'skill': skill.toJson(),
    'status': status.name,
    'scheduledAt': scheduledAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'creditsAmount': creditsAmount,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
    'requesterRating': requesterRating,
    'providerRating': providerRating,
  };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
    id: (json['id'] as String?) ?? '',
    requesterId: (json['requesterId'] as String?) ?? '',
    providerId: (json['providerId'] as String?) ?? '',
    requesterName: (json['requesterName'] as String?) ?? '',
    providerName: (json['providerName'] as String?) ?? '',
    requesterAvatar: json['requesterAvatar'] as String?,
    providerAvatar: json['providerAvatar'] as String?,
    skill: Skill.fromJson(json['skill'] as Map<String, dynamic>? ?? {}),
    status: SwapStatus.values.firstWhere(
      (s) => s.name == json['status'],
      orElse: () => SwapStatus.pending,
    ),
    scheduledAt: json['scheduledAt'] != null
        ? DateTime.tryParse(json['scheduledAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    durationMinutes: (json['durationMinutes'] as int?) ?? 60,
    creditsAmount: (json['creditsAmount'] as num?)?.toDouble() ?? 1.0,
    notes: json['notes'] as String?,
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    requesterRating: (json['requesterRating'] as num?)?.toDouble(),
    providerRating: (json['providerRating'] as num?)?.toDouble(),
  );
}

// ─── Message Model ─────────────────────────────────────────────
class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool isRead;
  final MessageType type;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    this.isRead = false,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'text': text,
    'sentAt': sentAt.toIso8601String(),
    'isRead': isRead,
    'type': type.name,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: (json['id'] as String?) ?? '',
    senderId: (json['senderId'] as String?) ?? '',
    text: (json['text'] as String?) ?? '',
    sentAt: json['sentAt'] != null
        ? DateTime.tryParse(json['sentAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    isRead: json['isRead'] as bool? ?? false,
    type: MessageType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => MessageType.text,
    ),
  );
}

enum MessageType { text, swapRequest, swapConfirmed }

class Conversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final bool otherUserOnline;
  final String lastMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final List<ChatMessage> messages;

  const Conversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    this.otherUserOnline = false,
    required this.lastMessage,
    required this.lastMessageAt,
    this.unreadCount = 0,
    required this.messages,
  });

  Conversation copyWith({
    List<ChatMessage>? messages,
    String? lastMessage,
    DateTime? lastMessageAt,
    int? unreadCount,
    bool? otherUserOnline,
  }) {
    return Conversation(
      id: id,
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      otherUserAvatar: otherUserAvatar,
      otherUserOnline: otherUserOnline ?? this.otherUserOnline,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
      messages: messages ?? this.messages,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'otherUserId': otherUserId,
    'otherUserName': otherUserName,
    'otherUserAvatar': otherUserAvatar,
    'otherUserOnline': otherUserOnline,
    'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt.toIso8601String(),
    'unreadCount': unreadCount,
  };

  factory Conversation.fromJson(Map<String, dynamic> json, {List<ChatMessage> messages = const []}) => Conversation(
    id: (json['id'] as String?) ?? '',
    otherUserId: (json['otherUserId'] as String?) ?? '',
    otherUserName: (json['otherUserName'] as String?) ?? '',
    otherUserAvatar: json['otherUserAvatar'] as String?,
    otherUserOnline: json['otherUserOnline'] as bool? ?? false,
    lastMessage: (json['lastMessage'] as String?) ?? '',
    lastMessageAt: json['lastMessageAt'] != null
        ? DateTime.tryParse(json['lastMessageAt'] as String) ?? DateTime.now()
        : DateTime.now(),
    unreadCount: (json['unreadCount'] as int?) ?? 0,
    messages: messages,
  );
}

// ─── Review Model ──────────────────────────────────────────────
class Review {
  final String id;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final Skill skill;

  const Review({
    required this.id,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.skill,
  });
}

// ─── Dispute Model ─────────────────────────────────────────────
enum DisputeStatus { open, underReview, resolved, closed }
enum DisputeReason { noShow, poorQuality, wrongSkill, paymentIssue, other }

class Dispute {
  final String id;
  final String bookingId;
  final String complainantId;
  final String complainantName;
  final String? complainantAvatar;
  final String respondentName;
  final DisputeReason reason;
  final DisputeStatus status;
  final String description;
  final DateTime createdAt;
  final String? resolution;
  final double? refundAmount;

  const Dispute({
    required this.id,
    required this.bookingId,
    required this.complainantId,
    required this.complainantName,
    this.complainantAvatar,
    required this.respondentName,
    required this.reason,
    required this.status,
    required this.description,
    required this.createdAt,
    this.resolution,
    this.refundAmount,
  });

  String get reasonLabel {
    switch (reason) {
      case DisputeReason.noShow: return 'No Show';
      case DisputeReason.poorQuality: return 'Poor Quality';
      case DisputeReason.wrongSkill: return 'Wrong Skill Level';
      case DisputeReason.paymentIssue: return 'Payment Issue';
      case DisputeReason.other: return 'Other';
    }
  }

  String get statusLabel {
    switch (status) {
      case DisputeStatus.open: return 'Open';
      case DisputeStatus.underReview: return 'Under Review';
      case DisputeStatus.resolved: return 'Resolved';
      case DisputeStatus.closed: return 'Closed';
    }
  }

  Color get statusColor {
    switch (status) {
      case DisputeStatus.open: return const Color(0xFFEF4444);
      case DisputeStatus.underReview: return const Color(0xFFF59E0B);
      case DisputeStatus.resolved: return const Color(0xFF10B981);
      case DisputeStatus.closed: return const Color(0xFF6B7280);
    }
  }
}

// ─── Match Model ───────────────────────────────────────────────
class SkillMatch {
  final UserModel user;
  final Skill theyOffer;
  final Skill youNeed;
  final double matchScore; // 0.0 to 1.0
  final List<String> matchReasons;
  final double distanceKm;

  const SkillMatch({
    required this.user,
    required this.theyOffer,
    required this.youNeed,
    required this.matchScore,
    required this.matchReasons,
    required this.distanceKm,
  });

  String get scoreLabel {
    if (matchScore >= 0.9) return 'Perfect Match';
    if (matchScore >= 0.75) return 'Great Match';
    if (matchScore >= 0.6) return 'Good Match';
    return 'Possible Match';
  }

  Color get scoreColor {
    if (matchScore >= 0.9) return const Color(0xFF10B981);
    if (matchScore >= 0.75) return const Color(0xFF3B82F6);
    if (matchScore >= 0.6) return const Color(0xFF7C3AED);
    return const Color(0xFF6B7280);
  }
}
