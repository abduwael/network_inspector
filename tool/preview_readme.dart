// Preview README roughly like pub.dev (GFM + common extensions).
//
// From package root:
//   dart run tool/preview_readme.dart
//
// Then open the printed HTML path in your browser (double-click or drag into Chrome/Edge).

import 'dart:io';

import 'package:markdown/markdown.dart';

void main() {
  final root = Directory.current;
  final readme = File.fromUri(root.uri.resolve('README.md'));
  if (!readme.existsSync()) {
    stderr.writeln('Run from package root (README.md not found).');
    exitCode = 1;
    return;
  }

  var md = readme.readAsStringSync();

  // Optional: show local screenshot files when README uses relative doc/ paths.
  final rootPath = root.absolute.path.replaceAll('\\', '/');
  md = md.replaceAllMapped(RegExp(r'src="doc/([^"]+)"'), (m) {
    final rel = 'doc/${m[1]}';
    final abs = '$rootPath/$rel';
    final uri = Uri.file(abs);
    return 'src="${uri.toString()}"';
  });

  final html = markdownToHtml(
    md,
    extensionSet: ExtensionSet.gitHubFlavored,
  );

  final out = File.fromUri(root.uri.resolve('tool/readme_preview.html'));
  out.writeAsStringSync('''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>README preview (local)</title>
  <style>
    body { font-family: system-ui, -apple-system, Segoe UI, Roboto, sans-serif;
           line-height: 1.5; max-width: 920px; margin: 2rem auto; padding: 0 1rem;
           color: #212529; background: #fff; }
    pre, code { font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
                font-size: 0.9em; }
    pre { background: #f6f8fa; padding: 1rem; overflow: auto; border-radius: 6px; }
    code { background: #f6f8fa; padding: 0.15em 0.35em; border-radius: 4px; }
    pre code { background: none; padding: 0; }
    img { max-width: 100%; height: auto; vertical-align: middle; }
    table { border-collapse: collapse; width: 100%; }
    th, td { border: 1px solid #d0d7de; padding: 0.5rem; }
    blockquote { border-left: 4px solid #d0d7de; margin-left: 0; padding-left: 1rem; color: #57606a; }
    .note { background: #fff8c5; border: 1px solid #e0c040; padding: 0.75rem 1rem;
            border-radius: 6px; margin-bottom: 1.5rem; font-size: 0.95rem; }
  </style>
</head>
<body>
  <div class="note">
    <strong>Local preview only.</strong> pub.dev applies extra sanitization and styling;
    check the carousel separately (<code>pubspec.yaml</code> <code>screenshots</code>).
    Re-run this script after README edits.
  </div>
  <article class="markdown-body">
$html
  </article>
</body>
</html>
''');

  stdout.writeln('Wrote: ${out.absolute.path}');
  stdout.writeln('Open that file in a browser to preview.');
}
