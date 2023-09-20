String formatCardNumber(String input) {
    input = input.replaceAll(RegExp(r'\s'), ''); // Remove existing spaces
    final StringBuffer output = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      if (i > 0 && i % 4 == 0) {
        output.write(' '); // Add a space every 4 characters
      }
      output.write(input[i]);
      if (output.length >= 19 + 4) {
        break; // Stop formatting after reaching max length (16 + 3 spaces)
      }
    }
    return output.toString();
  }
