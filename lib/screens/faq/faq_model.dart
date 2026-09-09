/// Model for FAQ data response from API
class Faq {
  final String id;
  final String question;
  final String answer;
  final int status;

  Faq({
    required this.id,
    required this.question,
    required this.answer,
    required this.status,
  });

  factory Faq.fromJson(Map<String, dynamic> json) {
    return Faq(
      id: json['_id'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      status: json['status'] as int,
    );
  }
}
