## Validate passwords

Make use of these classes to validate a weak, medium or strong password. Do not allow the user to choose as a password a word that is contained in the English dictionary, Spanish and others dictionaries.

### INSTRUCTIONS

Add ValidatePasswords.swift class in your project.

```
/// Options for password validate
///
/// - notPresentInDictionary: word present in dictionary not authorized
/// - checkStrengthPassword: strong, soft or weak password
public enum Option {
    case notPresentInDictionary
    case checkStrengthPassword
}

/// Enum for password status level type
///
/// - strong: strong password: minimum characters, four rules
/// - soft: soft password: minimum characters, three rules
/// - weak: weak password: minimum characters
/// - notPresentInDictionary: dictionary (English, German, Spanish, Italian) not contain password
/// - presentInDictionary: dictionary (English, German, Spanish, Italian) contain password
/// - errorPassword: password error
public enum PasswordType {
    case strong
    case soft
    case weak
    case notPresentInDictionary
    case presentInDictionary
    case errorPassword
}
```

Use this function with enum options:

Level strength:

```
ValidatePasswords.passwordIsValidate(password: "chicken",
                                             option: .checkStrengthPassword,
                                             minimumCharacters: 5) { (passwordType) in
                                                
                                                debugPrint("PASSWORD TYPE: \(passwordType)")
        }
```

Present or not in dictionary:

```
ValidatePasswords.passwordIsValidate(password: "chickenandcow",
                                             option: .notPresentInDictionary,
                                             minimumCharacters: 5) { (passwordType) in
                                                
                                                debugPrint("Password ok: PASSWORD TYPE: \(passwordType)")
        }
```

### LICENSE

This project is free and use <b>CC BY-NC-SA</b>.

This license lets others remix, tweak, and build upon your work without for commercial purposes, as long as they credit you and license their new creations under the identical terms.

### THANK YOU!

I hope you like it!

##### ArtCC 2019++