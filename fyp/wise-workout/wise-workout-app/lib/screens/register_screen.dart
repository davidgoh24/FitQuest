import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../widgets/register_button.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool agreeToTerms = false;
  bool isLoading = false;

  void showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Theme.of(context).colorScheme.error,
      ),
    );
  }

  bool isPasswordStrong(String password) {
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    return regex.hasMatch(password);
  }

  Future<void> handleRegister() async {
    if (!agreeToTerms) {
      showSnack("Please agree to the Terms & Conditions");
      return;
    }
    if (usernameController.text.trim().isEmpty) {
      showSnack("Username cannot be empty");
      return;
    }
    if (!isPasswordStrong(passwordController.text)) {
      showSnack("Password must be at least 8 characters and include upper, lower, digit, and special character.");
      return;
    }
    if (passwordController.text != confirmPasswordController.text) {
      showSnack("Passwords do not match");
      return;
    }

    setState(() => isLoading = true);

    final error = await registerUser(
      context,
      emailController.text,
      usernameController.text,
      passwordController.text,
      firstNameController.text,
      lastNameController.text,
    );

    setState(() => isLoading = false);

    if (error != null) {
      showSnack(error);
    } else {
      showSnack("register_success_otp_sent".tr(), success: true);
    }
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 19,
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );

  Widget _bulletList(BuildContext context, List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: items
        .map(
          (item) => Padding(
        padding: const EdgeInsets.only(left: 6.0, bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "• ",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15.5),
            ),
            Expanded(
              child: Text(
                item,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15.5),
              ),
            ),
          ],
        ),
      ),
    )
        .toList(),
  );

  List<String> _getBulletList(BuildContext context, String key) {
    final value = tr(key, context: context);
    if (value.trim().isEmpty) {
      return [];
    }
    return value.split('\n').map((e) => e.trim()).toList();
  }

  void showTermsDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          title: Text('privacy_policy_title'.tr()),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'privacy_policy_effective_date'.tr(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 14,
                      color: theme.hintColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'privacy_policy_intro'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                  ),

                  _sectionTitle(dialogContext, 'privacy_policy_section1'.tr()),
                  const SizedBox(height: 4),
                  Text(
                    'privacy_policy_1a'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                    ),
                  ),
                  _bulletList(dialogContext, _getBulletList(dialogContext, 'privacy_policy_1a_bullets')),
                  const SizedBox(height: 7),
                  Text(
                    'privacy_policy_1b'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                    ),
                  ),
                  _bulletList(dialogContext, _getBulletList(dialogContext, 'privacy_policy_1b_bullets')),
                  const SizedBox(height: 7),
                  Text(
                    'privacy_policy_1c'.tr(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                      'privacy_policy_1c_text'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                    ),
                  ),

                  _sectionTitle(dialogContext, 'privacy_policy_section2'.tr()),
                  _bulletList(dialogContext, _getBulletList(dialogContext, 'privacy_policy_2_bullets')),

                  _sectionTitle(dialogContext, 'privacy_policy_section3'.tr()),
                  _bulletList(dialogContext, _getBulletList(dialogContext, 'privacy_policy_3_bullets')),
                  Padding(
                    padding: const EdgeInsets.only(left: 6, top: 4),
                    child: Text(
                      'privacy_policy_3_text'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  // SECTION 4
                  _sectionTitle(dialogContext, 'privacy_policy_section4'.tr()),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, bottom: 6),
                    child: Text(
                      'privacy_policy_4_text'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                    ),
                  ),

                  _sectionTitle(dialogContext, 'privacy_policy_section5'.tr()),
                  _bulletList(dialogContext, _getBulletList(dialogContext, 'privacy_policy_5_bullets')),

                  _sectionTitle(dialogContext, 'privacy_policy_section6'.tr()),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, bottom: 6),
                    child: Text(
                      'privacy_policy_6_text'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                    ),
                  ),

                  _sectionTitle(dialogContext, 'privacy_policy_section7'.tr()),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, bottom: 6),
                    child: Text(
                      'privacy_policy_7_text'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                    ),
                  ),

                  _sectionTitle(dialogContext, 'privacy_policy_section8'.tr()),
                  Padding(
                    padding: const EdgeInsets.only(left: 6.0, bottom: 18),
                    child: Text(
                      'privacy_policy_8_text'.tr(),
                      style: theme.textTheme.bodyMedium?.copyWith(fontSize: 15.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('close'.tr()),
              onPressed: () => Navigator.pop(dialogContext),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  'assets/icons/fitquest-icon.png',
                  height: 150,
                ),
                const SizedBox(height: 32),

                Text(
                  "register_email_label".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'register_email_hint'.tr(),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  "register_first_name_label".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: 'register_first_name_hint'.tr(),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  'register_last_name_label'.tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: 'register_last_name_hint'.tr(),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  "register_username_label".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    hintText: 'register_username_hint'.tr(),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  "register_password_label".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: passwordController,
                  obscureText: !showPassword,
                  decoration: InputDecoration(
                    hintText: 'register_password_hint'.tr(),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showPassword ? Icons.visibility_off : Icons.visibility,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {
                        setState(() => showPassword = !showPassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "register_password_requirement".tr(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 16),
                Text(
                  "register_confirm_password_label".tr(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: !showConfirmPassword,
                  decoration: InputDecoration(
                    hintText: 'register_confirm_password_hint'.tr(),
                    hintStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: colorScheme.surface,
                    suffixIcon: IconButton(
                      icon: Icon(
                        showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                        color: theme.iconTheme.color,
                      ),
                      onPressed: () {
                        setState(() => showConfirmPassword = !showConfirmPassword);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: agreeToTerms,
                      activeColor: colorScheme.primary,
                      onChanged: (val) => setState(() => agreeToTerms = val ?? false),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'register_terms_prefix'.tr(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.textTheme.bodyMedium?.color,
                          ),
                          children: [
                            TextSpan(
                              text: 'register_terms_text'.tr(),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = showTermsDialog,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isLoading ? null : handleRegister,
                    child: isLoading
                        ? CircularProgressIndicator(
                      color: colorScheme.onPrimary,
                      strokeWidth: 2,
                    )
                        : Text(
                      "register_button_create_account".tr(),
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: Text(
                      "register_already_have_account".tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 14,
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}