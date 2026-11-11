# Changelog

This changelog starts with the local RECONX distribution. Upstream project
history remains available from the original open-source repository.

## [2026-11-11] - Local release

### Changed

- Rebranded the user-visible application from V-ARTEX to RECONX while
  retaining required copyright, attribution, and AGPL-3.0 licensing.
- Replaced the inherited product, planning, and feature documentation with a
  RECONX-specific documentation set.
- Updated local LLM profiles to the 9Router OpenAI-compatible gateway and
  exact `ocg/` model identifiers.
- Kept legacy internal package paths, environment-variable names, database
  identifiers, and persisted keys where changing them could break upgrades.

### Added

- Local Docker image target `reconx:local`.
- Loopback-only Compose runtime with pinned base and PostgreSQL images.
- Reproducible source-build instructions for the static frontend, embedded Go
  binary, and Docker image.
- A complete interface gallery with core workflows, task sessions, exploration
  graphs, findings, system configuration, dark mode, and responsive mobile
  views.
- The complete 83-skill Claude-BugHunter collection pinned at
  `d5dcc5347675ed431488e0a0e46749e4918aa194`, with source and license notices.
- Operations, architecture, security, and development documentation.

### Security

- Local source and artifact audit found no confirmed match for the reported
  CAPTCHA command-execution backdoor indicators.
- Runtime Compose configuration does not consume a prebuilt V-ARTEX image.
- API keys remain in ignored local configuration or the existing profile
  secret store and are not embedded in documentation or images.
