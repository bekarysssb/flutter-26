import 'models.dart';
class Library{
  final List<LibraryItem> items = [];

  void add(LibraryItem item) => items.add(item);

  Book? findByTitle(String title){
    for(final item in items){
      if (item is Book &&item.title == title) return item;
    }
    return null;
  }

  String countryOf(String title){
    return findByTitle(title)?.author.country ?? 'unknown';
  }

  late final DateTime openedAt;
  void open() => openedAt = DateTime.now();

  String? _cachedReport;
  String buildReport(){
    return _cachedReport ??= _generateReport();
  }

  String _generateReport(){
    return 'Report generated at $openedAt with ${items.length} items';
  }

  Iterable<String> get allTitles =>
      items.whereType<Book>().map((b) => b.title);

  Iterable<Book> get after2010 =>
      items.whereType<Book>().where((b) => b.year > 2010);

  double get averagePages{
    final books = items.whereType<Book>();
    return books.fold(0, (sum, b) => sum + b.pages) / books.length;
  }

  Map<String, int> get bookCountByAuthor{
    return items.whereType<Book>().fold(
      <String, int>{},
        (map, b) => map..update(b.author.name, (v) => v+1, ifAbsent: () => 1),
    );
  }

  Set<String> get distinctAuthors =>
      items.whereType<Book>().map((b) => b.author.name).toSet();

  Set<Genre> get genresPresent =>
      items.whereType<Book>().map((b) => b.genre).toSet();

  List<String> get displayList => [
    'CATALOGUE',
    for (final b in items.whereType<Book>()) '${b.title} (${b.year})',
    ...distinctAuthors,
    if (items.whereType<Book>().any((b) => b.pages == 0))
      '(incomplete data)'
  ];
}

