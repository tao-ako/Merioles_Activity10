# Firebase CRUD

A Flutter inventory list connected to Cloud Firestore in Firebase project
`notes-7152b`. Android, web, and Windows Firebase options are generated
in `lib/firebase_options.dart`; Android's native configuration is in
`android/app/google-services.json`.

Items are stored at `users/{uid}/items/{itemId}` with `name`, `quantity`,
`isFavorite`, and `createdAt` fields. The list listens to Firestore snapshots,
so changes appear without a manual refresh.

## Firestore access

In Firebase project `notes-7152b`, the Cloud Firestore API and `(default)`
database must be created before the app can connect.

Email/Password and Google authentication are available from the
`Login_Merioles` screen. A signed-in user can access only their own
`users/{uid}/items` collection.

The Firestore rules allow the optional `image_url` item field. Deploy rule
changes to the configured project with:
`firebase deploy --only firestore:rules`.

## Cloudinary image uploads

Image upload uses the unsigned `cloudinary_public` flow with Cloudinary cloud
`jhytwdsk` and unsigned preset `DariBadi`. Do not put a Cloudinary API secret in
the Flutter app. Keep the preset restricted to the asset types and upload
limits the app requires.

The Android gallery picker uses the system photo picker; Android does not
require broad media/storage permissions for this flow. The manifest already
declares internet access.

Run `flutter pub get` and `flutter run` after configuring Cloudinary and
deploying Firestore rules.
