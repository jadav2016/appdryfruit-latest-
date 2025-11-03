import 'package:intl/intl.dart';

formatDateTime(String dateString){

  // Parse the string into DateTime
  DateTime dateTime = DateTime.parse(dateString);

  // Format the date
  String formattedDate = DateFormat('dd/MMMM/yyyy').format(dateTime);

  return formattedDate;
}