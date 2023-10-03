import 'package:resultz/result.dart';

class ResultChecker<ERR extends Object, OK extends Object> {
  ResultChecker(this._result);

  final Result<ERR, OK> _result;
  bool _hasMatched = false;

  /// Checks if the result is an error. If it is, the callback function is called.
  /// Example:
  /// ```dart
  /// // Print the error if the result is an error.
  /// someResult.check
  ///   ..ifErr((SomeError err) => print(err));
  ///
  /// // Print the error if this result is a specific error.
  /// someResult.check
  ///   ..ifErr((SomeSpecificError err) => print(err));
  /// ```
  void ifErr<ERR_T extends ERR>(void Function(ERR_T) callback) {
    if (!_hasMatched && _result.isErr && _result.err is ERR_T) {
      callback(_result.err as ERR_T);
      _hasMatched = true;
    }
  }

  /// Checks if the result is an ok value. If it is, the callback function is called.
  /// Example:
  /// ```dart
  /// // Print the ok value if the result is an ok value.
  /// someResult.check
  ///   ..ifOk((SomeResponse ok) => print(ok));
  ///
  /// // Print the ok value if this result is a specific ok value.
  /// someResult.check
  ///   ..ifOk((SomeSpecificResponse ok) => print(ok));
  /// ```
  void ifOk<OK_T extends OK>(void Function(OK_T) callback) {
    if (!_hasMatched && _result.isOk && _result.ok is OK_T) {
      callback(_result.ok as OK_T);
      _hasMatched = true;
    }
  }

  /// Defines the callback that is called when the result wasn't matched by any of the earlier checks.
  /// Example:
  /// ```dart
  /// someResult.check
  ///  ..ifErr((SomeError err) => print('This never happens'))
  ///  ..elseDo(() => print('This text is printed!'));
  /// ```
  void elseDo(void Function() callback) {
    if (!_hasMatched) {
      callback();
    }
  }
}
