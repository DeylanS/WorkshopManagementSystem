import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/rating.dart';
import '../../providers/rating_provider.dart';

class AddRatingPage extends StatefulWidget {
  const AddRatingPage({super.key});

  @override
  _AddRatingPageState createState() => _AddRatingPageState();
}

class _AddRatingPageState extends State<AddRatingPage> {
  int stars = 0;
  final _commentController = TextEditingController();
  final _foremanIdController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    _foremanIdController.dispose();
    super.dispose();
  }

  void _submitRating() {
    if (stars == 0 ||
        _commentController.text.isEmpty ||
        _foremanIdController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields and select a star rating'),
        ),
      );
      return;
    }

    final newRating = Rating(
      ratingId: '', // Firestore will generate this
      ownerId: 'owner123', // TODO: Replace with actual logged-in user ID
      foremanId: _foremanIdController.text,
      stars: stars,
      comment: _commentController.text,
    );

    Provider.of<RatingProvider>(context, listen: false).addRating(newRating);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Rating')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _foremanIdController,
              decoration: const InputDecoration(labelText: 'Foreman ID'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star,
                    color: stars > index ? Colors.amber : Colors.grey,
                    size: 36,
                  ),
                  onPressed: () => setState(() => stars = index + 1),
                );
              }),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Comment'),
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitRating,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
