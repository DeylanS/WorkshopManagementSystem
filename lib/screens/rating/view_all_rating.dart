import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';

class ViewAllRatingPage extends StatefulWidget {
  const ViewAllRatingPage({super.key});

  @override
  State<ViewAllRatingPage> createState() => _ViewAllRatingPageState();
}

class _ViewAllRatingPageState extends State<ViewAllRatingPage> {
  late Future<void> _fetchRatingsFuture;

  @override
  void initState() {
    super.initState();
    _fetchRatingsFuture =
        Provider.of<RatingProvider>(context, listen: false).fetchRatings();
  }

  @override
  Widget build(BuildContext context) {
    final ratingProvider = Provider.of<RatingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('All Ratings')),
      body: FutureBuilder(
        future: _fetchRatingsFuture,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading ratings: ${snapshot.error}'),
            );
          }

          if (ratingProvider.ratings.isEmpty) {
            return const Center(child: Text('No ratings found.'));
          }

          return ListView.builder(
            itemCount: ratingProvider.ratings.length,
            itemBuilder: (ctx, i) {
              final r = ratingProvider.ratings[i];
              return ListTile(
                title: Text('⭐ ${r.stars} - ${r.comment}'),
                subtitle: Text('Foreman: ${r.foremanId}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () async {
                    await ratingProvider.deleteRating(r.ratingId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Rating deleted')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
