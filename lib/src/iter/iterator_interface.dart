part of 'iterator.dart';

/// Iterface for Rust only methods. Not included is some methods that are already implemented by Dart's Iterable.
abstract interface class _RIterator<T> implements Iterator<T>, Iterable<T> {
  /// If the iterator is empty, returns None. Otherwise, returns the next value wrapped in Some.
  Option<T> next();

  //************************************************************************//

  /// Advances the iterator by n elements.
  /// The iterator will have been advanced by n elements when Ok(()) is returned, or a Err(k)
  /// where k is remaining number of steps that could not be advanced because the iterator ran out.
  Result<(), int> advanceBy(int n);

  bool all(bool Function(T) f);

// any: Implemented by Iterable.any

  /// Returns an iterator over N elements of the iterator at a time.
  /// The chunks do not overlap. If N does not divide the length of the iterator, then the last up to N-1 elements will
  /// be omitted and can be retrieved from the [.intoRemainder()] function of the iterator.
  ArrayChunksRIterator<T> arrayChunks(int size);

// by_ref: Will not implement, Dart does not have borrowing

  /// Takes two iterators and creates a new iterator over both in sequence.
  RIterator<T> chain(Iterator<T> other);

// cloned: Will not implement, Dart objects are not clonable
// cmp: Implemented in an extension

  /// Lexicographically compares the elements of this Iterator with those of another with respect to the specified comparison function.
  /// Less = -1
  /// Equal = 0
  /// Greater = 1
  int cmpBy<U>(
      Iterator<U> other, int Function(T, U) f); // todo change to iterator

// collect: Implemented by extensions

  List<T> collectList({bool growable = true});

  Set<T> collectSet();

// collect_into: Will not be implemented, no dart equivalent
// contains: Implemented by Iterable.contains
// copied: Will not be implemented, no dart equivalent

  /// Counting the number of iterations and returning it.
  int count();

  /// Creates an iterator which repeats the elements of the original iterator endlessly.
  CycleRIterator<T> cycle();

  /// Creates an iterator which gives the current iteration count as well as the next value.
  RIterator<(int, T)> enumerate();

  /// Determines if the elements of this Iterator are equal to those of another using "==".
  bool eq<U>(Iterator<U> other);

  /// Determines if the elements of this Iterator are equal to those of another with respect to the specified equality function.
  bool eqBy<U>(Iterator<U> other, bool Function(T, U) f);

  /// Creates an iterator which uses a closure to determine if an element should be yielded.
  RIterator<T> filter(bool Function(T) f);

  /// Creates an iterator that both filters and maps.
  /// The returned iterator yields only the values for which the supplied closure returns Some(value).
  RIterator<U> filterMap<U>(Option<U> Function(T) f);

  /// Searches for an element of an iterator that satisfies a predicate.
  Option<T> find(bool Function(T) f);

  /// Applies the function to the elements of iterator and returns the first non-none result.
  Option<U> findMap<U>(Option<U> Function(T) f);

  /// Creates an iterator that works like map, but flattens nested structure.
  FlatMapRIterator<T, U> flatMap<U>(Iterator<U> Function(T) f);

// flatten: Implemented in an extension
// fold: Implemented by Iterable.fold
// for_each: Implemented by Iterable.forEach
// fuse: Implemented in an extension
// ge: Implemented in an extension
// gt: Implemented in an extension

  /// Does something with each element of an iterator, passing the value on.
  RIterator<T> inspect(void Function(T) f);

  /// Creates a new iterator which places a separator between adjacent items of the original iterator.
  /// Similar to join with strings.
  RIterator<T> intersperse(T element);

  /// Creates a new iterator which places an item generated by separator between adjacent items of the original iterator.
  /// The closure will be called each time to generate the separator.
  RIterator<T> intersperseWith(T Function() f);

  /// Checks if the elements of this iterator are partitioned according to the given predicate, such that all those that return true precede all those that return false.
  bool isPartitioned(bool Function(T) f);

// is_sorted: Implemented as an extension

  /// Checks if the elements of this iterator are sorted by f.
  /// That is, for each element f(a,b) and its following element f(b,c), f(a,b) <= f(b,c) must hold. If the iterator yields exactly zero or one element, true is returned.
  /// negative if a < b
  /// zero if a == b
  /// positive if a > b
  bool isSortedBy(int Function(T, T) f);

  /// Checks if the elements of this iterator are sorted by a key.
  /// That is, for each element f(a) and its following element f(b), f(a) <= f(b) must hold. If the iterator yields exactly zero or one element, true is returned.
  /// negative if a < b
  /// zero if a == b
  /// positive if a > b
  bool isSortedByKey<U extends Comparable<U>>(U Function(T) f);

  /// Consumes the iterator and returns the last element.
  Option<T> lastOrOption();

// le: Implemented in an extension
// lt: Implemented in an extension
// map: Implemented by Iterable.map

  /// Creates an iterator that both yields elements based on a predicate and maps.
  /// It will call this closure on each element of the iterator, and yield elements while it returns Some(_).
  RIterator<U> mapWhile<U>(Option<U> Function(T) f);

  /// Calls the given function f for each contiguous window of [size] over self and returns an iterator over the outputs of f
  /// e.g. [1, 2, 3, 4] with size 2 will yield windows of [1, 2], [2, 3], [3, 4]
  /// The windows indicies should be treated as immutable, as they are shared between calls to minize allocations.
  /// Therefore, you should not modify or store the window, but clone it if you need to.
  RIterator<U> mapWindows<U>(int size, U Function(Arr<T>) f);

// max: Implemented in extension

  /// Returns the element that gives the maximum value with respect to the specified comparison function.
  Option<T> maxBy(int Function(T, T) f);

  /// Returns the element that gives the maximum value from the specified function.
  Option<T> maxByKey<U extends Comparable<U>>(U Function(T) f);

// min: Implemented in extension

  /// Returns the element that gives the minimum value with respect to the specified comparison function.
  Option<T> minBy(int Function(T, T) f);

  /// Returns the element that gives the minimum value from the specified function.
  Option<T> minByKey<U extends Comparable<U>>(U Function(T) f);

// ne: Implemented in extension

  /// Returns the next n elements of the iterator as an [Arr],
  /// If there are not enough elements to fill the array then Err is returned containing an iterator over the remaining elements.
  Result<Arr<T>, RIterator> nextChunk(int size);

  /// Returns the nth element of the iterator.
  /// Like most indexing operations, the count starts from zero, so nth(0) returns the first value, nth(1) the second, and so on.
  /// nth() will return None if n is greater than or equal to the length of the iterator.
  Option<T> nth(int n);

// partial_cmp: Will not implement, Dart does not have partial comparison
// partial_cmp_by: Will not implement, Dart does not have partial comparison

  /// Consumes an iterator, creating two collections from it.
  /// partition() returns a pair, all of the elements for which it returned true, and all of the elements for which it returned false.
  (List<T>, List<T>) partition(bool Function(T) f);

  /// Reorders the elements of this iterator in-place according to the given predicate,
  /// such that all those that return true precede all those that return false.
  /// Returns the number of true elements found.
  /// The relative order of partitioned items is not maintained.
  int partitionInPlace(bool Function(T) f);

  /// Creates an iterator which can use the "peek" to look at the next element of the iterator without consuming it.
  PeekableRIterator<T> peekable();

  /// Searches for an element in an iterator, returning its index.
  Option<int> position(bool Function(T) f);

// product: Will not implement, not possible in Dart
// reduce: Implemented by Iterable.reduce

  /// Reverses the iterable
  RIterator<T> rev();

  /// Searches for an element in an iterator from the right, returning its index.
  /// Recommended to use with a list, as it is more efficient, otherwise use [position].
  Option<int> rposition(bool Function(T) f);

  /// An iterator which, like fold, holds internal state, but unlike fold, produces a new iterator.
  /// On iteration, the closure will be applied to each element of the iterator and the return value from the closure.
  /// The closure can return Some(value) to yield value, or None to end the iteration.
  RIterator<U> scan<U>(U initial, Option<U> Function(U, T) f);

// size_hint: Will not implement, not possible in Dart, would likely be implemented by any downstreams but do not to expect to have any.
// skip: Implemented by Iterable.skip
// skip_while: Implemented by Iterable.skipWhile

  /// Creates an iterator starting at the same point, but stepping by the given amount at each iteration.
  RIterator<T> stepBy(int step);

// sum: Will not implement, not possible in Dart
// take: Implemented by Iterable.take
// take_while: Implemented by Iterable.takeWhile
// try_collect: Implemented by extension
// try_find: Implemented by extension
// try_fold: Implemented by extension
// try_for_each: Implemented by extension
// try_reduce: Implemented by extension
// unzip: Implemented in extension

  // Zips this iterator with another and yields pairs of elements.
  // The first element comes from the first iterator, and the second element comes from the second iterator.
  // If either iterator does not have another element, the iterator stops.
  ZipRIterator<T, U> zip<U>(Iterator<U> other);
}
