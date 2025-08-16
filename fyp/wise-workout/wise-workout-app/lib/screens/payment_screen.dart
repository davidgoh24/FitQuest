import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'package:easy_localization/easy_localization.dart';
import '../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final String planName;
  final double price;
  const PaymentScreen({required this.planName, required this.price, Key? key}) : super(key: key);
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumController = TextEditingController();
  String cardNumber = '';
  String expiryDate = '';
  String cvv = '';
  String cardHolder = '';
  bool isProcessing = false;
  String? cardType;

  @override
  void dispose() {
    _cardNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    String previewNumber = cardNumber.isEmpty
        ? '**** **** **** ****'
        : cardNumber.padRight(16, '*').replaceRange(4, 12, ' **** **** ');

    return Scaffold(
      appBar: AppBar(
        title: Text('payment_title'.tr()),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                color: cs.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Container(
                  width: double.infinity,
                  height: 190,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            cardType ?? "",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: cs.onPrimary.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        previewNumber,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: cs.onPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                          letterSpacing: 2.0,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            expiryDate.isEmpty ? 'payment_card_expiry_hint'.tr() : expiryDate,
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cs.onPrimary.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            cardHolder.isEmpty ? 'payment_card_name_hint'.tr() : cardHolder.toUpperCase(),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: cs.onPrimary.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'payment_summary_title'.tr(args: [widget.planName]),
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${widget.price.toStringAsFixed(2)}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: cs.primary,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                decoration: InputDecoration(labelText: 'payment_label_cardholder'.tr()),
                onChanged: (value) => setState(() {
                  cardHolder = value;
                }),
                validator: (value) =>
                    value == null || value.isEmpty ? 'payment_error_cardholder'.tr() : null,
                onSaved: (value) => cardHolder = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cardNumController,
                decoration: InputDecoration(labelText: 'payment_label_cardnumber'.tr()),
                keyboardType: TextInputType.number,
                maxLength: 16,
                onChanged: (value) => setState(() {
                  cardNumber = value;
                }),
                validator: (value) {
                  if (value == null || value.length != 16) {
                    return 'payment_error_cardnumber'.tr();
                  }
                  return null;
                },
                onSaved: (value) => cardNumber = value!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'payment_label_expiry'.tr()),
                      maxLength: 5,
                      onChanged: (value) => setState(() {
                        expiryDate = value;
                      }),
                      validator: (value) {
                        if (value == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                          return 'payment_error_expiry_format'.tr();
                        }
                        int month = int.tryParse(value.substring(0, 2)) ?? 0;
                        int year = int.tryParse(value.substring(3, 5)) ?? 0;
                        if (month < 1 || month > 12) return 'payment_error_expiry_month'.tr();
                        final now = DateTime.now();
                        int currentYear = now.year % 100;
                        int currentMonth = now.month;
                        if (year < currentYear || (year == currentYear && month < currentMonth)) {
                          return 'payment_error_expiry_expired'.tr();
                        }
                        return null;
                      },
                      onSaved: (value) => expiryDate = value!,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'payment_label_cvv'.tr()),
                      obscureText: true,
                      maxLength: 3,
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value == null || value.length != 3 ? 'payment_error_cvv'.tr() : null,
                      onSaved: (value) => cvv = value!,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: isProcessing
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          setState(() {
                            isProcessing = true;
                          });
                          String paymentId = DateTime.now().millisecondsSinceEpoch.toString();
                          final result = await ApiService().buyPremiumWithMoney(widget.planName, paymentId);
                          setState(() {
                            isProcessing = false;
                          });
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => AlertDialog(
                              icon: result['success']
                                  ? Icon(Icons.check_circle, color: Colors.green[700], size: 40)
                                  : Icon(Icons.error, color: Colors.red[700], size: 40),
                              title: result['success']
                                  ? Text('payment_success_title'.tr())
                                  : Text('Payment Failed'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    result['success']
                                        ? 'Thank you for purchasing the ${widget.planName} plan.'
                                        : result['message'] ?? 'Payment failed. Please try again.',
                                  ),
                                  if (result['success']) ...[
                                    const SizedBox(height: 18),
                                    Row(
                                      children: [
                                        Icon(Icons.verified, color: Colors.green[700], size: 25),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            "You're eligible for a 7-day money back guarantee.",
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: Colors.green[700],
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Cancel within 7 days for a full refund.",
                                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 13),
                                      textAlign: TextAlign.center,
                                    ),
                                  ]
                                ],
                              ),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: cs.primary,
                                    foregroundColor: cs.onPrimary,
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(builder: (context) => const HomeScreen(userName: '')),
                                      (Route<dynamic> route) => false,
                                    );
                                  },
                                  child: const Text('OK'),
                                )
                              ],
                            ),
                          );
                        }
                      },
                child: isProcessing
                    ? CircularProgressIndicator(color: cs.onPrimary)
                    : Text('Pay \$${widget.price.toStringAsFixed(2)}',
                        style: theme.textTheme.titleMedium?.copyWith(color: cs.onPrimary)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
