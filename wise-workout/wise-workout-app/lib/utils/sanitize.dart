class SanitizeResult {
  final String value;
  final bool valid;
  final String? message;

  SanitizeResult._(this.value, this.valid, [this.message]);

  factory SanitizeResult.valid(String value) =>
      SanitizeResult._(value, true);

  factory SanitizeResult.invalid(String message) =>
      SanitizeResult._('', false, message);
}

class Sanitize {
  String sanitizeInput(String? input) {
    if (input == null) return '';
    return input.trim().replaceAll(RegExp(r'<[^>]*>?'), '');
  }

  SanitizeResult isValidEmail(String? email) {
    final sanitized = sanitizeInput(email);
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (sanitized.isEmpty) {
      return SanitizeResult.invalid("Email cannot be empty.");
    }

    if (!regex.hasMatch(sanitized)) {
      return SanitizeResult.invalid("Invalid email format.");
    }

    return SanitizeResult.valid(sanitized);
  }

  SanitizeResult isValidPassword(String? password) {
    final sanitized = sanitizeInput(password);

    if (sanitized.isEmpty) {
      return SanitizeResult.invalid("Password cannot be empty.");
    }

    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z0-9]).{8,}$');
    if (!regex.hasMatch(sanitized)) {
      return SanitizeResult.invalid(
        "Password must be at least 8 characters, include upper and lower case letters, and at least one number."
      );
    }

    return SanitizeResult.valid(sanitized);
  }

  SanitizeResult isValidUsername(String? username) {
    final sanitized = sanitizeInput(username);

    if (sanitized.isEmpty) {
      return SanitizeResult.invalid("Username cannot be empty.");
    }

    if (sanitized.length < 4) {
      return SanitizeResult.invalid("Username must be at least 4 characters.");
    }

    return SanitizeResult.valid(sanitized);
  }
  SanitizeResult isValidFirstName(String? firstName) {
    final sanitized = sanitizeInput(firstName);

    if (sanitized.isEmpty) {
      return SanitizeResult.invalid("First name cannot be empty.");
    }

    return SanitizeResult.valid(sanitized);
  }

  SanitizeResult isValidLastName(String? lastName) {
    final sanitized = sanitizeInput(lastName);

    if (sanitized.isEmpty) {
      return SanitizeResult.invalid("Last name cannot be empty.");
    }

    return SanitizeResult.valid(sanitized);
  }
}
