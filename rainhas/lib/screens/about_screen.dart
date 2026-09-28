import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app_info.dart';
import '../widgets/board_3d.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre')),
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
              snap.hasData ? 'Versão ${snap.data!.version}' : '',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Desenvolvido por'),
                  subtitle: Text(AppInfo.developerName),
                ),
                if (AppInfo.developerEmail.isNotEmpty)
                  ListTile(
                    leading: const Icon(Icons.email_outlined),
                    title: const Text('Contato'),
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
                    title: const Text('Política de privacidade'),
                    onTap: () => launchUrl(
                      Uri.parse(AppInfo.privacyPolicyUrl),
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ListTile(
                  leading: const Icon(Icons.description_outlined),
                  title: const Text('Licenças de software'),
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
            'Inspirado no problema das oito rainhas, proposto em 1848 por Max '
            'Bezzel, e no passeio do cavalo, estudado por Euler.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
