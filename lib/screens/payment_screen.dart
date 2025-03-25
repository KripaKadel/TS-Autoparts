// import 'package:flutter/material.dart';
// import 'package:khalti_flutter/khalti_flutter.dart'; // Use khalti_flutter package

// class PaymentScreen extends StatelessWidget {
//   final String serviceType;
//   final DateTime selectedDate;
//   final TimeOfDay selectedTime;
//   final int selectedMechanicId;
//   final VoidCallback onPaymentSuccess;

//   const PaymentScreen({
//     Key? key,
//     required this.serviceType,
//     required this.selectedDate,
//     required this.selectedTime,
//     required this.selectedMechanicId,
//     required this.onPaymentSuccess,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Payment'),
//       ),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => _initiatePayment(context),
//           child: const Text('Pay with Khalti'),
//         ),
//       ),
//     );
//   }

//   void _initiatePayment(BuildContext context) async {
//     try {
//       // Payment configuration
//       final paymentConfig = PaymentConfig(
//         amount: 1000, // Amount in paisa (e.g., 1000 paisa = Rs. 10)
//         productIdentity: 'appointment_${DateTime.now().millisecondsSinceEpoch}',
//         productName: 'Appointment Booking',
//       );

//       // Start payment using KhaltiFlutter
//       KhaltiFlutter.startPayment(
//         config: paymentConfig,
//         onSuccess: (PaymentSuccessResult result) {
//           // Payment successful
//           onPaymentSuccess(); // Call the callback to store the appointment
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Payment successful!')),
//           );
//         },
//         onFailure: (PaymentFailureResult result) {
//           // Payment failed
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('Payment failed: ${result.errorMessage}')),
//           );
//         },
//         onCancel: () {
//           // Payment canceled by the user
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Payment canceled!')),
//           );
//         },
//       );
//     } catch (e) {
//       // Handle any errors that occur during the payment process
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     }
//   }
// }


import 'package:flutter/material.dart';

class PaymentScreen extends StatelessWidget {
  final String serviceType;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int selectedMechanicId;
  final VoidCallback onPaymentSuccess;

  const PaymentScreen({
    Key? key,
    required this.serviceType,
    required this.selectedDate,
    required this.selectedTime,
    required this.selectedMechanicId,
    required this.onPaymentSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _initiatePayment(context),
          child: const Text('Pay Now'),
        ),
      ),
    );
  }

  // Placeholder payment function
  void _initiatePayment(BuildContext context) {
    // Simulating a payment success
    Future.delayed(const Duration(seconds: 2), () {
      // Call the callback to simulate a successful payment
      onPaymentSuccess();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment successful!')),
      );
    });
  }
}
