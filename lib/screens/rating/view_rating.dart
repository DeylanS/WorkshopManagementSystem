import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/rating_provider.dart';

class ViewRatingPage extends StatefulWidget {
  const ViewRatingPage({super.key});

  @override
  State<ViewRatingPage> createState() => _ViewRatingPageState();
}

class _ViewRatingPageState extends State<ViewRatingPage> {
  late Future<void> _fetchMyRatingFuture;

  @override
  void initState() {
    super.initState();
    _fetchMyRatingFuture =
        Provider.of<RatingProvider>(context, listen: false).fetchUserRating();
  }

  @override
  Widget build(BuildContext context) {
    final ratingProvider = Provider.of<RatingProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('My Ratings')),
      body: FutureBuilder(
        future: _fetchMyRatingFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error loading ratings: ${snapshot.error}'),
            );
          }

          final myRatings = ratingProvider.userRating;
          final average =
              myRatings.isEmpty
                  ? 0
                  : myRatings.map((r) => r.stars).reduce((a, b) => a + b) /
                      myRatings.length;

          return Column(
            children: [
              const SizedBox(height: 20),
              Text(
                '⭐ Average Rating: ${average.toStringAsFixed(1)}',
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    myRatings.isEmpty
                        ? const Center(child: Text('No ratings found.'))
                        : ListView.builder(
                          itemCount: myRatings.length,
                          itemBuilder: (ctx, i) {
                            final r = myRatings[i];
                            return Card(
                              child: ListTile(
                                title: Text('⭐ ${r.stars} - ${r.comment}'),
                                subtitle: Text('Foreman: ${r.foremanId}'),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        },
      ),
    );
  }
}
