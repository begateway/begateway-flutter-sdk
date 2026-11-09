String formatCardNumber(String input) {
  input = input.replaceAll(RegExp(r'\s'), ''); // убрать существующие пробелы
  final StringBuffer output = StringBuffer();
  for (int i = 0; i < input.length; i++) {
    if (i > 0 && i % 4 == 0) {
      output.write(' '); // добавлять пробел через каждые 4 символа
    }
    output.write(input[i]);
    if (output.length >= 19 + 4) {
      break; // прекратить форматирование после максимальной длины (16 + 3 пробела)
    }
  }
  return output.toString();
}
