import 'package:civic_app/shared/widgets/section_title.dart';
import 'package:civic_app/core/theme/feature_colors.dart';
import 'package:civic_app/shared/widgets/feature_app_bar.dart';
import 'package:civic_app/features/reports/presentation/controllers/my_reports_controller.dart';
import 'package:civic_app/features/reports/presentation/widgets/report_card.dart';
import 'package:civic_app/features/reports/presentation/widgets/report_form.dart';
import 'package:civic_app/shared/widgets/error_retry_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myReportsAsync = ref.watch(myReportsControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myReportsControllerProvider),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            FeatureAppBar(
              title: 'Signalements',
              color: FeatureColors.reports,
              backPath: '/home',
            ),
            const SliverToBoxAdapter(
              child: Padding(padding: EdgeInsets.all(20), child: ReportForm()),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SectionTitle('Mes signalements'),
              ),
            ),
            myReportsAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(
                    child: CircularProgressIndicator(
                      semanticsLabel: 'Chargement en cours',
                    ),
                  ),
                ),
              ),
              error: (error, stackTrace) => SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: ErrorRetryWidget(
                    message: 'Impossible de charger vos signalements.',
                    onRetry: () => ref.invalidate(myReportsControllerProvider),
                  ),
                ),
              ),
              data: (reports) => reports.isEmpty
                  ? SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 24,
                        ),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: Colors.grey.shade300,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Aucun signalement pour le moment.',
                                style: TextStyle(color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      sliver: SliverList.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) =>
                            ReportCard(report: reports[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
