import 'package:flutter/material.dart';
import 'package:smart_spend_app/constants/app_colors.dart';

class ComprasDetalleRowSkeleton extends StatelessWidget {
  const ComprasDetalleRowSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Skeleton para el nombre
              Expanded(
                child: Container(
                  height: 20.0,
                  color: AppColors.gray200,
                ),
              ),
              const SizedBox(width: 8.0),
              // Skeleton para el precio
              Container(
                width: 80.0,
                height: 20.0,
                color: AppColors.gray200,
              ),
              const SizedBox(width: 8.0),
              // Skeleton para el icono de cierre
              Container(
                width: 20.0,
                height: 20.0,
                color: AppColors.gray200,
              ),
            ],
          ),
          const SizedBox(height: 4.0),
          // Skeleton para la fecha
          Container(
            width: 100.0,
            height: 16.0,
            color: AppColors.gray200,
          ),
        ],
      ),
    );
  }
}
