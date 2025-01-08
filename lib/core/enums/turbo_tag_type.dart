enum TurboTagType {
  workspace;

  String get argument {
    switch (this) {
      case TurboTagType.workspace:
        return name;
    }
  }
}
