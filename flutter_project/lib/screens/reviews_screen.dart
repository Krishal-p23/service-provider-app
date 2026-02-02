import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final reviews = userProvider.userReviews;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
      ),
      body: reviews.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.rate_review_outlined,
                    size: 80,
                    color: theme.primaryColor.withValues(alpha:0.3),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No reviews yet',
                    style: theme.textTheme.displaySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your reviews will appear here',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 80),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Provider info
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: theme.primaryColor.withValues(alpha: 0.1),
                              child: Text(
                                review.providerName[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: theme.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review.providerName,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    review.category,
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            // Rating
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    review.rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.star,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Review text
                        Text(
                          review.reviewText,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),
                        
                        // Date
                        Text(
                          review.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}