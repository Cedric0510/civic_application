import 'package:url_launcher/url_launcher.dart';

Future<void> launchPhoneCall(String phone) =>
    launchUrl(Uri(scheme: 'tel', path: phone));

Future<void> launchEmail(String email) =>
    launchUrl(Uri(scheme: 'mailto', path: email));
