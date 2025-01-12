enum RelationType {
  sourceTag,
  targetTag,
  ;

  bool get isSource => this == RelationType.sourceTag;
  bool get isTarget => this == RelationType.targetTag;
}
