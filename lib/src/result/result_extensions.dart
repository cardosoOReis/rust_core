import 'dart:async';

import 'package:rust_core/result.dart';
import 'package:rust_core/convert.dart';
import 'package:rust_core/option.dart';

extension FlattenExtension<S, F extends Object> on Result<Result<S, F>, F> {
  /// Converts a [Result] of a [Result] into a single [Result]
  @pragma("vm:prefer-inline")
  Result<S, F> flatten() {
    if (isOk()) {
      return unwrap();
    }
    return Err(unwrapErr());
  }
}

extension FlattenFutureExtension<S, F extends Object>
    on FutureResult<Result<S, F>, F> {
  @pragma("vm:prefer-inline")
  FutureResult<S, F> flatten() {
    return then((result) => result.flatten());
  }
}

extension ResultNullExtension<S, F extends Object> on Result<S?, F> {
  /// transposes a [Result] of a nullable type into a nullable [Result].
  /// Note: [transposeOut] is named as such otherwise there is ambiguity if named the same as [transposeIn] (transpose).
  Result<S, F>? transposeOut() {
    if (isOk()) {
      final val = unwrap();
      if (val == null) {
        return null;
      } else {
        return Ok(val);
      }
    } else {
      return Err(unwrapErr());
    }
  }
}

extension FutureResultNullExtension<S extends Object, F extends Object>
    on Future<Result<S?, F>> {
  @pragma("vm:prefer-inline")
  Future<Result<S, F>?> transpose() {
    return then((result) => result.transposeOut());
  }
}

extension ResultOptionExtension<S extends Object, F extends Object>
    on Result<Option<S?>, F> {
  /// Transposes a Result of an Option into an Option of a Result.
  Option<Result<S, F>> transpose() {
    if (isOk()) {
      final val = unwrap();
      if (val.v != null) {
        // ignore: null_check_on_nullable_type_parameter
        return Some(Ok(val.v!));
      }
      return None;
    } else {
      return Some(Err(unwrapErr()));
    }
  }
}

extension FutureResultOptionExtension<S extends Object, F extends Object>
    on Future<Result<Option<S?>, F>> {
  /// Transposes a FutureResult of an Option into an Option of a Result.
  @pragma("vm:prefer-inline")
  Future<Option<Result<S, F>>> transpose() async {
    return then((result) => result.transpose());
  }
}

extension NullResultExtension<S, F extends Object> on Result<S, F>? {
  /// transposes a nullable [Result] into a non-nullable [Result].
  /// Note: [transposeIn] is named as such otherwise there is ambiguity if named the same as [transposeOut] (transpose).
  Result<S?, F> transposeIn() {
    if (this != null) {
      if (this!.isOk()) {
        return Ok(this!.unwrap());
      } else {
        return Err(this!.unwrapErr());
      }
    }
    return Ok(null);
  }
}

//************************************************************************//

extension IterableResultExtensions<S, F extends Object>
    on Iterable<Result<S, F>> {
  /// Transforms an Iterable of results into a single result where the ok value is the list of all successes. If any
  /// error is encountered, the first error is used as the error result.
  Result<List<S>, F> toResultEager() {
    List<S> list = [];
    Result<List<S>, F> finalResult = Ok(list);
    for (final result in this) {
      if (result.isErr()) {
        return Err(result.unwrapErr());
      }
      list.add(result.unwrap());
    }
    return finalResult;
  }

  /// Transforms an Iterable of results into a single result where the ok value is the list of all successes and err
  /// value is a list of all failures.
  Result<List<S>, List<F>> toResult() {
    List<S> okList = [];
    late List<F> errList;
    Result<List<S>, List<F>> finalResult = Ok(okList);
    for (final result in this) {
      if (finalResult.isOk()) {
        if (result.isOk()) {
          okList.add(result.unwrap());
        } else {
          errList = [result.unwrapErr()];
          finalResult = Err(errList);
        }
      } else if (result.isErr()) {
        errList.add(result.unwrapErr());
      }
    }
    return finalResult;
  }
}

extension FutureIterableResultExtensions<S, F extends Object>
    on Future<Iterable<Result<S, F>>> {
  @pragma("vm:prefer-inline")
  FutureResult<List<S>, F> toResultEager() {
    return then((result) => result.toResultEager());
  }

  @pragma("vm:prefer-inline")
  FutureResult<List<S>, List<F>> toResult() {
    return then((result) => result.toResult());
  }
}

extension IterableFutureResultExtensions<S, F extends Object>
    on Iterable<FutureResult<S, F>> {
  /// Transforms an Iterable of [FutureResult]s into a single result where the ok value is the list of all successes. If
  /// any error is encountered, the first error is used as the error result. The order of [S] and [F] is determined by
  /// the order in which futures complete.
  FutureResult<List<S>, F> toResultEager() async {
    List<S> list = [];
    Result<List<S>, F> finalResult = Ok(list);
    await for (final result in _streamFuturesInOrderOfCompletion(this)) {
      if (result.isErr()) {
        return Err(result.unwrapErr());
      }
      list.add(result.unwrap());
    }
    return finalResult;
  }

  /// Transforms an Iterable of [FutureResult]s into a single result where the ok value is the list of all successes
  /// and err value is a list of all failures. The order of [S] and [F] is determined by
  /// the order in the List.
  FutureResult<List<S>, List<F>> toResult() async {
    List<S> okList = [];
    late List<F> errList;
    Result<List<S>, List<F>> finalResult = Ok(okList);
    for (final result in this) {
      final resultSync = await result;
      if (finalResult.isOk()) {
        if (resultSync.isOk()) {
          okList.add(resultSync.unwrap());
        } else {
          errList = [resultSync.unwrapErr()];
          finalResult = Err(errList);
        }
      } else if (resultSync.isErr()) {
        errList.add(resultSync.unwrapErr());
      }
    }
    return finalResult;
  }
}

extension FutureIterableFutureResultExtensions<S, F extends Object>
    on Future<Iterable<FutureResult<S, F>>> {
  @pragma("vm:prefer-inline")
  FutureResult<List<S>, F> toResultEager() async {
    return then((result) => result.toResultEager());
  }

  @pragma("vm:prefer-inline")
  FutureResult<List<S>, List<F>> toResult() async {
    return then((result) => result.toResult());
  }
}

extension ResultToFutureResultExtension<S, F extends Object> on Result<S, F> {
  /// Turns a [Result] into a [FutureResult].
  @pragma("vm:prefer-inline")
  FutureResult<S, F> toFutureResult() async {
    return this;
  }
}

extension ResultFutureToFutureResultExtension<S, F extends Object>
    on Result<Future<S>, F> {
  /// Turns a [Result] of a [Future] into a [FutureResult].
  FutureResult<S, F> toFutureResult() async {
    if (isErr()) {
      return (this as Err<Future<S>, F>).into();
    }
    return Ok(await unwrap());
  }
}

extension ToOkExtension<S> on S {
  /// Convert the object to a [Result] type [Ok].
  @pragma("vm:prefer-inline")
  Ok<S, E> toOk<E extends Object>() {
    assert(this is! Result,
        'Don\'t use the "toOk()" method on instances of Result.');
    return Ok(this);
  }
}

extension ToErrExtension<E extends Object> on E {
  /// Convert the object to a [Result] type [Err].
  @pragma("vm:prefer-inline")
  Err<S, E> toErr<S>() {
    assert(this is! Result,
        'Don\'t use the "toErr()" method on instances of Result.');
    return Err(this);
  }
}

extension InfallibleOkExtension<S> on Result<S, Infallible> {
  @pragma("vm:prefer-inline")
  S intoOk() {
    return unwrap();
  }
}

extension InfallibleErrExtension<F extends Object> on Result<Infallible, F> {
  @pragma("vm:prefer-inline")
  F intoErr() {
    return unwrapErr();
  }
}

extension InfallibleFutureOkExtension<S> on FutureResult<S, Infallible> {
  @pragma("vm:prefer-inline")
  Future<S> intoOk() {
    return then((result) => result.intoOk());
  }
}

extension InfallibleFutureErrExtension<F extends Object>
    on FutureResult<Infallible, F> {
  @pragma("vm:prefer-inline")
  Future<F> intoErr() {
    return then((result) => result.intoErr());
  }
}

//************************************************************************//

/// Returns futures in the order they complete
Stream<T> _streamFuturesInOrderOfCompletion<T>(Iterable<Future<T>> futures) {
  var controller = StreamController<T>();
  int yetToComplete = futures.length;
  if (yetToComplete == 0) {
    controller.close();
  }

  for (var future in futures) {
    future.then((value) {
      controller.add(value);
      yetToComplete--;
      if (yetToComplete == 0) {
        controller.close();
      }
    }).catchError((dynamic error) {
      if (error is Object) {
        controller.addError(error);
      }
      yetToComplete--;
      if (yetToComplete == 0) {
        controller.close();
      }
    });
  }

  return controller.stream;
}
