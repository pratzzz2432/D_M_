import 'package:flutter/material.dart';
import 'package:d_m/services/translation_service.dart';
import 'package:provider/provider.dart';
import 'package:d_m/providers/language_provider.dart'; // ✅ Adjust the path if needed



class LanguageSelectionDialog extends StatelessWidget {
  const LanguageSelectionDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Language'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: TranslationService.availableLanguages.length,
          itemBuilder: (context, index) {
            final language = TranslationService.availableLanguages[index];
            return ListTile(
              title: Row(
                children: [
                  Text(language.name), // Native script
                  const SizedBox(width: 8),
                  Text(
                    '(${language.englishName})', // English name
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              onTap: () async {
                final provider = Provider.of<LanguageProvider>(context, listen: false);
                await provider.changeLanguage(language.code);
                Navigator.pop(context);
              },

            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}