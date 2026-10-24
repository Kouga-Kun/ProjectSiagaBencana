import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:siagabencana_flutter/app/widgets/siaga_components.dart';
import 'package:siagabencana_flutter/features/profile/presentation/profile_page.dart';

void main() {
  testWidgets('emergency contacts use content width without warning panel', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ProfilePage(onOpenSection: (_) {})),
      ),
    );
    await tester.pumpAndSettle();

    final title = find.text('Kontak darurat pada website sumber');
    final card = find.ancestor(of: title, matching: find.byType(SiagaCard));
    expect(tester.getSize(card.first).width, 940);

    await tester.tap(title);
    await tester.pumpAndSettle();

    expect(find.text('Periksa kembali nomor kontak'), findsNothing);
    expect(
      find.text(
        'Nomor berikut disalin dari halaman profil Laravel dan belum diverifikasi dalam tahap desain ini.',
      ),
      findsNothing,
    );
    expect(find.text('BPBD Kota Padang'), findsOneWidget);
    expect(find.text('0751-778775'), findsOneWidget);
    expect(find.text('SAR Kota Padang'), findsOneWidget);
    expect(find.text('0751-484534'), findsOneWidget);
    expect(find.text('Pemadam Kebakaran'), findsOneWidget);
    expect(find.text('113 / 0751-28558'), findsOneWidget);
    expect(find.text('PMI Padang'), findsOneWidget);
    expect(find.text('0751-31795'), findsOneWidget);
    expect(find.text('Polisi / Poltabes'), findsOneWidget);
    expect(find.text('110 / 0751-33724'), findsOneWidget);
    expect(find.text('RS M. Djamil Padang'), findsOneWidget);
    expect(find.text('0751-37030'), findsOneWidget);
  });
}
