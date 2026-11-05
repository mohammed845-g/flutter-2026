class Payments {
    String id;
    String dealId;
    String customerId;
    int amount;
    String paymentMethod;
    String paymentStatus;
    String transactionId;
    DateTime paidAt;
    DateTime createdAt;

    Payments({
        required this.id,
        required this.dealId,
        required this.customerId,
        required this.amount,
        required this.paymentMethod,
        required this.paymentStatus,
        required this.transactionId,
        required this.paidAt,
        required this.createdAt,
    });


factory Payments.fromJson(Map<String, dynamic> json) {
        return Payments(
            id: json['_id'],
            dealId: json['dealId'],
            customerId: json['customerId'],
            amount: json['amount'],
            paymentMethod: json['paymentMethod'],
            paymentStatus: json['paymentStatus'],
            transactionId: json['transactionId'],
            paidAt: DateTime.parse(json['paidAt']),
            createdAt: DateTime.parse(json['createdAt']),
        );
    }
    Map<String, dynamic> toJson() {
        return {
            '_id': id,
            'dealId': dealId,
            'customerId': customerId,
            'amount': amount,
            'paymentMethod': paymentMethod,
            'paymentStatus': paymentStatus,
            'transactionId': transactionId,
            'paidAt': paidAt.toIso8601String(),
            'createdAt': createdAt.toIso8601String(),
        };
    }
}
