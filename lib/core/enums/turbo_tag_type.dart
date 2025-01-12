enum TagType {
  workspace;

  String get argument {
    switch (this) {
      case TagType.workspace:
        return name;
    }
  }
}
