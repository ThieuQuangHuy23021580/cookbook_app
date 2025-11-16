class AIChatSource {
  final String title;
  final int id;
  AIChatSource({required this.title, required this.id});
  factory AIChatSource.fromJson(Map<String, dynamic> json) {
    return AIChatSource(title: json['title'] as String, id: json['id'] as int);
  }
  Map<String, dynamic> toJson() {
    return {'title': title, 'id': id};
  }
}

class AIChatResponse {
  final String answer;
  final List<AIChatSource> sources;
  AIChatResponse({required this.answer, required this.sources});
  factory AIChatResponse.fromJson(Map<String, dynamic> json) {
    return AIChatResponse(
      answer: json['answer'] as String,
      sources:
          (json['sources'] as List<dynamic>?)
              ?.map(
                (source) =>
                    AIChatSource.fromJson(source as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'answer': answer,
      'sources': sources.map((source) => source.toJson()).toList(),
    };
  }
}
