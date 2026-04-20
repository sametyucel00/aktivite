import 'package:aktivite/app/app.dart';
import 'package:aktivite/core/config/repository_source.dart';
import 'package:aktivite/shared/providers/repository_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders app shell', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          repositorySourceProvider.overrideWith(
            (ref) => RepositorySource.inMemory,
          ),
        ],
        child: const AktiviteApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Basit bir planla başla'), findsWidgets);
  });
}
