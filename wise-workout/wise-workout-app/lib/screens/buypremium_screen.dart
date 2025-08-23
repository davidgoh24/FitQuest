import 'package:flutter/material.dart';
import 'payment_screen.dart';
import '../widgets/plan_cards_widget.dart';
import '../widgets/benefits_widget.dart';
import '../widgets/included_widget.dart';
import '../widgets/money_back_widget.dart';
import '../services/api_service.dart';

class BuyPremiumScreen extends StatefulWidget {
  const BuyPremiumScreen({Key? key}) : super(key: key);
  @override
  State<BuyPremiumScreen> createState() => _BuyPremiumScreenState();
}

class _BuyPremiumScreenState extends State<BuyPremiumScreen> {
  final ApiService apiService = ApiService(); // <-- instantiate here

  int selectedPlan = 0;
  int userTokens = 0;
  bool isPremium = false;
  DateTime? premiumExpiry;
  bool loading = true;

  final List<Map<String, dynamic>> plans = [
    { 'name': 'Monthly', 'price': '\$2.99', 'period': '/month', 'tokens': 4000, 'durationDays': 30, },
    { 'name': 'Annual', 'price': '\$19.99', 'period': '/year', 'tokens': 19000, 'durationDays': 365, },
    { 'name': 'Lifetime', 'price': '\$49', 'period': '', 'tokens': 99000, 'durationDays': 36500, },
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() { loading = true; });
    try {
      final profile = await apiService.getCurrentProfile();
      setState(() {
        userTokens = profile['tokens'] ?? 0;
        isPremium = profile['role'] == 'premium';
        premiumExpiry = profile['premium_until'] != null
            ? DateTime.tryParse(profile['premium_until'])
            : null;
      });
    } catch (_) {} finally {
      setState(() { loading = false; });
    }
  }

  Future<void> _showBuyWithTokenConfirmation() async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final int neededTokens = (plans[selectedPlan]['tokens'] as num).toInt();
    final int durationDays = (plans[selectedPlan]['durationDays'] as num).toInt();
    String planName = plans[selectedPlan]['name'];
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Purchase"),
        content: Text("Are you sure you want to buy the $planName plan for $neededTokens tokens?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          content: SizedBox(
            height: 80,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text("Processing your purchase...", style: theme.textTheme.bodyMedium)
                ],
              ),
            ),
          ),
        ),
      );
      try {
        final buyResult = await apiService.buyPremiumWithTokens(planName);
        if (buyResult['success'] == true) {
          final profile = await apiService.getCurrentProfile();
          Navigator.of(context, rootNavigator: true).pop();
          setState(() {
            userTokens = profile['tokens'] ?? 0;
            isPremium = profile['role'] == 'premium';
            premiumExpiry = profile['premium_until'] != null
                ? DateTime.tryParse(profile['premium_until'])
                : null;
          });
          String premiumMsg =
          (durationDays > 3650)
              ? "Congratulations! You're now a premium user for LIFE."
              : "Congratulations! You're a premium user for $durationDays days!";
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Success!"),
              content: Text(premiumMsg, style: theme.textTheme.bodyMedium),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        } else {
          Navigator.of(context, rootNavigator: true).pop();
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Purchase Failed"),
              content: Text(buyResult['message'].toString(), style: theme.textTheme.bodyMedium),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK"),
                ),
              ],
            ),
          );
        }
      } catch (e) {
        Navigator.of(context, rootNavigator: true).pop();
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Purchase Failed"),
            content: Text(e.toString(), style: theme.textTheme.bodyMedium),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (loading) {
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onBackground),
          onPressed: () { Navigator.pop(context); },
        ),
        title: Text(
          'Premium Plan',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            if (isPremium) ...[
              _premiumDurationCard(context),
              const SizedBox(height: 13),
            ],
            const SizedBox(height: 10),
            _sectionTitle(context, 'Choose your Plan'),
            PlanCardsWidget(
              plans: plans,
              selectedPlan: selectedPlan,
              onSelected: (i) => setState(() => selectedPlan = i),
            ),
            const SizedBox(height: 24),
            _sectionTitle(context, 'Premium Benefits'),
            const BenefitsWidget(),
            const SizedBox(height: 24),
            _sectionTitle(context, "What's Included"),
            const IncludedWidget(),
            const SizedBox(height: 18),
            const MoneyBackWidget(),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(18, 2, 18, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52, width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: () {
                  String planName = plans[selectedPlan]['name'];
                  String priceString = plans[selectedPlan]['price'];
                  double price = double.tryParse(priceString.replaceAll('\$', '')) ?? 0.0;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(planName: planName, price: price),
                    ),
                  );
                },
                child: const Text("Get Premium Now"),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 48, width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  textStyle: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold, fontSize: 17),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: userTokens >= (plans[selectedPlan]['tokens'] as num).toInt()
                    ? _showBuyWithTokenConfirmation
                    : null,
                child: Text("Buy with ${(plans[selectedPlan]['tokens'] as num).toInt()} Tokens"),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "You have $userTokens tokens",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14,
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              "(Tokens can be won on Lucky Spin!)",
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: colorScheme.primary.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _premiumDurationCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    String durationText = '';
    if (premiumExpiry != null) {
      final daysLeft = premiumExpiry!.difference(DateTime.now()).inDays;
      if (daysLeft > 3650) {
        durationText = "Lifetime Premium";
      } else if (daysLeft > 0) {
        durationText = "$daysLeft days left";
      } else {
        durationText = "Expired";
      }
    } else {
      durationText = "Active";
    }
    return Card(
      color: colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Icon(Icons.star, color: colorScheme.secondary),
            const SizedBox(width: 14),
            Text(
              "You are Premium: ",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            Text(
              durationText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 16,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 17,
        color: Theme.of(context).colorScheme.onBackground,
      ),
    ),
  );
}