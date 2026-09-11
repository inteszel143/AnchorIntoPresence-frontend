import 'dart:io';
import 'package:flutter/material.dart';
import '../../utils/urls.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({super.key, this.image, this.file, this.size = 96});
  final String? image;
  final File? file;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    Widget fallback() => ColoredBox(
        color: colors.surfaceContainerHighest,
        child: Icon(Icons.person_outline_rounded,
            size: size * .45, color: colors.onSurfaceVariant));
    final path = image;
    return ClipOval(
        child: SizedBox.square(
      dimension: size,
      child: file != null
          ? Image.file(file!,
              fit: BoxFit.cover, errorBuilder: (_, __, ___) => fallback())
          : path != null && path.isNotEmpty
              ? Image.network(
                  Uri.tryParse(path)?.hasScheme == true
                      ? path
                      : '${Urls.baseUrlimages}$path',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => fallback())
              : fallback(),
    ));
  }
}
