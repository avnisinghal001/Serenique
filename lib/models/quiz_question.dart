class QuizQuestion {
  final int id;
  final String question;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'options': options.map((option) => option.toMap()).toList(),
    };
  }
}

class QuizOption {
  final String letter;
  final String text;

  QuizOption({required this.letter, required this.text});

  Map<String, dynamic> toMap() {
    return {'letter': letter, 'text': text};
  }
}
