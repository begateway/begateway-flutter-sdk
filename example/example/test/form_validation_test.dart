import 'package:example/utils/form_validation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TextEditingController field(String text) => TextEditingController(text: text);

  group('formValidation: номер карты', () {
    test('пустое поле → обязательное, учитывает язык', () {
      expect(formValidation('cardNumber', field(''), 'en'),
          'Card number is required');
      expect(formValidation('cardNumber', field(''), 'ru'),
          'Необходимо указать номер карты');
    });

    test('короткий номер → неверный', () {
      expect(formValidation('cardNumber', field('4111 1111'), 'en'),
          'Card number is invalid');
    });

    test('неверная контрольная сумма → неверный', () {
      expect(formValidation('cardNumber', field('4111 1111 1111 1112'), 'en'),
          'Card number is invalid');
    });

    test('валидный VISA → пустая строка', () {
      expect(
          formValidation('cardNumber', field('4111 1111 1111 1111'), 'en'), '');
    });
  });

  group('formValidation: срок действия', () {
    test('пустое поле → обязательное', () {
      expect(formValidation('expiration', field(''), 'en'),
          'Expiration date is required');
    });

    test('неполная дата → неверный', () {
      expect(formValidation('expiration', field('12/'), 'en'),
          'Expiration date is invalid');
    });

    test('месяц вне диапазона → неверный', () {
      expect(formValidation('expiration', field('13/30'), 'en'),
          'Expiration date is invalid');
    });

    test('прошедшая дата → неверный', () {
      expect(formValidation('expiration', field('12/00'), 'en'),
          'Expiration date is invalid');
    });

    test('будущая дата → валидна', () {
      final year = (DateTime.now().year % 100 + 5) % 100;
      final text = '12/${year.toString().padLeft(2, '0')}';
      expect(formValidation('expiration', field(text), 'en'), '');
    });

    test('нецифровые символы не роняют валидацию', () {
      expect(formValidation('expiration', field('ab/cd'), 'en'),
          'Expiration date is invalid');
    });
  });

  group('formValidation: CVC/CVV', () {
    test('пустое поле → обязательное', () {
      expect(formValidation('cvv', field(''), 'en'), 'CVV/CVC is required');
    });

    test('меньше трёх символов → неверный', () {
      expect(formValidation('cvv', field('12'), 'en'), 'CVV/CVC is invalid');
    });

    test('три символа → валидно', () {
      expect(formValidation('cvv', field('123'), 'en'), '');
    });
  });

  group('formValidation: имя держателя', () {
    test('пустое поле → обязательное', () {
      expect(formValidation('holderName', field(''), 'en'),
          'Name on card is required');
    });

    test('один символ → обязательное', () {
      expect(formValidation('holderName', field('J'), 'en'),
          'Name on card is required');
    });

    test('два символа → валидно', () {
      expect(formValidation('holderName', field('Jo'), 'en'), '');
    });
  });

  test('неизвестное имя поля → пустая строка', () {
    expect(formValidation('unknown', field('whatever'), 'en'), '');
  });
}
