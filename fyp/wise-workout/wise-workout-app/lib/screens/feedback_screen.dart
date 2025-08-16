import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/feedback_service.dart';
import 'give_feedback.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);
  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  double rating = 0.0;
  int ratingCount = 0;
  List<Map<String, dynamic>> reviews = [];
  List<String> pros = [];
  List<String> cons = [];
  List<double> stats = [0, 0, 0, 0, 0];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadReviews();
  }

  Future<void> loadReviews() async {
    try {
      final data = await FeedbackService().fetchPublishedFeedback();
      List<String> allPros = [];
      List<String> allCons = [];

      reviews = data.map((e) {
        final ratingVal = (e['rating'] ?? 0);
        final liked = (e['liked_features'] is List)
            ? List<String>.from(e['liked_features'])
            : <String>[];
        final problems = (e['problems'] is List)
            ? List<String>.from(e['problems'])
            : <String>[];

        allPros.addAll(liked);
        allCons.addAll(problems);

        return {
          'author': e['username'] != null
              ? '${e['username']}${e['firstName'] != null ? ' (${e['firstName']})' : ''}'
              : tr('feedback_user'),
          'date': _formatDate(e['created_at']),
          'rating': ratingVal is int
              ? ratingVal
              : (ratingVal is double
                  ? ratingVal.toInt()
                  : int.tryParse(ratingVal.toString()) ?? 0),
          'comment': (e['message'] ?? '').toString(),
          'liked_features': liked,
          'problems': problems,
        };
      }).toList();

      if (reviews.isNotEmpty) {
        ratingCount = reviews.length;
        rating = reviews.fold<double>(
              0.0,
              (sum, e) => sum + ((e['rating'] ?? 0) as int),
            ) /
            reviews.length;

        List<int> starCounts = List.generate(5, (i) => 0);
        for (final r in reviews) {
          final stars = r['rating'] ?? 0;
          if (stars is int && stars > 0 && stars <= 5) {
            starCounts[5 - stars]++;
          }
        }

        if (starCounts.fold<int>(0, (a, b) => a + b) > 0) {
          stats = starCounts.map((e) => e / reviews.length).toList();
        }

        final prosCount = <String, int>{};
        for (var p in allPros) {
          prosCount[p] = (prosCount[p] ?? 0) + 1;
        }
        final sortedPros = prosCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        pros = sortedPros.take(3).map((entry) => entry.key).toList();

        final consCount = <String, int>{};
        for (var c in allCons) {
          consCount[c] = (consCount[c] ?? 0) + 1;
        }
        final sortedCons = consCount.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        cons = sortedCons.take(1).map((entry) => entry.key).toList();
      }
    } catch (e, stack) {
      debugPrint('Error loading reviews: $e\n$stack');
    }
    setState(() {
      loading = false;
    });
  }

  String _formatDate(dynamic dt) {
    if (dt == null) return '';
    final d = DateTime.tryParse(dt.toString());
    if (d == null) return '';
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return tr('feedback_today');
    if (diff == 1) return tr('feedback_yesterday');
    return tr('feedback_days_ago', args: ['$diff']);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 16),
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, size: 24, color: colorScheme.onBackground),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: Text(
                        tr('feedback_title'),
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        rating.toStringAsFixed(2),
                        style: textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          5,
                          (i) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Icon(
                              i < rating.floor()
                                  ? Icons.star
                                  : i < rating
                                      ? Icons.star_half
                                      : Icons.star_border,
                              color: const Color(0xFFF5C542),
                              size: 34,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Center(
                      child: Text(
                        tr('feedback_based_on', args: ['$ratingCount']),
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildRatingBars(context),
                    const SizedBox(height: 18),
                    Text(
                      tr('feedback_pros_title'),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: pros
                          .map((pro) => Chip(
                                label: Text(
                                  pro,
                                  style: textTheme.labelLarge
                                      ?.copyWith(color: colorScheme.onSurface),
                                ),
                                side: BorderSide(color: colorScheme.primary),
                                backgroundColor: Colors.transparent,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      tr('feedback_cons_title'),
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: cons
                          .map((con) => Chip(
                                label: Text(
                                  con,
                                  style: textTheme.labelLarge
                                      ?.copyWith(color: colorScheme.onSurface),
                                ),
                                side: BorderSide(color: colorScheme.primary),
                                backgroundColor: Colors.transparent,
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          tr('feedback_reviews', args: ['$ratingCount']),
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            foregroundColor: colorScheme.onSecondary,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const GiveFeedbackScreen()),
                            ).then((_) => loadReviews());
                          },
                          child: Text(
                            tr('feedback_give'),
                            style: textTheme.labelLarge
                                ?.copyWith(color: colorScheme.onSecondary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                      reviews.isEmpty
                          ? Center(
                              child: Text(
                                tr('feedback_none'),
                                style: textTheme.bodyMedium,
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: reviews.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 12),
                              itemBuilder: (context, i) {
                                final review = reviews[i];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colorScheme.outline.withOpacity(0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            review["author"],
                                            style: textTheme.titleSmall?.copyWith(
                                              fontWeight: FontWeight.w700,
                                              color: colorScheme.onSurface,
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            review["date"],
                                            style: textTheme.bodySmall?.copyWith(
                                              color: colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (star) => Icon(
                                            star < review["rating"]
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: const Color(0xFFF5C542),
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      if ((review["comment"] as String).isNotEmpty)
                                        Text(
                                          review["comment"],
                                          style: textTheme.bodyMedium
                                              ?.copyWith(color: colorScheme.onSurface),
                                        ),
                                      if ((review["liked_features"] as List).isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Wrap(
                                            spacing: 8,
                                            children: (review["liked_features"] as List)
                                                .map<Widget>((feature) => Chip(
                                                      label: Text(
                                                        feature,
                                                        style: textTheme.bodySmall?.copyWith(
                                                          color: colorScheme.onSurface,
                                                        ),
                                                      ),
                                                      backgroundColor: colorScheme.primary
                                                          .withOpacity(0.09),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                      if ((review["problems"] as List).isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Wrap(
                                            spacing: 8,
                                            children: (review["problems"] as List)
                                                .map<Widget>((problem) => Chip(
                                                      label: Text(
                                                        problem,
                                                        style: textTheme.bodySmall?.copyWith(
                                                          color: colorScheme.onSurface,
                                                        ),
                                                      ),
                                                      backgroundColor: colorScheme.error
                                                          .withOpacity(0.09),
                                                    ))
                                                .toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildRatingBars(BuildContext context) {
    final labels = [
      tr('feedback_5stars'),
      tr('feedback_4stars'),
      tr('feedback_3stars'),
      tr('feedback_2stars'),
      tr('feedback_1star'),
    ];
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: List.generate(5, (i) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: [
              SizedBox(
                width: 68,
                child: Text(labels[i],
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    )),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 11,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: colorScheme.outline.withOpacity(0.18),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: stats[i],
                      child: Container(
                        height: 11,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}