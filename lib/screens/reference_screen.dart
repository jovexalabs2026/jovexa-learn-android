import 'package:flutter/material.dart';

import '../content_repository.dart';
import '../models.dart';
import '../widgets/code_block.dart';

/// Searchable, filterable reference of language features and syntax examples.
class ReferenceScreen extends StatefulWidget {
  const ReferenceScreen({super.key});

  @override
  State<ReferenceScreen> createState() => _ReferenceScreenState();
}

class _ReferenceScreenState extends State<ReferenceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String? _category;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ReferenceEntry> get _filtered {
    final q = _query.trim().toLowerCase();
    return [
      for (final entry in ContentRepository.instance.referenceEntries)
        if ((q.isEmpty ||
                entry.name.toLowerCase().contains(q) ||
                entry.description.toLowerCase().contains(q)) &&
            (_category == null || entry.category == _category))
          entry,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final entries = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Reference')),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded),
                  hintText: 'Search the reference',
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                  for (final category
                      in ContentRepository.instance.referenceCategories)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: entries.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No matches. Try a different term.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                      itemCount: entries.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReferenceCard(entry: entries[index]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceCard extends StatelessWidget {
  final ReferenceEntry entry;

  const _ReferenceCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.name,
              style: textTheme.titleMedium?.copyWith(
                fontFamily: 'monospace',
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              entry.category.toUpperCase(),
              style: TextStyle(
                fontSize: 10.5,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(entry.description, style: textTheme.bodyMedium),
            CodeBlock(code: entry.example),
          ],
        ),
      ),
    );
  }
}
