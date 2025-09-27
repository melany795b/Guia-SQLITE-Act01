import 'package:flutter/material.dart';
import 'package:guia_05/database_helper.dart';
import 'libros.dart';


void main() {
  runApp(const MyApp()); // únto de entrada de la aplicación Flutter
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    // Configuración Principal de la aplicación MaterialApp  
    return MaterialApp(
      title: 'FLutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,),
      home: const MyHomePage(), // Pantalla inicial de la app
    );
  }
}


class MyHomePage extends StatefulWidget {
    const MyHomePage({super.key});


  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {
  // controlador del campo de texto donde escribiremos el título del libro
  final DatabaseHelper _dbHelper = DatabaseHelper();
  // Lista que almacena todos los libros que obtenemos de la base de datos
  final TextEditingController _EditTituloLibro = TextEditingController();
  // Instancia del helper para interactuar con la BD SQLite
  List<Libro> _items = [];
 
  @override
  void initState() {
    super.initState(); // Inicializa el estado para cargar libros
    _cargarListaLibros(); // Permite cargar los libros al iniciar la pantalla
  }


  // Método para cargar todos los libros de la BD
  Future<void> _cargarListaLibros() async {
    final items = await _dbHelper.getItems(); // Consulta a la BD
    setState(() {
      _items = items; // Permite actualizar la interfaz con nuevos datos
    });
  }


  // Agrega un nuevo libro a la base de datos
  void _agregarNuevoLibro(String tituloLibro) async {
    final nuevoLibro = Libro(tituloLibro: tituloLibro); // Crea objeto libro
    await _dbHelper.insertLibro(nuevoLibro);  // Inserta la BD
    print("SE AGREGÓ EL NUEVO LIBRO"); // Actualiza la lita después de agregar
    _cargarListaLibros();
  }


  // Muestra un diálogo para agregar un nuevo libro
  void _mostrarVentanaAgregar() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Título"),
          content: TextField(
            controller: _EditTituloLibro, // Campo de texto para ingresar Título
            decoration: const InputDecoration(hintText: "Ingrese el titulo"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_EditTituloLibro.text.isNotEmpty) {
                  _agregarNuevoLibro(_EditTituloLibro.text.toString());
                  Navigator.of(context).pop(); // Cierra el diálogo
                }
              },
              child: const Text("Agregar")
            )
          ],
        );
      }
    );
  }


  // Elimina un libro de la BD por su ID
  void _eliminarLibro(int id) async {
    await _dbHelper.eliminar('libros', where: 'id = ?', whereArgs: [id]);
    _cargarListaLibros(); // Actualiza la lista después de la eliminación
  }


  // Muestra tarjeta con dialogo de confirmación antes de eliminar un libro
  void _mostrarMensajeModificar(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirmar eliminación"),
          content: const Text("¿Estas seguro de que quieres eliminar este libro?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // "Cancelar eliminación"
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _eliminarLibro(id);
                Navigator.of(context).pop(); // "Confirmar eliminción"
              },
              child: const Text("Eliminar"),
            ),
          ],
        );
      },
    );
  }


  // Actualiza el título de un libro existente en la BD
  void _actualizarLibro(int id, String nuevoTitulo) async {
    // Controlador pre-llenado con el título actual del libro -------------------------------------------------------------------------------------------------------
    await _dbHelper.actualizar(
      'libros',
      {'tituloLibro': nuevoTitulo},
      where: 'id = ?',
      whereArgs: [id],
    );
    _cargarListaLibros();
  }


  void _ventanaEditar(int id, String tituloActual) {
    TextEditingController _tituloController = TextEditingController(text: tituloActual);


    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modificar Titulo del Libro"),
          content: TextField(
            controller: _tituloController, // Campo editable con título actual
            decoration: const InputDecoration(
              hintText: "Escribe el nuevo título",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancela la edición
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                if (_tituloController.text.isNotEmpty) {
                  _actualizarLibro(id, _tituloController.text.toString()); // Guarda los cambios
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Guardar"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    // Construye la interfaz principal de la app
    return Scaffold(
      appBar: AppBar(
        title: const Text("SqlLite Flutter"),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: ListView.separated(
        itemCount: _items.length, // # de elementos en lista
        separatorBuilder: (context, index) => const Divider(), // Línea divisoria entre ítems
        itemBuilder: (context, index) {
          final libro = _items[index]; // Libro actual en la iteración
          return ListTile(
            title: Text(libro.tituloLibro), // Muestra el tóitulo del libro
            subtitle: Text('ID: ${libro.id}'), // Muestra el ID del libro
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.grey),
              onPressed: () {
                _mostrarMensajeModificar(libro.id!); // Abre card con diálogo de eliminación
              },
            ),
            onTap: () {
              _ventanaEditar(libro.id!, libro.tituloLibro); // Abre card con diálogo de edición al hacer tap
            },
          );
        },
      ),
      // Botón flotante para agregar nuevos libros |+|
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarVentanaAgregar,
        child: const Icon(Icons.add),
      ),
    );
  }
}
