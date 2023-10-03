library resultz;

import 'package:resultz/result_checker.dart';

abstract class Result<ERR extends Object, OK extends Object> {
  const Result();

  /// Getter that will check if this result is an error.
  ///
  /// Note that you can gain similar behaviour by using
  bool get isErr => this is Err<ERR, OK>;

  /// Getter that will check if this result is ok.
  bool get isOk => this is Ok<ERR, OK>;

  /// Getter that will cast the result as an error.
  /// If the result is ok, it will throw an exception.
  /// You MUST CHECK if the result is an error before calling this getter.
  ///
  /// Example:
  /// ```dart
  /// final someResult = getResponse(); // Returns a Result<SomeError, Response>
  /// if (someResult.isErr) {
  ///   // Now it's safe to call this getter
  ///   final error = someResult.err;
  ///   // Do something with the error
  ///   print(error.message);
  /// }
  /// ```
  ///
  /// As an alternative to using this getter, you could also use the [check] or [map] method.
  /// These methods will provide safe and easier access to the result value, but are prone to
  /// callback hell. It's ADVISABLE to only use the [ok] and [err] getters when you would
  /// otherwise have to write a very long callback chain which is hard to read.
  ///
  /// In the future, we would like to add a static analysis tool that will enforce checks
  /// before using the [ok] and [err] getters. This way we can ensure casting safety.
  ERR get err {
    if (!isErr) {
      throw ResultException('Did not check isErr before getting err');
    }

    return (this as Err<ERR, OK>).val;
  }

  /// Getter that will cast the result as ok.
  /// If the result is an error, it will throw an exception.
  /// You MUST CHECK if the result is ok before calling this getter.
  ///
  /// Example:
  /// ```dart
  /// final someResult = getResponse(); // Returns a Result<SomeError, Response>
  /// if (someResult.isOk) {
  ///   // Now it's safe to call this getter
  ///   final response = someResult.ok;
  ///   // Do something with the response
  ///   print(response.message);
  /// }
  /// ```
  ///
  /// As an alternative to using this getter, you could also use the [check] or [map] method.
  /// These methods will provide safe and easier access to the result value, but are prone to
  /// callback hell. It's ADVISABLE to only use the [ok] and [err] getters when you would
  /// otherwise have to write a very long callback chain which is hard to read.
  ///
  /// In the future, we would like to add a static analysis tool that will enforce checks
  /// before using the [ok] and [err] getters. This way we can ensure casting safety.
  OK get ok {
    if (!isOk) {
      throw ResultException('Did not check isOk before getting ok');
    }

    return (this as Ok<ERR, OK>).val;
  }

  /// Creates a checker for this result.
  /// Can be used to check if the result is an error or an ok value.
  /// Example:
  ///
  /// ```dart
  /// someResult.check
  ///   ..isErr((SomeError err) => print(err))
  ///   ..isOk((SomeResponse ok) => print(ok))
  ///   ..elseDo(() => print('No match'));
  /// ```
  ///
  /// As an alternative to using this method, you could also use the [err] or [ok] getter.
  ResultChecker<ERR, OK> get check => ResultChecker(this);

  /// Transforms this result into another result.
  /// Takes two callback functions: one for the error case and one for the ok case.
  /// Each callback function must return the same type of result.
  /// Example:
  /// ```dart
  /// final transformedResult = someResult.map(
  ///   onErr: (SomeError err) => Err(err),
  ///   onOk: (SomeResponse ok) {
  ///     if (ok.message == 'Failed') {
  ///      return Err(SomeError('Failed'));
  ///    }
  ///     return Ok(ok);
  ///   },
  /// );
  /// ```
  /// As an alternative to using this method, you could also use the [err] or [ok] getter.
  Result<ERR_OUT, OK_OUT> map<ERR_OUT extends Object, OK_OUT extends Object>({
    required Result<ERR_OUT, OK_OUT> Function(ERR) onErr,
    required Result<ERR_OUT, OK_OUT> Function(OK) onOk,
  }) =>
      isOk ? onOk(ok) : onErr(err);

  /// Transforms this result into another result.
  /// Takes two callback functions: one for the error case and one for the ok case.
  /// Each callback function must return the same type of result.
  /// Example:
  /// ```dart
  /// final transformedResult = someResult.mapFuture(
  ///   onErr: (SomeError err) async => Err(err),
  ///   onOk: (SomeResponse ok) async {
  ///     if (ok.message == 'Failed') {
  ///      return Err(SomeError('Failed'));
  ///    }
  ///     return Ok(ok);
  ///   },
  /// );
  /// ```
  /// As an alternative to using this method, you could also use the [err] or [ok] getter.
  Future<Result<ERR_OUT, OK_OUT>>
      mapFuture<ERR_OUT extends Object, OK_OUT extends Object>({
    required Future<Result<ERR_OUT, OK_OUT>> Function(ERR) onErr,
    required Future<Result<ERR_OUT, OK_OUT>> Function(OK) onOk,
  }) async =>
          isOk ? await onOk(ok) : await onErr(err);

  @override
  String toString();
}

class ResultException implements Exception {
  ResultException(this.message);
  final String message;
}

class Err<ERR extends Object, OK extends Object> extends Result<ERR, OK> {
  const Err(this.val);
  final ERR val;

  @override
  String toString() => 'Err($val)';
}

class Ok<ERR extends Object, OK extends Object> extends Result<ERR, OK> {
  const Ok(this.val);
  final OK val;

  @override
  String toString() => 'Ok($val)';
}

extension ErrListExtension<T> on List<T> {
  bool containsType(Type type) => any((element) => element.runtimeType == type);
}
