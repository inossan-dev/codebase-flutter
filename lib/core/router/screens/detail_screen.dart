import 'package:flutter/material.dart';

/// Placeholder d'écran de détail paramétré.
///
/// À remplacer par votre implémentation métier.
class DetailScreen extends StatelessWidget {
  const DetailScreen({required this.id, super.key});
  final String id;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text('Detail: $id')),
        body: Center(child: Text('Contenu pour l\'élément $id')),
      );
}
