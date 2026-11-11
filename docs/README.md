# RECONX Documentation

This directory documents the local RECONX distribution and its supported
operating workflow.

- [Architecture](ARCHITECTURE.md): components, data flow, persistence, and LLM
  routing.
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
