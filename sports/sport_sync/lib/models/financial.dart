enum TransactionType {
  sponsorship,
  grant,
  stipend,
  expense,
  other
}

enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled
}

class Financial {
  final String id;
  final String userId;
  final List<Sponsorship> sponsorships;
  final List<Grant> grants;
  final List<Transaction> transactions;
  final Map<String, double> summary;
  final DateTime lastUpdated;

  Financial({
    required this.id,
    required this.userId,
    this.sponsorships = const [],
    this.grants = const [],
    this.transactions = const [],
    this.summary = const {},
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  factory Financial.fromJson(Map<String, dynamic> json) {
    return Financial(
      id: json['id'] as String,
      userId: json['userId'] as String,
      sponsorships: (json['sponsorships'] as List?)
          ?.map((e) => Sponsorship.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      grants: (json['grants'] as List?)
          ?.map((e) => Grant.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      transactions: (json['transactions'] as List?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      summary: Map<String, double>.from(json['summary'] as Map? ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'sponsorships': sponsorships.map((e) => e.toJson()).toList(),
      'grants': grants.map((e) => e.toJson()).toList(),
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'summary': summary,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // Helper methods
  double get totalIncome {
    return transactions
        .where((t) => t.amount > 0)
        .fold(0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return transactions
        .where((t) => t.amount < 0)
        .fold(0, (sum, t) => sum + t.amount.abs());
  }

  double get balance => totalIncome - totalExpenses;

  List<Sponsorship> get activeSponshorships =>
      sponsorships.where((s) => s.isActive).toList();

  List<Grant> get activeGrants =>
      grants.where((g) => g.isActive).toList();
}

class Sponsorship {
  final String id;
  final String sponsorName;
  final String description;
  final double amount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final List<String> terms;
  final Map<String, dynamic>? contractDetails;

  Sponsorship({
    required this.id,
    required this.sponsorName,
    required this.description,
    required this.amount,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.terms = const [],
    this.contractDetails,
  });

  factory Sponsorship.fromJson(Map<String, dynamic> json) {
    return Sponsorship(
      id: json['id'] as String,
      sponsorName: json['sponsorName'] as String,
      description: json['description'] as String,
      amount: json['amount'] as double,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool? ?? true,
      terms: List<String>.from(json['terms'] ?? []),
      contractDetails: json['contractDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sponsorName': sponsorName,
      'description': description,
      'amount': amount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'terms': terms,
      'contractDetails': contractDetails,
    };
  }

  bool get isExpired => endDate.isBefore(DateTime.now());
  
  double get remainingDuration {
    final now = DateTime.now();
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays.toDouble();
  }
}

class Grant {
  final String id;
  final String name;
  final String provider;
  final String description;
  final double amount;
  final DateTime applicationDate;
  final DateTime? approvalDate;
  final DateTime? disbursementDate;
  final bool isActive;
  final List<String> requirements;
  final Map<String, dynamic>? additionalDetails;

  Grant({
    required this.id,
    required this.name,
    required this.provider,
    required this.description,
    required this.amount,
    required this.applicationDate,
    this.approvalDate,
    this.disbursementDate,
    this.isActive = true,
    this.requirements = const [],
    this.additionalDetails,
  });

  factory Grant.fromJson(Map<String, dynamic> json) {
    return Grant(
      id: json['id'] as String,
      name: json['name'] as String,
      provider: json['provider'] as String,
      description: json['description'] as String,
      amount: json['amount'] as double,
      applicationDate: DateTime.parse(json['applicationDate'] as String),
      approvalDate: json['approvalDate'] != null
          ? DateTime.parse(json['approvalDate'] as String)
          : null,
      disbursementDate: json['disbursementDate'] != null
          ? DateTime.parse(json['disbursementDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      requirements: List<String>.from(json['requirements'] ?? []),
      additionalDetails: json['additionalDetails'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'description': description,
      'amount': amount,
      'applicationDate': applicationDate.toIso8601String(),
      'approvalDate': approvalDate?.toIso8601String(),
      'disbursementDate': disbursementDate?.toIso8601String(),
      'isActive': isActive,
      'requirements': requirements,
      'additionalDetails': additionalDetails,
    };
  }

  bool get isPending => approvalDate == null;
  bool get isDisbursed => disbursementDate != null;
}

class Transaction {
  final String id;
  final double amount;
  final String description;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime date;
  final String? category;
  final Map<String, dynamic>? metadata;

  Transaction({
    required this.id,
    required this.amount,
    required this.description,
    required this.type,
    required this.status,
    required this.date,
    this.category,
    this.metadata,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      amount: json['amount'] as double,
      description: json['description'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      date: DateTime.parse(json['date'] as String),
      category: json['category'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'description': description,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'date': date.toIso8601String(),
      'category': category,
      'metadata': metadata,
    };
  }

  bool get isIncome => amount > 0;
  bool get isExpense => amount < 0;
  bool get isPending => status == TransactionStatus.pending;
}