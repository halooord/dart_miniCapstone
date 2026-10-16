import 'package:flutter/material.dart';
import '../services/nba_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ui.dart';

class CommunityScreen extends StatefulWidget {
  final bool active;
  const CommunityScreen({super.key, required this.active});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final service = NbaService();

  @override
  void dispose() {
    service.dispose();
    super.dispose();
  }

  List<NewsStory> stories = [];
  bool loading = false;
  bool showingSamples = false;
  String? error;
  DateTime? lastUpdated;

  @override
  void initState() {
    super.initState();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) loadNews();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CommunityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active && lastUpdated == null && !loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) loadNews();
      });
    }
  }

  Future<void> loadNews() async {
    setState(() {
      loading = true;
      showingSamples = false;
      error = null;
    });
    try {
      final latest = await service.fetchStories();
      if (!mounted) return;
      setState(() {
        stories = latest;
        lastUpdated = DateTime.now();
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        error =
            'Could not reach the NBA news feed. Check your internet and tap Retry.';
        loading = false;
        stories = [];
      });
    }
  }

  void useDemo() => setState(() {
        showingSamples = true;
        stories = NewsStory.sample;
        error = null;
      });

  void openArticle(NewsStory article) {
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
                title: Text(article.isSample ? 'TRAINING TIP' : 'NBA UPDATE')),
            body: SafeArea(
                child: ListView(padding: const EdgeInsets.all(24), children: [
              Kicker(article.isSample ? 'Offline example' : 'From live API'),
              const SizedBox(height: 14),
              Text(article.title,
                  style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 14),
              Text(article.source,
                  style: const TextStyle(color: AppColors.orange)),
              const SizedBox(height: 24),
              SurfaceCard(
                  child: Text(article.summary,
                      style: const TextStyle(
                          color: AppColors.text, fontSize: 16, height: 1.6))),
              const SizedBox(height: 14),
              const Text(
                  'Headlines and summaries are displayed for learning and inspiration.'),
            ])),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) => RefreshIndicator(
        color: AppColors.orange,
        onRefresh: loadNews,
        child: ListView.builder(
          key: const Key('community_list'),
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(22, 15, 22, 24),
          itemCount: 1 +
              (loading || error != null || stories.isEmpty
                  ? 1
                  : stories.length),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Kicker('Inspiration beyond the court'),
                  const SizedBox(height: 8),
                  Text('HOOP CULTURE',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 9),
                  const Text(
                      'Catch basketball headlines and bring that energy into your training.'),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(19),
                    decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            colors: [Color(0xFF57341E), Color(0xFF211A19)]),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFF754429))),
                    child: Row(children: [
                      const Icon(Icons.emoji_events_outlined,
                          color: AppColors.orange, size: 36),
                      const SizedBox(width: 14),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            const Kicker('Your challenge'),
                            const SizedBox(height: 5),
                            Text('Do 50 form shots today.',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            const Text('Repetition beats hesitation.',
                                style: TextStyle(fontSize: 12)),
                          ])),
                    ]),
                  ),
                  const SizedBox(height: 20),
                  Row(children: [
                    Expanded(
                        child: Text('Around the league',
                            style: Theme.of(context).textTheme.titleLarge)),
                    IconButton(
                        tooltip: 'Refresh news',
                        onPressed: loading ? null : loadNews,
                        icon: const Icon(Icons.refresh_rounded,
                            color: AppColors.orange)),
                  ]),
                  if (showingSamples)
                    const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: Text('OFFLINE DEMO CONTENT — NOT LIVE NEWS',
                            style: TextStyle(
                                color: AppColors.orange,
                                fontSize: 10,
                                letterSpacing: .9,
                                fontWeight: FontWeight.w800)))
                  else if (lastUpdated != null && error == null)
                    Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                            'Live API • Updated ${TimeOfDay.fromDateTime(lastUpdated!).format(context)}',
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.success))),
                  const SizedBox(height: 6),
                ],
              );
            }
            if (loading) {
              return const Padding(
                  padding: EdgeInsets.all(50),
                  child: Center(
                      child: Column(children: [
                    CircularProgressIndicator(color: AppColors.orange),
                    SizedBox(height: 18),
                    Text('Fetching NBA headlines...'),
                  ])));
            }
            if (error != null) {
              return EmptyPanel(
                icon: Icons.wifi_off_rounded,
                title: 'Connection unavailable',
                details: error!,
                action: Column(children: [
                  SizedBox(
                      width: 185,
                      child: PrimaryAction(
                          label: 'Retry live API',
                          icon: Icons.refresh_rounded,
                          onPressed: loadNews)),
                  TextButton(
                      onPressed: useDemo,
                      child: const Text('View offline training tips')),
                ]),
              );
            }
            if (stories.isEmpty) {
              return EmptyPanel(
                icon: Icons.newspaper_outlined,
                title: 'No headlines right now',
                details:
                    'The API returned an empty list. You can refresh or view sample tips.',
                action: TextButton(
                    onPressed: useDemo,
                    child: const Text('View offline training tips')),
              );
            }
            final story = stories[index - 1];
            return Padding(
              padding: const EdgeInsets.only(bottom: 11),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () => openArticle(story),
                child: SurfaceCard(
                    child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 50,
                        height: 54,
                        decoration: BoxDecoration(
                            color: AppColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(14)),
                        child: Icon(
                            story.isSample
                                ? Icons.tips_and_updates_outlined
                                : Icons.newspaper_outlined,
                            color: AppColors.orange,
                            size: 24)),
                    const SizedBox(width: 13),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Kicker(story.source, color: AppColors.orangeSoft),
                          const SizedBox(height: 5),
                          Text(story.title,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text(story.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.muted)),
                        ])),
                    const SizedBox(width: 4),
                    const Icon(Icons.chevron_right_rounded,
                        color: AppColors.muted, size: 18),
                  ],
                )),
              ),
            );
          },
        ),
      );
}
