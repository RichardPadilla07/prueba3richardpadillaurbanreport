import 'package:uuid/uuid.dart';

class Report {
    Report copyWith({
      String? id,
      String? usuarioId,
      String? titulo,
      String? descripcion,
      String? categoria,
      String? estado,
      double? latitud,
      double? longitud,
      String? fotoUrl,
      DateTime? createdAt,
    }) {
      return Report(
        id: id ?? this.id,
        usuarioId: usuarioId ?? this.usuarioId,
        titulo: titulo ?? this.titulo,
        descripcion: descripcion ?? this.descripcion,
        categoria: categoria ?? this.categoria,
        estado: estado ?? this.estado,
        latitud: latitud ?? this.latitud,
        longitud: longitud ?? this.longitud,
        fotoUrl: fotoUrl ?? this.fotoUrl,
        createdAt: createdAt ?? this.createdAt,
      );
    }
  final String id;
  final String usuarioId;
  final String titulo;
  final String descripcion;
  final String categoria;
  final String estado;
  final double latitud;
  final double longitud;
  final String fotoUrl;
  final DateTime createdAt;

  Report({
    required this.id,
    required this.usuarioId,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.estado,
    required this.latitud,
    required this.longitud,
    required this.fotoUrl,
    required this.createdAt,
  });

  factory Report.fromMap(Map<String, dynamic> map) {
    return Report(
      id: map['id'],
      usuarioId: map['usuario_id'],
      titulo: map['titulo'],
      descripcion: map['descripcion'],
      categoria: map['categoria'],
      estado: map['estado'],
      latitud: map['latitud'],
      longitud: map['longitud'],
      fotoUrl: map['foto_url'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'usuario_id': usuarioId,
      'titulo': titulo,
      'descripcion': descripcion,
      'categoria': categoria,
      'estado': estado,
      'latitud': latitud,
      'longitud': longitud,
      'foto_url': fotoUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }

  static Report empty(String usuarioId) => Report(
    id: const Uuid().v4(),
    usuarioId: usuarioId,
    titulo: '',
    descripcion: '',
    categoria: 'otro',
    estado: 'pendiente',
    latitud: 0,
    longitud: 0,
    fotoUrl: '',
    createdAt: DateTime.now(),
  );
}
