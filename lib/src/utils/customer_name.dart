/// Имя покупателя из строки вида «Имя Фамилия».
///
/// Первое слово — имя, остальные слова — фамилия («Jean Claude Van Damme»
/// → `Jean` / `Claude Van Damme`). Для одного слова фамилия пустая:
/// раньше `holder.split(' ')[1]` падал с RangeError и ронял платёж.
({String firstName, String lastName}) parseCustomerName(String holder) {
  final parts = holder.trim().split(RegExp(r'\s+'));
  return (
    firstName: parts.first,
    lastName: parts.length > 1 ? parts.sublist(1).join(' ') : '',
  );
}
