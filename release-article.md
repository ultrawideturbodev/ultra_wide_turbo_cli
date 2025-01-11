---
title: "Ultra Wide Turbo CLI 0.1.15: Enhanced Global Package Support"
tags: ["release", "cli", "dart", "developer-tools"]
excerpt: "Latest release brings improved global package handling, better error messages, and enhanced test coverage"
featured: false
status: "draft"
---

We're excited to announce the release of Ultra Wide Turbo CLI version 0.1.15! This release focuses on improving the global package experience and enhancing test coverage across the board.

## 🌟 What's New

### Global Package Support
The main highlight of this release is the improved handling of global packages. We've addressed several issues:

- Fixed the update service to correctly handle global package paths
- Added fallback path resolution for global packages
- Improved error messages when configuration files are missing

These changes make the CLI more robust when installed globally via `dart pub global activate`, ensuring a smoother experience for all users.

### Enhanced Testing
We've also made significant improvements to our test suite:

- Added comprehensive integration tests for tag source and clone workflows
- Expanded test coverage for multi-directory operations
- Fixed test setup to properly handle global package scenarios

## 🔍 Technical Details

The update service now intelligently handles path resolution, checking both local and global package directories for configuration files. This makes the CLI more resilient and provides clearer feedback when issues arise.

## 🚀 Getting Started

To update to the latest version, run:

```bash
dart pub global activate ultra_wide_turbo_cli
```

For new installations:

```bash
dart pub global activate ultra_wide_turbo_cli
```

## 📝 Full Changelog

For a complete list of changes, check out our [changelog on GitHub](https://github.com/ultrawideturbodev/ultra_wide_turbo_cli/blob/main/CHANGELOG.md).

## 🤝 Contributing

We welcome contributions! Whether it's bug reports, feature requests, or code contributions, check out our [GitHub repository](https://github.com/ultrawideturbodev/ultra_wide_turbo_cli) to get started. 