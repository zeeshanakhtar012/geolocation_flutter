import 'dart:math';

String generateOTP() {
  Random random = Random();
  int otp = random.nextInt(9000) + 1000; // Generate a 4-digit OTP
  return otp.toString();
}