import 'package:flutter/material.dart';

class CustomLoader extends StatelessWidget {
  const CustomLoader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fondo semitransparente
        const Opacity(
          opacity: 0.5,
          child: ModalBarrier(
            dismissible: false,
            color: Colors.black,
          ),
        ),
        // Indicador de carga circular
        Center(
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Cargando...',
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
