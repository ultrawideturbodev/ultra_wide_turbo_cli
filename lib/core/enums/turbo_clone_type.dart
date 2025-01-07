enum TurboCloneType {
  workspace;

  String get pName {
    switch (this) {
      case TurboCloneType.workspace:
        return name;
    }
  }

  String get help {
    switch (this) {
      case TurboCloneType.workspace:
        return 'Clone a workspace from the Ultra Wide Turbo (AI Agent) Workspace repo.';
    }
  }

  String get description {
    switch (this) {
      case TurboCloneType.workspace:
        return '''
Sets up a new workspace with the specified name
Options:
  -t, --target    Target directory for the clone (default: "../")
  -f, --force     Force clone even if directory exists

Example:
  turbo clone workspace --target=my_workspace --force
''';
    }
  }
}
