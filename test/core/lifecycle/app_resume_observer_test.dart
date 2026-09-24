import 'package:civic_app/core/lifecycle/app_resume_observer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'calls onResume when the app comes back to the foreground, and only then',
    (tester) async {
      var resumes = 0;
      await tester.pumpWidget(
        AppResumeObserver(
          onResume: () => resumes++,
          child: const Directionality(
            textDirection: TextDirection.ltr,
            child: SizedBox(),
          ),
        ),
      );

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      expect(resumes, 0);

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      expect(resumes, 1);
    },
  );

  testWidgets('stops listening once removed from the tree', (tester) async {
    var resumes = 0;
    await tester.pumpWidget(
      AppResumeObserver(onResume: () => resumes++, child: const SizedBox()),
    );
    await tester.pumpWidget(const SizedBox());

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    expect(resumes, 0);
  });
}
