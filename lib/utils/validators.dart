class Validator {
  static String? nameValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter full name';
    }
    return null;
  }

  static String? userNameValidator(String? value) {
    const usernamePattern = r'^[a-zA-Z0-9._-]+$';
    final usernameRegExp = RegExp(usernamePattern);
    if (value == null || value.isEmpty) {
      return 'please enter your username';
    } else if (!usernameRegExp.hasMatch(value)) {
      return 'enter valid username';
    } else if (value.length < 3) {
      return 'username too short';
    }
    return null;
  }

  static String? phoneNumberValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'enter your phone number';
    } else if (value.length != 11) {
      return 'enter valid phone number';
    }
    return null;
  }

  static String? emailValidator(String? value) {
    RegExp emailRegex = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value == null || value.isEmpty) {
      return 'please enter email address';
    } else if (!emailRegex.hasMatch(value)) {
      return 'please enter valid email address';
    }
    return null;
  }

  static String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) {
      return 'please enter your password';
    } else if (value.length < 8) {
      return 'password must be 8 character long';
    }
    return null;
  }

  static String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'please enter your password';
    } else if (value.length < 8) {
      return 'password must be 8 character long';
    } else if (value != password) {
      return 'password does not match';
    }
    return null;
  }

  static String? validateForm(String? value, String message) {
    if (value == null || value.isEmpty) {
      return message;
    }
    return null;
  }

  static String? validateGroupName(String? value, bool isGroupChat) {
    if (isGroupChat == false) {
      return null;
    } else if (value == null || value.isEmpty) {
      return 'please enter a group name';
    } else if (value.length < 3) {
      return 'group name is too short';
    }
    return null;
  }

  static String? validateLink(String? value, String validateMsg) {
    /// Regular expression to validate domain or URL
    const urlPattern = r"^(https?:\/\/)?(www\.)?[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}(:[0-9]{1,5})?(\/.*)?$";
    final urlRegExp = RegExp(urlPattern);
    if (value == null || value.isEmpty) {
      return null;
    } else if (!urlRegExp.hasMatch(value)) {
      return 'enter a valid link here';
    } else if (validateMsg.isNotEmpty) {
      return validateMsg;
    }
    return null;
  }

  static String? validateBirthdate(DateTime? date) {
    final DateTime minimumDate = DateTime.now().subtract(const Duration(days: 13 * 365));
    if (date == null) {
      return 'Please select your birthdate';
    }
    if (date.isAfter(minimumDate)) {
      return 'You must be at least 13 years old';
    }
    return null;
  }
}
