import 'package:flutter/material.dart';
import 'package:app2/services/recommend_service.dart';

class LLMRecommendationPage extends StatefulWidget {
  final int score;
  LLMRecommendationPage({required this.score});
  @override
  State<LLMRecommendationPage> createState() => _RecommendationPageState();
}

class _RecommendationPageState extends State<LLMRecommendationPage> {
  final RecommendService _recommendService = RecommendService();
  String? _recommendation; // Variable para almacenar la recomendación de la IA
  bool _isLoading = false; // Spinner de carga
  String? _error; // Variable para almacenar errores de red o del servidor

  @override
  // Lanza automáticamente la petición al LLM  al iniciar la página
  void initState() {
    super.initState();
    _fetchRecommendation();
  }

  // LLamada a RecommendService y actualiza el estado de la página
  Future<void> _fetchRecommendation() async {
    setState(() {
      _isLoading = true; //activa el spinner de carga
      _error = null;
    });

    // Construir prompt dinámico según la puntuación
    // widget.score : // Puntuación total del cuestionario
    final prompt = StringBuffer()
      ..writeln(
          'He obtenido una puntuación total de ${widget.score} en el cuestionario que mide niveles de depresión, ansiedad y soledad.')
      ..writeln(
          'Por favor, proporciona recomendaciones personalizadas y prácticas para mejorar el bienestar emocional según este resultado. Sé conciso y empático.');

    try {
      final response = await _recommendService
          .sendMessage(prompt.toString()); // Envía el prompt al LLM
      setState(() {
        _recommendation =
            response; // Actualiza la recomendación con la respuesta del LLM
      });
    } catch (e) {
      setState(() {
        _error = 'Error al obtener la recomendación: \$e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recomendaciones de IA"),
        backgroundColor: Colors.black,
        titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primaryContainer),
      ),
      backgroundColor: const Color.fromARGB(255, 0, 15, 49),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(
          child: _isLoading //Cuando la petición está en curso
              ? const CircularProgressIndicator() // Spinner de carga
              : _error != null
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _fetchRecommendation,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aquí tienes tus recomendaciones:',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Text(
                              _recommendation ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchRecommendation,
                          child: const Text('Actualizar Recomendaciones'),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.deepPurple.shade200.withOpacity(0.8),
                          ),
                          child: Text(
                            'Volver',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
