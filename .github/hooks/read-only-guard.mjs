#!/usr/bin/env node
// PreToolUse guard: the Shopizer checkout in <project>/shopizer is read-only for the agent.
//
// Claude Code passes the tool call as JSON on stdin. Exit 0 allows it; exit 2 blocks it and the message on stderr
// goes back to the agent. File tools are checked by path (exact). Bash is checked by a pattern heuristic, so it is a
// second layer on top of the permission deny rules in settings.json, not a sandbox. Anything that can write through
// a tool we do not recognise is out of scope; the lab says so in the runbook.
import { resolve, sep } from 'node:path';

// Tool names are compared in lower case. Claude Code: Edit, Write, MultiEdit, NotebookEdit, Bash, PowerShell.
// GitHub Copilot CLI names are not verified by the build; the likely ones are listed too (edit, create, bash, powershell ...).
const FILE_TOOLS = new Set(['edit', 'write', 'multiedit', 'notebookedit', 'create', 'str_replace', 'str_replace_editor', 'insert', 'apply_patch']);
const SHELL_TOOLS = new Set(['bash', 'powershell', 'shell', 'execute']);
const MSG = 'Blocked: shopizer/ is read-only in this lab. Write your output to reports/ instead.';

const norm = (p) => p.split(sep).join('/').replace(/\/+$/, '').toLowerCase();

// Mutating commands for bash and PowerShell, and git subcommands that change the working tree or the index.
const MUTATING = new RegExp(
  '(^|\\s)(rm|rmdir|mv|cp|del|erase|touch|mkdir|chmod|chown|ln|tee|truncate|dd|install|patch|' +
    'remove-item|move-item|copy-item|set-content|add-content|out-file|new-item|rename-item|clear-content|ri|mi|ni|sc|ac)(\\s|$)' +
    '|(^|\\s)(sed|perl)\\s+(-\\w*i|--in-place)' +
    '|(^|\\s)git\\s+(-C\\s+\\S+\\s+)?(add|commit|checkout|switch|reset|clean|restore|apply|am|merge|rebase|cherry-pick|revert|stash|pull|rm|mv|tag|worktree|update-ref|gc|prune)\\b' +
    // branch: listing flags (-a, -r, -v, --list, --contains) stay allowed; create, delete, move, copy, force are refused
    '|(^|\\s)git\\s+(-C\\s+\\S+\\s+)?branch\\s+((?!-)\\S|-\\w*[dDmMcCfF]|--(delete|move|copy|force|set-upstream-to|unset-upstream|edit-description))',
  'i',
);
const REDIRECT_INTO_SHOPIZER = />>?\s*["']?[^\s"'|;&<>]*shopizer/i;
const CD = /^\s*(cd|pushd|set-location|sl)\s+["']?([^\s"';&|]+)/i;

export function decide(input, projectDir) {
  const protectedDir = norm(resolve(projectDir, 'shopizer'));
  const inside = (p) => {
    const n = norm(resolve(projectDir, p));
    return n === protectedDir || n.startsWith(protectedDir + '/');
  };
  // Claude Code and Copilot (PascalCase) send tool_name and tool_input; Copilot (camelCase) sends toolName and toolArgs.
  const tool = String(input.tool_name || input.toolName || '').toLowerCase();
  let args = input.tool_input ?? input.toolArgs ?? {};
  if (typeof args === 'string') {
    try { args = JSON.parse(args); } catch { args = { command: args }; }
  }
  args = args || {};

  if (FILE_TOOLS.has(tool)) {
    const target = args.file_path || args.notebook_path || args.path || args.filePath || '';
    if (target) return inside(target) ? MSG : null;
    // a patch or an edit with no path field: refuse if it names the protected folder anywhere
    return /shopizer(\/|\\\\)/i.test(JSON.stringify(args)) ? MSG : null;
  }
  if (SHELL_TOOLS.has(tool)) {
    const command = String(args.command || '');
    if (REDIRECT_INTO_SHOPIZER.test(command)) return MSG;
    let cwdInside = false; // true after a `cd` into shopizer/ earlier in the same command
    for (const segment of command.split(/&&|\|\||;|\||\r?\n/)) {
      const cd = segment.match(CD);
      if (cd) cwdInside = inside(cd[2]);
      const touches = cwdInside || /shopizer/i.test(segment);
      if (touches && MUTATING.test(segment)) return MSG;
    }
  }
  return null;
}

// Run as a hook only when executed directly, so tests can import decide().
if (process.argv[1]?.endsWith('read-only-guard.mjs')) {
  let raw = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', (c) => (raw += c));
  process.stdin.on('end', () => {
    let input;
    try {
      input = JSON.parse(raw);
    } catch {
      console.error('read-only-guard: could not parse hook input, blocking to be safe.');
      process.exit(2);
    }
    const projectDir = process.env.CLAUDE_PROJECT_DIR || input.cwd || process.cwd();
    const reason = decide(input, projectDir);
    if (reason) {
      console.error(reason);
      process.exit(2);
    }
    process.exit(0);
  });
}
