import 'dart:convert';

import 'package:crud_firebase_app/widgets/item_form_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets('requires an item name and quantity', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ItemFormDialog(onSave: (name, quantity) async {})),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter an item name.'), findsOneWidget);
    expect(find.text('Enter a quantity.'), findsOneWidget);
  });

  testWidgets('rejects a non-numeric quantity', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ItemFormDialog(onSave: (name, quantity) async {})),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Keyboard');
    await tester.enterText(find.byType(TextFormField).at(1), 'many');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid numeric quantity.'), findsOneWidget);
  });

  testWidgets('cancel closes add dialog without saving', (tester) async {
    var wasSaved = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => ItemFormDialog(
                    onSave: (name, quantity) async {
                      wasSaved = true;
                    },
                  ),
                );
              },
              child: const Text('Open Add'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Add'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Add Item'), findsNothing);
    expect(wasSaved, isFalse);
  });

  testWidgets('uploads selected image and passes its URL when saving', (
    tester,
  ) async {
    final image = XFile.fromData(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/lJoAAAAASUVORK5CYII=',
      ),
      name: 'item.png',
    );
    var uploaded = false;
    String? savedImageUrl;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => ItemFormDialog(
                    onSave: (name, quantity) async {},
                    onPickImage: () async => image,
                    onUploadImage: (selectedImage) async {
                      uploaded = true;
                      return 'https://res.cloudinary.com/demo/image/upload/item.png';
                    },
                    onSaveWithImage: (name, quantity, imageUrl) async {
                      savedImageUrl = imageUrl;
                    },
                  ),
                );
              },
              child: const Text('Open Add'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Add'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Item');
    await tester.enterText(find.byType(TextFormField).at(1), '2');
    await tester.tap(find.text('Choose image'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(uploaded, isTrue);
    expect(
      savedImageUrl,
      'https://res.cloudinary.com/demo/image/upload/item.png',
    );
  });
}
