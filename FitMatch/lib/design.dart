import 'package:flutter/material.dart';

import 'poll.dart';

const ink = Color(0xFF2C2127);
const muted = Color(0xFF685E62);
const canvas = Color(0xFFF9F6F1);
const paper = Color(0xFFFFFDFA);
const border = Color(0xFFE4DDD6);
const plum = Color(0xFF472B43);
const blush = Color(0xFFF1E4ED);
const rose = Color(0xFFF5CFBF);
const green = Color(0xFFDCEADF);
const greenInk = Color(0xFF315442);

ThemeData fitMatchTheme() {
  final theme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: plum).copyWith(
      primary: plum,
      onPrimary: Colors.white,
      surface: paper,
      onSurface: ink,
      outlineVariant: border,
    ),
    fontFamily: 'DM Sans',
  );
  return theme.copyWith(
    scaffoldBackgroundColor: canvas,
    textTheme: theme.textTheme.apply(bodyColor: ink, displayColor: ink),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: plum,
        elevation: 0,
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 19, vertical: 14),
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: plum,
        side: const BorderSide(color: border),
        textStyle: const TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minimumSize: const Size(0, 46),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: paper,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.all(18),
    ),
    snackBarTheme: const SnackBarThemeData(backgroundColor: plum),
  );
}

class Brand extends StatelessWidget {
  const Brand({super.key});

  @override
  Widget build(BuildContext context) => const Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconTile(Icons.auto_awesome, fill: rose, size: 36),
      SizedBox(width: 9),
      Text(
        'FitMatch',
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 23,
          letterSpacing: -1.25,
        ),
      ),
    ],
  );
}

class IconTile extends StatelessWidget {
  const IconTile(this.icon, {super.key, this.fill = blush, this.size = 42});

  final IconData icon;
  final Color fill;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(11),
    ),
    child: Icon(icon, size: size * .49, color: plum),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading({
    super.key,
    required this.label,
    required this.title,
    required this.description,
    this.trailing,
  });

  final String label;
  final String title;
  final String description;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final wide = constraints.maxWidth >= 655;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.15,
              color: plum,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Playfair Display',
              fontWeight: FontWeight.w500,
              fontSize: wide ? 60 : 42,
              letterSpacing: wide ? -2.7 : -1.65,
              height: 1.07,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: BodyCopy(description, size: 15)),
              if (wide && trailing != null) trailing!,
            ],
          ),
          if (!wide && trailing != null) ...[
            const SizedBox(height: 14),
            trailing!,
          ],
        ],
      );
    },
  );
}

class BodyCopy extends StatelessWidget {
  const BodyCopy(this.text, {super.key, this.size = 14});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(fontSize: size, color: muted, height: 1.48),
  );
}

class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(21),
    this.fill = paper,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color fill;

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: fill,
      border: Border.all(color: border),
      borderRadius: BorderRadius.circular(18),
    ),
    child: child,
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(
    this.text, {
    super.key,
    this.fill = blush,
    this.color = plum,
  });

  final String text;
  final Color fill;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
    decoration: BoxDecoration(
      color: fill,
      borderRadius: BorderRadius.circular(30),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

class FriendAvatar extends StatelessWidget {
  const FriendAvatar(this.friend, {super.key});

  final Friend friend;

  @override
  Widget build(BuildContext context) => CircleAvatar(
    backgroundColor: friend == Friend.maya ? rose : green,
    foregroundColor: ink,
    radius: 19,
    child: Text(
      friend.initials,
      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
    ),
  );
}

class LookCard extends StatelessWidget {
  const LookCard({
    super.key,
    required this.outfit,
    this.votes,
    this.selected = false,
    this.onTap,
  });

  final Outfit outfit;
  final int? votes;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: paper,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(
        color: selected ? plum : border,
        width: selected ? 2 : 1,
      ),
    ),
    clipBehavior: Clip.antiAlias,
    child: Semantics(
      button: onTap != null,
      selected: onTap == null ? null : selected,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.86,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRect(
                    child: FractionallySizedBox(
                      widthFactor: 2,
                      alignment: outfit == Outfit.tailored
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      child: Image.asset(
                        'assets/outfits.webp',
                        fit: BoxFit.cover,
                        alignment: const Alignment(0, -.1),
                        excludeFromSemantics: true,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: StatusPill(outfit.tag, fill: paper, color: ink),
                  ),
                  if (onTap != null)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: selected ? plum : paper,
                        foregroundColor: selected ? Colors.white : plum,
                        child: Icon(
                          selected ? Icons.check : Icons.circle_outlined,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    outfit.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  BodyCopy(outfit.description, size: 12),
                  if (votes != null && votes! > 0) ...[
                    const SizedBox(height: 7),
                    StatusPill(
                      '$votes ${votes == 1 ? 'vote' : 'votes'}',
                      fill: green,
                      color: greenInk,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class Looks extends StatelessWidget {
  const Looks({super.key, this.controller, this.selected, this.onSelected});

  final PollController? controller;
  final Outfit? selected;
  final ValueChanged<Outfit>? onSelected;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final outfit in Outfit.values) ...[
        if (outfit != Outfit.values.first) const SizedBox(width: 13),
        Expanded(
          child: LookCard(
            outfit: outfit,
            votes: controller?.votesFor(outfit),
            selected: selected == outfit,
            onTap: onSelected == null ? null : () => onSelected!(outfit),
          ),
        ),
      ],
    ],
  );
}
