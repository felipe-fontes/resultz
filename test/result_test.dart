import 'package:flutter_test/flutter_test.dart';
import 'package:resultz/result.dart';

class SomeError extends Error {
  SomeError(this.message);
  final String message;
}

class SpecificError1 extends SomeError {
  SpecificError1(super.message);
}

class SpecificError2 extends SomeError {
  SpecificError2(super.message);
}

class SpecificError3 extends SomeError {
  SpecificError3(super.message);
}

class Response {
  const Response(this.message);
  final String? message;
}

class SpecialResponse extends Response {
  const SpecialResponse(super.message);
}

Result<SomeError, Response> getResponse(int n) {
  if (n == -1) {
    return const Ok(SpecialResponse('Special response'));
  }

  if (n == 1) {
    return Err(SpecificError1('n cannot be 1'));
  }

  if (n == 2) {
    return Err(SpecificError2('n cannot be 2'));
  }

  if (n == 3) {
    return Err(SpecificError3('n cannot be 3'));
  }

  if (n >= 4) {
    return Err(SomeError('n cannot be greater than 3'));
  }

  return const Ok(Response('Hello, World!'));
}

Future<Result<SomeError, String>> getPerson(int id) async {
  final people = [
    'MagnusCarlsen',
    'RickAstley',
    'JohnDoe',
  ];

  if (id < 0 || id >= people.length) {
    return Err(SomeError('n is out of bounds'));
  }

  return Ok(people[id]);
}

Future<Result<SomeError, String>> getIceCream(
  String flavour,
  int numScoops,
) async {
  final iceCreamQuantities = {
    'chocolate': 10,
    'vanilla': 5,
    'strawberry': 0,
    'lemon': 2,
  };

  if (!iceCreamQuantities.containsKey(flavour)) {
    return Err(SomeError('Flavour not found'));
  }

  if (iceCreamQuantities[flavour]! < numScoops) {
    return Err(SomeError('Not enough ice cream'));
  }

  return Ok('Here is your $numScoops of $flavour ice cream');
}

Future<Result<SomeError, String>> eatIceCream(
  String personName,
  String flavour,
) async {
  if (personName == 'RickAstley') {
    return Err(SomeError('Rick Astley does not like ice cream'));
  }

  if (personName == 'JohnDoe' && flavour == 'lemon') {
    return Err(SomeError('John Doe does not like lemon ice cream'));
  }

  return Ok('Enjoy your $flavour ice cream, $personName!');
}

Future<Result<SomeError, Response>> giveSomeoneIceCream(
  int personId,
  String flavour,
  int numScoops,
) async {
  final person = await getPerson(personId);

  return person.mapFuture(
    onErr: (err) async => Err(err),
    onOk: (personName) async {
      final iceCream = await getIceCream(flavour, numScoops);

      return iceCream.mapFuture(
        onErr: (err) async => Err(err),
        onOk: (iceCream) async {
          final eat = await eatIceCream(personName, flavour);

          return eat.map(
            onErr: Err.new,
            onOk: (message) => Ok(Response(message)),
          );
        },
      );
    },
  );
}

Future<Result<SomeError, Response>> giveSomeoneIceCream2(
  int personId,
  String flavour,
  int numScoops,
) async {
  final person = await getPerson(personId);

  if (person.isErr) {
    return Err(person.err);
  }

  final iceCream = await getIceCream(flavour, numScoops);

  if (iceCream.isErr) {
    return Err(iceCream.err);
  }

  final eatResult = await eatIceCream(person.ok, flavour);

  if (eatResult.isErr) {
    return Err(SomeError('eat is null'));
  }

  return Ok(Response(eatResult.ok));
}

void main() {
  group('Result', () {
    test('SpecialResponse', () {
      getResponse(-1).check
        ..ifErr<SpecificError1>((err) => fail('Should not be SpecificError1'))
        ..ifErr<SpecificError2>((err) => fail('Should not be SpecificError2'))
        ..ifErr<SpecificError3>((err) => fail('Should not be SpecificError3'))
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<SpecialResponse>(
          (response) => expect(response.message, 'Special response'),
        )
        ..ifOk<Response>((response) => fail('Should not be Response'))
        ..elseDo(() => fail('No match'));
    });

    test('Ok', () {
      getResponse(0).check
        ..ifErr<SpecificError1>((err) => fail('Should not be SpecificError1'))
        ..ifErr<SpecificError2>((err) => fail('Should not be SpecificError2'))
        ..ifErr<SpecificError3>((err) => fail('Should not be SpecificError3'))
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<Response>(
          (response) => expect(response.message, 'Hello, World!'),
        )
        ..elseDo(() => fail('No match'));
    });

    test('SpecificError1', () {
      getResponse(1).check
        ..ifErr<SpecificError1>((err) => expect(err.message, 'n cannot be 1'))
        ..ifErr<SpecificError2>((err) => fail('Should not be SpecificError2'))
        ..ifErr<SpecificError3>((err) => fail('Should not be SpecificError3'))
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<Response>((response) => fail('Should not be Ok'))
        ..elseDo(() => fail('No match'));
    });

    test('SpecificError2', () {
      getResponse(2).check
        ..ifErr<SpecificError1>((err) => fail('Should not be SpecificError1'))
        ..ifErr<SpecificError2>((err) => expect(err.message, 'n cannot be 2'))
        ..ifErr<SpecificError3>((err) => fail('Should not be SpecificError3'))
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<Response>((response) => fail('Should not be Ok'))
        ..elseDo(() => fail('No match'));
    });

    test('SpecificError3', () {
      getResponse(3).check
        ..ifErr<SpecificError1>((err) => fail('Should not be SpecificError1'))
        ..ifErr<SpecificError2>((err) => fail('Should not be SpecificError2'))
        ..ifErr<SpecificError3>((err) => expect(err.message, 'n cannot be 3'))
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<Response>((response) => fail('Should not be Ok'))
        ..elseDo(() => fail('No match'));
    });

    test('SomeError', () {
      getResponse(4).check
        ..ifErr<SpecificError1>((err) => fail('Should not be SpecificError1'))
        ..ifErr<SpecificError2>((err) => fail('Should not be SpecificError2'))
        ..ifErr<SpecificError3>((err) => fail('Should not be SpecificError3'))
        ..ifErr<SomeError>(
          (err) => expect(err.message, 'n cannot be greater than 3'),
        )
        ..ifOk<Response>((response) => fail('Should not be Ok'))
        ..elseDo(() => fail('No match'));
    });
  });

  group('Mapping results', () {
    test('Ok', () {
      final okResult = getResponse(0);

      okResult
          .map(
            onErr: (err) => fail('Should not be SomeError'),
            onOk: Ok.new,
          )
          .check
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<Response>(
          (response) => expect(response.message, 'Hello, World!'),
        )
        ..elseDo(() => fail('No match'));
    });

    test('SpecialResponse', () {
      final specialResult = getResponse(-1);

      final mappedResponse = specialResult.map<SomeError, SpecialResponse>(
        onErr: (err) => fail('Should not be SomeError'),
        onOk: (response) {
          if (response is SpecialResponse) {
            return Ok(response);
          } else {
            return Err(SomeError('Response is not SpecialResponse'));
          }
        },
      );

      mappedResponse.check
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<SpecialResponse>(
          (response) => expect(response.message, 'Special response'),
        )
        ..elseDo(() => fail('No match'));
    });

    test('SomeError', () {
      final errorResult = getResponse(4);

      final mappedResponse = errorResult.map(
        onErr: (err) => const Ok(Response('Hello, World!')),
        onOk: (response) => fail('Should not be Ok'),
      );
      mappedResponse.check
        ..ifErr<SomeError>((err) => fail('Should not be SomeError'))
        ..ifOk<Response>(
          (response) => expect(response.message, 'Hello, World!'),
        )
        ..elseDo(() => fail('No match'));
    });
  });

  group('MockExample - callback chaining', () {
    test('Good input passes', () async {
      final result = await giveSomeoneIceCream(0, 'chocolate', 2);
      expect(result.isOk, true);
      expect(
        result.ok.message,
        'Enjoy your chocolate ice cream, MagnusCarlsen!',
      );
    });

    test('Bad input fails', () async {
      final result = await giveSomeoneIceCream(0, 'doesnotexist', 0);
      expect(result.isErr, true);
      expect(result.err.message, 'Flavour not found');
    });
  });

  group('MockExample - manual checking', () {
    test('Good input passes', () async {
      final result = await giveSomeoneIceCream2(0, 'chocolate', 2);
      expect(result.isOk, true);
      expect(
        result.ok.message,
        'Enjoy your chocolate ice cream, MagnusCarlsen!',
      );
    });

    test('Bad input fails', () async {
      final result = await giveSomeoneIceCream2(0, 'doesnotexist', 0);
      expect(result.isErr, true);
      expect(result.err.message, 'Flavour not found');
    });
  });
}
