import 'package:flutter/material.dart';
import 'package:app2/services/recommend_service.dart';

class LLMRecommendationPage extends StatefulWidget {
  final int depressionScore;
  final int anxietyScore;
  final int stressScore;
  final String contextSummary; //a parir de graphics_page.dart

  LLMRecommendationPage({
    required this.depressionScore,
    required this.anxietyScore,
    required this.stressScore,
    this.contextSummary = '', //no es required
  });
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

    try {
      final ctx =
          widget.contextSummary.trim(); //Comprobar contexto previo si existe
      final response = await _recommendService.sendMessage(
        depressionScore: widget.depressionScore,
        anxietyScore: widget.anxietyScore,
        stressScore: widget.stressScore,
        message: [
          if (ctx.isNotEmpty) 'Context from my last sessions:\n$ctx\n',
          'Task: Generate practical recommendations based on my DASS-21 scores and decide whether each domain seems low/medium/high (or concerning). ',
          'Scoring note: each domain score ranges from 0 to 21 (higher = more intense).',
          '(depression=${widget.depressionScore}, anxiety=${widget.anxietyScore}, stress=${widget.stressScore}). '
              'Prioritize what matches the mood and flags if context is provided. '
              'Avoid clinical diagnosis.',
        ].join('\n'),
      ); // Envía el prompt al LLM
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
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          // Contenedor para el AppBar con fondo con imagen
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: AppBar(
            title: Text("AI Recommendations"),
            backgroundColor: Colors.transparent,
            titleTextStyle: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ),
      ),

      //backgroundColor: const Color.fromARGB(255, 0, 15, 49),
      body: SizedBox.expand(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/fondo1.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Padding(
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
                              'Here are your recommendations:',
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: _fetchRecommendation,
                                  child: const Text('Update Recommendations'),
                                ),
                                SizedBox(width: 20), // espacio entre botones
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.deepPurple.shade200
                                        .withOpacity(0.8),
                                  ),
                                  child: Text(
                                    'Back',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
            ),
          ),
        ),
      ),
    );
  }
}
