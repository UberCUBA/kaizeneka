class ModelsResponseModel {
  final List<AIModel> data;

  ModelsResponseModel({required this.data});

  factory ModelsResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      final dataList = json['data'];
      if (dataList is List) {
        return ModelsResponseModel(
          data: dataList
              .map((model) => AIModel.fromJson(model as Map<String, dynamic>))
              .toList(),
        );
      } else {
        print('Unexpected data format: $dataList');
        return ModelsResponseModel(data: []);
      }
    } catch (e) {
      print('Error parsing models response: $e');
      return ModelsResponseModel(data: []);
    }
  }
}

class AIModel {
  final String id;
  final String name;
  final String description;
  final Pricing pricing;
  final String contextLength;
  final dynamic architecture;

  AIModel({
    required this.id,
    required this.name,
    required this.description,
    required this.pricing,
    required this.contextLength,
    required this.architecture,
  });

  factory AIModel.fromJson(Map<String, dynamic> json) {
    return AIModel(
      id: json['id'] ?? '',
      name: json['name'] ?? json['id'] ?? '',
      description: json['description'] ?? '',
      pricing: Pricing.fromJson(json['pricing'] ?? {}),
      contextLength: json['context_length']?.toString() ?? '0',
      architecture: json['architecture'] ?? {},
    );
  }

  bool get isFree => pricing.prompt == '0' && pricing.completion == '0';
  bool get isPaid => !isFree;
}

class Pricing {
  final String prompt;
  final String completion;

  Pricing({
    required this.prompt,
    required this.completion,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    // Handle different pricing formats
    var prompt = '0';
    var completion = '0';

    if (json['prompt'] != null) {
      prompt = json['prompt'].toString();
    }
    if (json['completion'] != null) {
      completion = json['completion'].toString();
    }

    return Pricing(
      prompt: prompt,
      completion: completion,
    );
  }
}