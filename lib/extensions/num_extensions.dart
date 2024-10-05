import 'dart:math';
import 'package:flutter/cupertino.dart';


extension NumExtensions on double {
  double roundToNum(int x) {
    int decimals = x;
    num fac = pow(10, decimals);
    double d = this;
    d = (d * fac).round() / fac;
    return d;
  }
}

extension ListNumExtensions on Iterable<num> {
  num get getSum {
    num sum = 0;
    this.forEach((element) => sum += element);
    return sum;
  }
}
extension customString on String{
  String  get tofirstLetterupercase{
    return "${this[0].toLowerCase()}${this.substring(1).toUpperCase()}";
  }
}
extension totalEarningFromService on Iterable<num>{
  num get totalEarningFromServices{
    num Sum = 0;
    this.forEach((element) => Sum +=element);
    return Sum;
}
}
extension Democontext on BuildContext{

  get ScreenHeight=>MediaQuery.of(this).size.height;
  get ScreenWidth=>MediaQuery.of(this).size.width;

}

// extension dateTimeFormates on DateTime{
//   String dateTimeFormate(){
//     return DateFormat.yMMMMEEEEd().format(this);
//   }
// }

