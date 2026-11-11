# RECONX Documentation

This directory documents the local RECONX distribution and its supported
operating workflow.

## Application screenshots

The core workflow views use the built-in Acme demo dataset; the login and
current 9Router profile views come from the live local deployment. No personal
assessment data is exposed.

| Login | Dashboard |
| :---: | :---: |
| ![Login](images/login.png) | ![Dashboard](images/demo/dashboard.png) |

| Agent chat | Exploration graph |
| :---: | :---: |
| ![Agent chat](images/demo/chat-conversation.png) | ![Exploration graph](images/demo/task-graph.png) |

| Findings | LLM profiles |
| :---: | :---: |
| ![Findings](images/demo/findings.png) | ![LLM profiles](images/llm.png) |

See the [complete interface gallery](GALLERY.md) for the full screen tour,
including desktop, dark mode, and mobile views.

## Guides

- [Architecture](ARCHITECTURE.md): components, data flow, persistence, and LLM
  routing.
- [Interface gallery](GALLERY.md): complete application screenshot tour.
- [Operations](OPERATIONS.md): build, start, health checks, backups, logs, and
  troubleshooting.
- [Security](SECURITY.md): trust boundaries, secret handling, supply-chain
  controls, and residual risk.
- [Development](DEVELOPMENT.md): repository layout, build/test loop, and
  compatibility identifiers.
- [Security and build report](../SECURITY_BUILD_REPORT.md): current audit,
  image, runtime, and verification evidence.

Documentation conventions:

- Examples target PowerShell on Windows unless a section says otherwise.
- `D:\RECONX` is the project root used by the local deployment.
- Do not place real credentials in documentation, examples, screenshots, or
  committed configuration.
- Keep compatibility notes explicit when an internal name retains a legacy
  identifier.
