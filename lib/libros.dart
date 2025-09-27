// Modelo de datos que representa un libro en la aplicación
class Libro {
  int? id; // ID único del libro (puede ser null para libros nuevos)
  String tituloLibro; // Título del libro

  // Constructor para crear instancias de Libro
  Libro({this.id, required this.tituloLibro});

  // Convierte el objeto Libro a un Map para guardar en la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tituloLibro': tituloLibro,
    };
  }
}
