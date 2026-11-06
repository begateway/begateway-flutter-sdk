import 'package:begateway_flutter_sdk/src/utils/customer_name.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parseCustomerName: имя и фамилия', () {
    expect(parseCustomerName('Rick Astley'),
        (firstName: 'Rick', lastName: 'Astley'));
  });

  test('parseCustomerName: все слова после первого — фамилия', () {
    expect(parseCustomerName('Jean Claude Van Damme'),
        (firstName: 'Jean', lastName: 'Claude Van Damme'));
  });

  test('parseCustomerName: одно слово не падает с RangeError', () {
    // Раньше здесь было holder.split(' ')[1] — платёж падал.
    expect(parseCustomerName('Cher'), (firstName: 'Cher', lastName: ''));
  });

  test('parseCustomerName: пустая строка', () {
    expect(parseCustomerName(''), (firstName: '', lastName: ''));
  });

  test('parseCustomerName: лишние пробелы схлопываются', () {
    expect(parseCustomerName('  John   Doe  '),
        (firstName: 'John', lastName: 'Doe'));
  });
}
