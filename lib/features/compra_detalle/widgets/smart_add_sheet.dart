import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:smart_spend_app/constants/app_colors.dart';
import 'package:smart_spend_app/features/compra_detalle/providers/compra_detalle_provider.dart';
import 'package:smart_spend_app/features/shared/services/gemini_service.dart';
import 'package:smart_spend_app/domain/models/compra_detalle_model.dart';

class SmartAddSheet extends ConsumerStatefulWidget {
  const SmartAddSheet({super.key});

  @override
  ConsumerState<SmartAddSheet> createState() => _SmartAddSheetState();
}

class _SmartAddSheetState extends ConsumerState<SmartAddSheet> {
  final GeminiService _geminiService = GeminiService();
  final ImagePicker _picker = ImagePicker();
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool _isProcessing = false;
  bool _isListening = false;
  String _statusText = "";

  Future<void> _processImage({bool fromGallery = false}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: fromGallery ? ImageSource.gallery : ImageSource.camera,
      );
      if (image == null) return;

      setState(() {
        _isProcessing = true;
        _statusText = "Analizando imagen...";
      });

      final File file = File(image.path);
      final result = await _geminiService.processImage(file);

      await _addItem(result);
    } catch (e) {
      _showError("Error al procesar imagen: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _statusText = "";
        });
      }
    }
  }

  Future<void> _processVoice() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        if (mounted) setState(() => _isListening = false);
        _showError("Error de voz: ${errorNotification.errorMsg}");
      },
    );

    if (available) {
      if (!mounted) return;
      setState(() {
        _isListening = true;
        _statusText = "Escuchando...";
      });
      _speech.listen(
        onResult: (result) async {
          if (result.finalResult) {
            if (!mounted) return;
            setState(() {
              _isListening = false;
              _isProcessing = true;
              _statusText = "Procesando: ${result.recognizedWords}";
            });

            final processed =
                await _geminiService.processText(result.recognizedWords);
            if (!mounted) return;
            await _addItem(processed);

            if (mounted) {
              setState(() {
                _isProcessing = false;
                _statusText = "";
              });
            }
          }
        },
        localeId: "es_ES", // Force Spanish if possible, or detect
      );
    } else {
      _showError("El reconocimiento de voz no está disponible.");
    }
  }

  Future<void> _addItem(Map<String, dynamic> data) async {
    final String nombre = data['nombre'] ?? 'Desconocido';
    final double precio = data['precio'] ?? 0.0;

    if (nombre == 'Error de lectura' ||
        nombre == 'Error al procesar imagen' ||
        nombre == 'Error al procesar texto') {
      _showError("No se pudo identificar el producto.");
      return;
    }

    final compraState = ref.read(compraDetalleProvider);
    final detalle = CompraDetalleModel(
      nombre: nombre,
      precio: precio,
      compraId: compraState.compraId,
      fecha: DateTime.now(),
    );

    await ref.read(compraDetalleProvider.notifier).addDetalle(detalle);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Agregado: $nombre - S/ $precio")),
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error500),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Agregar Producto Inteligente",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          if (_isProcessing || _isListening)
            Column(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(_statusText, textAlign: TextAlign.center),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildOption(
                  icon: Icons.camera_alt,
                  label: "Cámara",
                  onTap: _processImage,
                  color: AppColors.primary500,
                ),
                _buildOption(
                  icon: Icons.mic,
                  label: "Voz",
                  onTap: _processVoice,
                  color: AppColors.blueGray500,
                ),
                _buildOption(
                  icon: Icons.photo_library,
                  label: "Galería",
                  onTap: () => _processImage(fromGallery: true),
                  color: AppColors.primary700,
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 40, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
