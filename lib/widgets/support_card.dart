import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/tokens.dart';
import '../theme/typography.dart';
import 'buttons.dart';
import 'sheet.dart';

/// Shown as a deck card when energy or mood has been low for several days in
/// a row. Kind, short, never alarming, and easy to set aside.
class SupportCard extends StatelessWidget {
  const SupportCard({super.key, required this.onDismiss});
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final c = context.c;
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(Radii.big),
        border: Border.all(color: c.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite_rounded, size: 15, color: c.text),
              const SizedBox(width: 6),
              Text('A QUICK CHECK ON YOU', style: T.label(c.textDim)),
            ],
          ),
          const SizedBox(height: Space.l),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('You\'ve been running low for a few days.', style: T.h1(c.text)),
                  const SizedBox(height: Space.m),
                  Text(
                    'That happens to everyone, and it\'s worth looking after. Talking to someone you trust, '
                    'or to a doctor or other health professional, can genuinely help.',
                    style: T.body(c.textDim),
                  ),
                  const SizedBox(height: Space.m),
                  Text('Today, only the essentials. Nothing else is owed.', style: T.bodyStrong(c.text)),
                ],
              ),
            ),
          ),
          const SizedBox(height: Space.m),
          PrimaryButton(label: 'See support options', height: 54, onTap: () => showSupportSheet(context)),
          const SizedBox(height: 6),
          Center(
            child: TextButton(
              onPressed: onDismiss,
              child: Text('Not today', style: T.small(c.textDim)),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> showSupportSheet(BuildContext context) => showExeSheet<void>(
  context,
  builder: (ctx) {
    final c = ctx.c;
    Widget item(IconData i, String title, String body, {VoidCallback? onTap}) => Padding(
      padding: const EdgeInsets.only(bottom: Space.m),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface2,
            borderRadius: BorderRadius.circular(Radii.card),
            border: Border.all(color: c.border, width: 0.8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(i, size: 20, color: c.accentInk),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: T.bodyStrong(c.text)),
                    const SizedBox(height: 2),
                    Text(body, style: T.small(c.textDim)),
                  ],
                ),
              ),
              if (onTap != null) Icon(Icons.open_in_new_rounded, size: 16, color: c.textDim),
            ],
          ),
        ),
      ),
    );
    return SheetBody(
      title: 'Support options',
      subtitle: 'Small steps count. Pick whichever feels doable.',
      children: [
        item(
          Icons.people_alt_rounded,
          'Talk to someone you trust',
          'A friend, family member or mentor. Even a short message: "Rough week, can we talk?"',
        ),
        item(
          Icons.medical_services_rounded,
          'See a doctor or health professional',
          'Low energy and mood that hang around are worth a check-up. It is a normal thing to ask for.',
        ),
        item(
          Icons.support_agent_rounded,
          'Find a free, confidential helpline',
          'Trained people to talk to, in your country. Opens findahelpline.com.',
          onTap: () =>
              launchUrl(Uri.parse('https://findahelpline.com'), mode: LaunchMode.externalApplication),
        ),
        item(
          Icons.emergency_rounded,
          'If you feel unsafe right now',
          'Call your local emergency number, or go to the nearest emergency department.',
        ),
      ],
    );
  },
);
