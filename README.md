# Resultz Dart Package

The Resultz Dart package provides a simple and type-safe way to handle results in your Dart and Flutter applications. It allows you to represent the outcome of an operation as either an error or a success and provides convenient methods for working with these results.

Installation
To use this package, add resultz as a dependency in your pubspec.yaml file:

```yaml
dependencies:
  resultz: ^1.0.0 # Use the latest version from pub.dev
```
Then, run flutter pub get to fetch the package.

## Usage

### Creating and Handling Results

Results are represented as `Result<ERR, OK>`, where ERR is the error type and OK is the success type. You can create results using Err for errors and Ok for successes.

```dart
Future<Result<AddTaskError, Task>> addTask(Task task) async {
  try {
    
    if (task.title.isEmpty) {
        return Err(AddTaskError('Title cannot be empty'));
    }

    // Add task to database

    return Ok(task);
  } catch (e) {
    return Err(AddTaskError('Failed to add task'));
  }
}
```

### Checking Result Type

You can check the type of a result using the `isErr` and `isOk` getters:

```dart
if (result.isErr) {
  // Handle error
} else if (result.isOk) {
  // Handle success
}
```




### Accessing Values

To access the error or success value, you can use the `err` and `ok` getters. However, it's recommended to check the result type before accessing the value to ensure type safety.

```dart
if (result.isErr) {
    final error = result.err;
    // Handle error
    return;
}

var okResult = result.ok;
// Handle success
```

### Using Result Checker

The ResultChecker class provides a convenient way to handle results based on their type. You can specify the error or success type when using ifErr and ifOk methods to ensure type safety.

#### Handling Errors

Use the `ifErr` method to handle errors of a specific type:

```dart
result.check.ifErr<SpecificErrorType>((error) {
  // Handle errors of SpecificErrorType
});
```

#### Handling Successes

Use the `ifOk` method to handle successes of a specific type:

```dart
result.check.ifOk<SpecificSuccessType>((success) {
  // Handle successes of SpecificSuccessType
});
```

#### Handling Unmatched Results

The `elseDo` method allows you to define a callback that is called when the result wasn't matched by any of the earlier checks:

```dart
result.check
  ..ifErr<SpecificErrorType>((error) {
    // Handle specific error
  })
  ..ifOk<SpecificSuccessType>((success) {
    // Handle specific success
  })
  ..elseDo(() {
    // Handle unmatched result
  });
```

By specifying the type in `ifErr` and `ifOk`, you can ensure that you are handling the correct error or success types, providing type safety in your code.

### Mapping Result

You can transform result using the `map` and `mapFuture` methods:

```dart
final transformedResult = result.map(
  onErr: (error) => Err<int, String>(error * 2),
  onOk: (success) => Ok<int, String>('Transformed $success'),
);

final transformedResultFuture = result.mapFuture(
  onErr: (error) async => Err<int, String>(error * 2),
  onOk: (success) async => Ok<int, String>('Transformed $success'),
);
```

### Ensuring that you handle errors

The package provides a `ResultException` class that can be thrown if you try to access the value without checking the result type.

```dart
try {
  final error = result.err; // May throw ResultException
} catch (e) {
  print('Error: $e');
}

// err getter throws ResultException if result is not an error
ERR get err {
if (!isErr) {
    throw ResultException('Did not check isErr before getting err');
}

return (this as Err<ERR, OK>).val;
}
```

### Contributions and Issues

Contributions and bug reports are welcome! If you encounter any issues or have suggestions for improvements, please open an issue on the GitHub repository.