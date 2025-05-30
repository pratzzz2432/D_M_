import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/language_provider.dart';

import 'package:d_m/services/translation_service.dart';



class TranslatableText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatableText(
      this.text, {
        Key? key,
        this.style,
        this.textAlign,
        this.maxLines,
        this.overflow,
      }) : super(key: key);

  @override
  State<TranslatableText> createState() => _TranslatableTextState();
}

class _TranslatableTextState extends State<TranslatableText> {
  String? _translatedText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _translateText();
  }

  Future<void> _translateText() async {
    final provider = Provider.of<LanguageProvider>(context, listen: false);
    final translated = await provider.translateText(widget.text);

    if (mounted) {
      setState(() {
        _translatedText = translated;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _translatedText ?? widget.text,
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
    );
  }

}
