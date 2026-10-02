import { mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const packageRoot = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(packageRoot, '../..');
const tokens = JSON.parse(readFileSync(resolve(packageRoot, 'tokens.json'), 'utf8')) as {
  color: Record<string, { light: string; dark: string }>;
  radius: Record<string, number>;
  space: Record<string, number>;
  font: { family: string };
};

const decl = (name: string, value: string) => `  --${name}: ${value};`;
const colorVars = (mode: 'light' | 'dark') =>
  Object.entries(tokens.color).map(([name, value]) => decl(`color-${name}`, value[mode]));
const metricVars = (group: string, values: Record<string, number>) =>
  Object.entries(values).map(([name, value]) => decl(`${group}-${name}`, `${value}px`));
const camel = (group: string, name: string) =>
  group + name.slice(0, 1).toUpperCase() + name.slice(1);
const argb = (hex: string) => `Color(0xFF${hex.slice(1)})`;

const css = [
  '/* Generated from packages/design-tokens/tokens.json. Do not edit. */',
  ':root {',
  ...colorVars('light'),
  ...metricVars('radius', tokens.radius),
  ...metricVars('space', tokens.space),
  decl('font-family', `"${tokens.font.family}"`),
  '}',
  '',
  '.dark {',
  ...colorVars('dark'),
  '}',
  '',
].join('\n');

const dart = [
  '// Generated from packages/design-tokens/tokens.json. Do not edit.',
  "import 'dart:ui';",
  '',
  'abstract final class BridgeTokens {',
  ...Object.entries(tokens.color).flatMap(([name, value]) => [
    `  static const ${name} = ${argb(value.light)};`,
    `  static const ${name}Dark = ${argb(value.dark)};`,
  ]),
  ...Object.entries(tokens.radius).map(
    ([name, value]) => `  static const ${camel('radius', name)} = ${value};`,
  ),
  ...Object.entries(tokens.space).map(
    ([name, value]) => `  static const ${camel('space', name)} = ${value};`,
  ),
  `  static const fontFamily = '${tokens.font.family}';`,
  '}',
  '',
].join('\n');

for (const [path, contents] of [
  [resolve(packageRoot, 'dist/tokens.css'), css],
  [resolve(repoRoot, 'packages/bridgecabs_core/lib/theme/tokens.dart'), dart],
] as const) {
  mkdirSync(dirname(path), { recursive: true });
  writeFileSync(path, contents);
}
