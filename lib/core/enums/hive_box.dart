enum HiveBox {
  localStorageDto,
  ;

  String get id => toString();

  String documentId({required String id}) => switch (this) {
        HiveBox.localStorageDto => '$name\_$id',
      };
}
