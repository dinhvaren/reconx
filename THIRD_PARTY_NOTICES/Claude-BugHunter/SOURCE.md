# Claude-BugHunter

Source: <https://github.com/elementalsouls/Claude-BugHunter>

Pinned commit: `d5dcc5347675ed431488e0a0e46749e4918aa194`

Author and attribution: Sachin Sharma / ElementalSoul and contributors.

RECONX includes the bundle's 83 skill directories from `skills/`. Skill content,
methodology, wordlists, and documentation are licensed under CC BY 4.0. Python
helpers are licensed under MIT. The complete upstream license texts are kept
beside this notice as `LICENSE` and `LICENSE-CONTENT`; upstream additional notes
are retained in `NOTICE`.

Installation scope:

- Included: the complete upstream `skills/` tree, including references and
  helper scripts shipped inside individual skills.
- Excluded: Claude slash commands, the `engine/`, `cbh` CLI, repository install
  scripts, GitHub workflows, Burp MCP wiring, and generated research assets.
- `apk-redteam-pipeline` already existed in RECONX and is byte-identical to the
  pinned upstream version, so it was not overwritten.
- No upstream installer, helper script, or command was executed during
  installation.

Static audit result:

- 83/83 upstream skill directories contain a `SKILL.md` with valid frontmatter.
- Upstream names are unique and match their directory names.
- No symlinks or hardcoded credentials were found.
- The three Python helpers only read local files, perform a public HackerOne
  GraphQL query, or run the bundled HackerOne helper with a fixed executable.
- The bundle contains offensive-security payload examples by design. These are
  documentation for authorized testing and are not executed automatically.

A local check confirmed all 105 upstream skill files match the pinned source by
SHA-256.
