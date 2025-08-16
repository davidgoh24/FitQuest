import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wise_workout_app/services/profile_edit_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String firstName, lastName, username, dob, email, level, accountType, profileImage, backgroundImage;
  const EditProfileScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.dob,
    required this.email,
    required this.level,
    required this.accountType,
    required this.profileImage,
    required this.backgroundImage,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool isEditing = false;
  late String firstName;
  late String lastName;
  late String username;
  late String dateOfBirth;
  late String email;
  late String level;
  late String accountType;
  late String profileImage;
  late String backgroundImage;
  late TextEditingController firstNameController, lastNameController, dobController, usernameController, emailController;

  @override
  void initState() {
    super.initState();
    firstName = widget.firstName;
    lastName = widget.lastName;
    username = widget.username;
    dateOfBirth = widget.dob;
    email = widget.email;
    level = widget.level;
    accountType = widget.accountType;
    profileImage = widget.profileImage;
    backgroundImage = widget.backgroundImage;
    firstNameController = TextEditingController(text: firstName);
    lastNameController = TextEditingController(text: lastName);
    dobController = TextEditingController(text: _formatIncomingDOB(dateOfBirth));
    usernameController = TextEditingController(text: username);
    emailController = TextEditingController(text: email);
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    dobController.dispose();
    usernameController.dispose();
    emailController.dispose();
    super.dispose();
  }

  void startEditing() => setState(() => isEditing = true);

  void saveEdits() async {
    setState(() {
      firstName = firstNameController.text.trim();
      lastName = lastNameController.text.trim();
      username = usernameController.text.trim();
      dateOfBirth = dobController.text;
      email = emailController.text.trim();
      isEditing = false;
    });
    final isoDOB = _parseToISODate(dateOfBirth);
    final success = await ProfileEditService().updateProfile(
      username: username,
      firstName: firstName,
      lastName: lastName,
      dob: isoDOB,
      email: email,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('profile_update_failed'.tr())),
      );
    }
  }

  void cancelEdits() {
    setState(() {
      firstNameController.text = firstName;
      lastNameController.text = lastName;
      dobController.text = dateOfBirth;
      usernameController.text = username;
      emailController.text = email;
      isEditing = false;
    });
  }

  String _formatIncomingDOB(String dob) {
    try {
      final parsed = DateTime.parse(dob);
      return DateFormat('dd MMM yyyy').format(parsed);
    } catch (_) {
      return dob;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.tryParse(_parseToISODate(dobController.text)) ?? DateTime(1990, 1, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      String formatted = DateFormat('dd MMM yyyy').format(picked);
      setState(() {
        dobController.text = formatted;
      });
    }
  }

  String _parseToISODate(String value) {
    try {
      final parsed = DateFormat('dd MMM yyyy').parse(value);
      return DateFormat('yyyy-MM-dd').format(parsed);
    } catch (_) {
      return DateFormat('yyyy-MM-dd').format(DateTime.now());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final surface = colorScheme.surface;
    final surfaceVariant = colorScheme.surfaceVariant;
    final onSurface = colorScheme.onSurface;
    final secondary = colorScheme.secondary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          Container(
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(backgroundImage),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back, color: colorScheme.onSecondary),
                          onPressed: () => Navigator.pop(context, true),
                        ),
                        Expanded(
                          child: Text(
                            'profile_title'.tr(),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSecondary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // spacer for balanced layout
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 55),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        elevation: 4,
                        color: surface,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 70, bottom: 30, left: 20, right: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                child: Column(
                                  children: [
                                    Text(
                                      username,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: onSurface,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      accountType,
                                      style: TextStyle(
                                        color: secondary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Lvl. $level',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 30),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "profile_details".tr(),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (!isEditing)
                                    ElevatedButton.icon(
                                      onPressed: startEditing,
                                      icon: const Icon(Icons.edit, size: 16),
                                      label: Text("common_edit".tr()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: secondary,
                                        foregroundColor: colorScheme.onSecondary,
                                        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              dataItem("profile_first_name".tr(), isEditing ? buildField(firstNameController) : firstName, context),
                              dataItem("profile_last_name".tr(), isEditing ? buildField(lastNameController) : lastName, context),
                              dataItem("profile_username".tr(), isEditing ? buildField(usernameController) : username, context),
                              dataItem("profile_dob".tr(), isEditing ? buildDOBField(context, dobController) : _formatIncomingDOB(dateOfBirth), context),
                              dataItem("profile_email".tr(), isEditing ? buildField(emailController) : email, context),
                              const SizedBox(height: 20),
                              Text(
                                "Account Details",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              dataItem("profile_level".tr(), level, context, isGrey: true),
                              dataItem("profile_account_type".tr(), accountType, context, isGrey: true),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              backgroundImage,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                          CircleAvatar(
                            radius: 54,
                            backgroundImage: profileImage.isNotEmpty ? AssetImage(profileImage) : null,
                            backgroundColor:
                            profileImage.isNotEmpty ? Colors.transparent : colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isEditing)
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: saveEdits,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: secondary,
                        foregroundColor: colorScheme.onSecondary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("common_save".tr()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: cancelEdits,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text("common_cancel".tr()),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget dataItem(String label, dynamic value, BuildContext context, {bool isGrey = false, bool isBold = false}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          value is String
              ? Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isGrey ? variant : onSurface,
            ),
          )
              : SizedBox(width: 180, child: value),
        ],
      ),
    );
  }

  Widget buildField(TextEditingController controller) {
    return TextField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyMedium,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6)),
        ),
      ),
    );
  }

  Widget buildDOBField(BuildContext context, TextEditingController controller) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final variant = Theme.of(context).colorScheme.onSurfaceVariant;
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: AbsorbPointer(
        child: TextField(
          controller: controller,
          readOnly: true,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6)),
            ),
            suffixIcon: Icon(Icons.calendar_today, size: 18, color: variant),
          ),
        ),
      ),
    );
  }
}