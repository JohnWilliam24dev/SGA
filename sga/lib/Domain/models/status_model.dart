import 'package:flutter/foundation.dart' show immutable;

/// Em que fase do fluxo um [StatusModel] está. O servidor manda em
/// MAIÚSCULAS (`EM_ANDAMENTO`); aqui fica no padrão do Dart.
enum StatusTipo {
  inicial('INICIAL'),
  emAndamento('EM_ANDAMENTO'),
  concluido('CONCLUIDO'),
  cancelado('CANCELADO');

  const StatusTipo(this.valorApi);

  /// Texto exato que trafega na API.
  final String valorApi;

  /// Converte o texto da API; falha alto se vier um tipo desconhecido, para
  /// o contrato quebrado aparecer cedo.
  static StatusTipo fromApi(String valor) {
    return StatusTipo.values.firstWhere(
      (tipo) => tipo.valorApi == valor,
      orElse: () => throw FormatException('StatusTipo desconhecido: $valor'),
    );
  }
}

/// Uma coluna do fluxo de commissions (ex.: "Na fila", "Em andamento").
@immutable
class StatusModel {
  const StatusModel({
    required this.id,
    required this.nome,
    required this.ordem,
    required this.tipo,
  });

  factory StatusModel.fromJson(Map<String, dynamic> json) {
    return StatusModel(
      id: json['id'] as String,
      nome: json['nome'] as String,
      ordem: json['ordem'] as int,
      tipo: StatusTipo.fromApi(json['tipo'] as String),
    );
  }

  final String id;
  final String nome;
  final int ordem;
  final StatusTipo tipo;

  Map<String, dynamic> toJson() => {
        'id': id,
        'nome': nome,
        'ordem': ordem,
        'tipo': tipo.valorApi,
      };

  /// Cópia com outro nome, outra posição e/ou outro tipo.
  StatusModel copyWith({String? nome, int? ordem, StatusTipo? tipo}) {
    return StatusModel(
      id: id,
      nome: nome ?? this.nome,
      ordem: ordem ?? this.ordem,
      tipo: tipo ?? this.tipo,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is StatusModel &&
        other.id == id &&
        other.nome == nome &&
        other.ordem == ordem &&
        other.tipo == tipo;
  }

  @override
  int get hashCode => Object.hash(id, nome, ordem, tipo);

  @override
  String toString() => 'StatusModel($id, $nome, $tipo)';
}
