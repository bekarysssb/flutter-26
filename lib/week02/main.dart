import 'data.dart';
import 'models.dart';
import 'catalogue.dart';
import 'shelf_state.dart';

void main() {
  final library = Library();

  for (final json in rawBooks){
    library.add(Book.fromJson(json));
  }
  library.open();

  print(library.displayList.join('\n'));
  print('');

  print('Books after 2010: ${library.after2010.map((b) => b.title).toList()}');
  print('Average pages: ${library.averagePages}');
  print('Books per author: ${library.bookCountByAuthor}');
  print('DistinctAuthors: ${library.distinctAuthors}');
  print('GenresPresent: ${library.genresPresent}');
  print('');

  final books = library.items.whereType<Book>().toList();
  final stats = statsOf(books);
  print('Stats: count=${stats.count}, avgPages=${stats.avgPages}');
  print('');

  print(describe(Empty()));
  print(describe(Ready(books)));
  print(describe(Broken('shelf collapsed')));
}