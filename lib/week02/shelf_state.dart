import 'models.dart';

sealed class ShelfState{}

class Empty extends ShelfState{}

class Ready extends ShelfState{
  final List<Book> books;
  Ready(this.books);
}

class Broken extends ShelfState{
  final String message;
  Broken(this.message);
}

String describe(ShelfState state) => switch (state){
  Empty() => 'Shelf is empty',
  Ready(books: var b) => 'Shelf has ${b.length} books',
  Broken(message: var m) => 'Shelf broken: $m',
};

({int count, double avgPages}) statsOf(List<Book> books){
  final count = books.length;
  final avgPages = count == 0
      ? 0.0
      : books.fold(0, (sum, b) => sum + b.pages) / count;
  return (count: count, avgPages: avgPages);
}
