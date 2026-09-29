import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_info.dart';
import '../l10n/l10n.dart';
import '../services/progress.dart';
import '../widgets/board_3d.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final l = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l.about)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: SpinningPiece(size: 120)),
          Text(
            AppInfo.appName,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snap) => Text(
              snap.hasData ? l.version(snap.data!.version) : '',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(l.developedBy),
                  subtitle: const Text(AppInfo.developerName),
                ),
                if (AppInfo.developerEmail.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: Text(l.contact),
                    subtitle: const Text(AppInfo.developerEmail),
                    onTap: () => launchUrl(
                      Uri(
                        scheme: 'mailto',
                        path: AppInfo.developerEmail,
                        query:
                            'subject=${Uri.encodeComponent(AppInfo.appName)}',
                      ),
                    ),
                  ),
                if (AppInfo.privacyPolicyUrl.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined),
                    title: Text(l.privacyPolicy),
                    onTap: () => launchUrl(
                      Uri.parse(AppInfo.privacyPolicyFor(l.localeName)),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l.language),
                  trailing: DropdownButton<String>(
                    value: appLanguage.value,
                    underline: const SizedBox.shrink(),
                    onChanged: (code) {
                      if (code == null) return;
                      Progress.instance.language = code;
                      appLanguage.value = code;
                    },
                    items: [
                      DropdownMenuItem(
                        value: '',
                        child: Text(l.languageSystem),
                      ),
                      for (final e in languageNames.entries)
                        DropdownMenuItem(value: e.key, child: Text(e.value)),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: Text(l.licenses),
                  onTap: () => showLicensePage(
                    context: context,
                    applicationName: AppInfo.appName,
                    applicationLegalese: '© ${AppInfo.developerName}',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l.aboutInspiration,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
