import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../settings_store.dart';
import '../theme.dart';

typedef _LabPreset = ({String name, String html, String css, String js});

const List<_LabPreset> _presets = [
  (
    name: 'Starter page',
    html: '''
<h1>Hello from Jovexa Learn</h1>
<p>Edit this page, then press Run to see your changes.</p>
<button id="greet">Say hello</button>
<p id="message"></p>
''',
    css: '''
body {
  font-family: sans-serif;
  margin: 24px;
  color: #1f2937;
}
h1 {
  color: #2563eb;
}
button {
  background: #2563eb;
  color: #ffffff;
  border: none;
  padding: 10px 18px;
  border-radius: 8px;
  font-size: 16px;
}
''',
    js: '''
var button = document.getElementById('greet');
var message = document.getElementById('message');
button.addEventListener('click', function () {
  message.textContent = 'You clicked the button. JavaScript works!';
});
''',
  ),
  (
    name: 'Flexbox cards',
    html: '''
<h1>Team plans</h1>
<div class="row">
  <div class="card">
    <h2>Basic</h2>
    <p>Everything you need to get started.</p>
  </div>
  <div class="card">
    <h2>Pro</h2>
    <p>Extra tools for daily builders.</p>
  </div>
  <div class="card">
    <h2>Team</h2>
    <p>Shared workspaces for small groups.</p>
  </div>
</div>
''',
    css: '''
body {
  font-family: sans-serif;
  margin: 20px;
}
.row {
  display: flex;
  gap: 12px;
}
.card {
  flex: 1;
  background: #eff6ff;
  border: 1px solid #bfdbfe;
  border-radius: 10px;
  padding: 12px;
}
.card h2 {
  margin: 0 0 6px;
  font-size: 18px;
  color: #1d4ed8;
}
.card p {
  margin: 0;
  font-size: 14px;
  color: #334155;
}
''',
    js: '''
// Try changing the gap value in the CSS panel, then press Run again.
console.log('Flexbox demo ready');
''',
  ),
  (
    name: 'Counter',
    html: '''
<h1>Tap counter</h1>
<p id="count" class="count">0</p>
<button id="add">Add one</button>
''',
    css: '''
body {
  font-family: sans-serif;
  text-align: center;
  margin-top: 48px;
}
.count {
  font-size: 48px;
  font-weight: bold;
  color: #0891b2;
  margin: 12px 0;
}
button {
  background: #0891b2;
  color: #ffffff;
  border: none;
  padding: 10px 20px;
  border-radius: 8px;
  font-size: 16px;
}
''',
    js: '''
var count = 0;
var label = document.getElementById('count');
document.getElementById('add').addEventListener('click', function () {
  count = count + 1;
  label.textContent = String(count);
});
''',
  ),
];

enum _LabView { editor, preview }

/// The Code Lab: an offline HTML, CSS, and JavaScript sandbox rendered in a
/// local WebView. All navigation is blocked so nothing external can load.
class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  final TextEditingController _htmlController = TextEditingController();
  final TextEditingController _cssController = TextEditingController();
  final TextEditingController _jsController = TextEditingController();
  late final WebViewController _webController;

  int _presetIndex = 0;
  _LabView _view = _LabView.editor;
  bool _hasRun = false;

  @override
  void initState() {
    super.initState();
    _webController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) => NavigationDecision.prevent,
        ),
      );
    _applyPreset(0);
  }

  @override
  void dispose() {
    _htmlController.dispose();
    _cssController.dispose();
    _jsController.dispose();
    super.dispose();
  }

  void _applyPreset(int index) {
    _presetIndex = index;
    _htmlController.text = _presets[index].html;
    _cssController.text = _presets[index].css;
    _jsController.text = _presets[index].js;
  }

  String _composeDocument() =>
      '<!DOCTYPE html><html><head>'
      '<meta name="viewport" content="width=device-width, initial-scale=1">'
      '<style>${_cssController.text}</style></head>'
      '<body>${_htmlController.text}'
      '<script>${_jsController.text}</script></body></html>';

  void _run() {
    _webController.loadHtmlString(_composeDocument());
    setState(() {
      _hasRun = true;
      _view = _LabView.preview;
    });
  }

  void _copyDocument() {
    Clipboard.setData(ClipboardData(text: _composeDocument()));
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Document copied to clipboard'),
          duration: Duration(seconds: 1),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Code Lab'),
        actions: [
          PopupMenuButton<int>(
            tooltip: 'Load a preset',
            icon: const Icon(Icons.auto_awesome_mosaic_outlined),
            onSelected: (index) => setState(() => _applyPreset(index)),
            itemBuilder: (context) => [
              for (var i = 0; i < _presets.length; i++)
                PopupMenuItem(value: i, child: Text(_presets[i].name)),
            ],
          ),
          IconButton(
            tooltip: 'Copy document',
            icon: const Icon(Icons.copy_rounded),
            onPressed: _copyDocument,
          ),
          IconButton(
            tooltip: 'Reset to preset',
            icon: const Icon(Icons.restart_alt_rounded),
            onPressed: () => setState(() => _applyPreset(_presetIndex)),
          ),
        ],
      ),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SettingsStore.instance,
          builder: (context, _) => Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: [
                SegmentedButton<_LabView>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: _LabView.editor,
                      label: Text('Editor'),
                      icon: Icon(Icons.edit_note_rounded),
                    ),
                    ButtonSegment(
                      value: _LabView.preview,
                      label: Text('Preview'),
                      icon: Icon(Icons.visibility_outlined),
                    ),
                  ],
                  selected: {_view},
                  onSelectionChanged: (selection) =>
                      setState(() => _view = selection.first),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _view == _LabView.editor
                      ? _buildEditor(context)
                      : _buildPreview(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(BuildContext context) {
    return ListView(
      children: [
        _EditorField(label: 'HTML', controller: _htmlController),
        const SizedBox(height: 12),
        _EditorField(label: 'CSS', controller: _cssController),
        const SizedBox(height: 12),
        _EditorField(label: 'JavaScript', controller: _jsController),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _run,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Run'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Expanded(
          child: _hasRun
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    color: Colors.white,
                    child: WebViewWidget(controller: _webController),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Nothing to preview yet',
                          style: textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Write some code in the editor and press Run to see it here.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: _run,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Run current code'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          'Runs locally on your device. HTML, CSS, and JavaScript only.',
          style: textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _EditorField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _EditorField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: scheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: 8,
          keyboardType: TextInputType.multiline,
          autocorrect: false,
          enableSuggestions: false,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: SettingsStore.instance.codeFontSize,
            height: 1.5,
            color: const Color(0xFFE2E8F0),
          ),
          decoration: const InputDecoration(
            filled: true,
            fillColor: JovexaTheme.codeBg,
          ),
        ),
      ],
    );
  }
}
