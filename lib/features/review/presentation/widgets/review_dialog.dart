import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/theme_extension.dart';
import '../../../../shared/widgets/input_field.dart';

class ReviewDialog extends ConsumerStatefulWidget {
  final int? initialRating;
  final String? initialComment;
  final bool isEdit;

  const ReviewDialog({
    super.key,
    this.initialRating,
    this.initialComment,
    this.isEdit = false,
  });

  @override
  ConsumerState<ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends ConsumerState<ReviewDialog> {
  late int _rating;
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 5;
    _commentController = TextEditingController(text: widget.initialComment ?? '');
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.isEdit ? 'Modifier votre avis' : 'Donner votre avis',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      index < _rating ? Icons.star : Icons.star_border,
                      size: 40,
                      color: context.secondary,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            Text(
              'Commentaire',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            InputField(
              controller: _commentController,
              hint: 'Partagez votre expérience...',
              maxLines: 5,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'rating': _rating,
              'comment': _commentController.text.trim(),
            });
          },
          child: Text(widget.isEdit ? 'Modifier' : 'Publier'),
        ),
      ],
    );
  }
}
