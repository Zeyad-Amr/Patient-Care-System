import 'package:flutter/material.dart';

String msg(int status) {
  switch (status) {
    case 0:
      return 'Connecting ..';
    case 1:
      return 'Adjusting conditions';
    case 2:
      return 'Machine is working';
    case 3:
      return 'Dialysate Container is empty, please fill it';
    case 4:
      return 'Drain Container is full, please empty it';

    default:
      return 'Waiting ...';
  }
}

String statusMsg(int status) {
  switch (status) {
    case 0:
      return 'Offline';
    case 1:
      return 'Online';
    case 2:
      return 'Online';
    case 3:
      return 'Warning !';
    case 4:
      return 'Warning !';

    default:
      return 'Waiting ...';
  }
}

Color statusColor(int status) {
  switch (status) {
    case 0:
      return Colors.grey;
    case 1:
      return Colors.blue;
    case 2:
      return Colors.green;
    case 3:
      return Colors.amber;
    case 4:
      return Colors.amber;

    default:
      return Colors.grey;
  }
}
