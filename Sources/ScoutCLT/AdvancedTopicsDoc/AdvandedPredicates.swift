//
// Scout
// Copyright (c) Alexis Bridoux 2020
// MIT license, see LICENSE file for details

import Lux

extension AdvancedDocumentation {
    enum Predicates {}
}

extension AdvancedDocumentation.Predicates {

    private static let zshInjector = ZshInjector(type: .terminal)
    private static var standardComparisonOperators: String {
        ["==", "!=", "<", "<=", ">", ">="]
            .map(\.bold)
            .joined(separator: ", ")
    }

    static var text =
    """
    ----------
    Predicates
    ----------

    Predicates are used to filter the value with some commands.
    The variable 'value' in the predicate will be replaced when evaluating a value against the predicate.
    For instance, the predicate \(zshString: "value > 10") will validate only the numeric values that are greater than 10.

    Strings have to be specified with single quotes to distinguish them from a variable: \(zshString: "value == 'String'").

    It's possible to use logic operators in a predicate to specify advanced conditions.
    For instance, \(zshString: "value > 10 && value <= 20")

    A predicate cannot use the 'value' variable with different types.
    For instance, \(zshString: "value > 10 && value hasPrefix 'to'") is not a valid predicate, as 'value'
    could be numeric or a string.

    \(header: "Standard operators")
    The standard comparison operators can be used: \(standardComparisonOperators)
    - \(zshString: "value > 10")
    - \(zshString: "value == 'Endo'")
    - \(zshString: "value >= 'Toto'") (strings are compared alphabetically)

    \(header: "Logic operators")
    The 'and' \("&&".bold) and 'or' \("||".bold) are available.
    - \(zshString: "value == 'Riri' || value == 'Fifi' || value == 'Loulou'")
    - \(zshString: "value > 10 && value <= 20")

    Also, the 'not' ! operator is available and can invert an epxression.
    - \(zshString: "!value") when value is a boolean. It's the same as \(zshString: "value == false")
    - \(zshString: "!(value > 10)")

    \(header: "Advanced operators")
    Predicates can use advanced operators.

    \(subheader: "contains")
    (string)
    true when the left operand contains the right operand. Case sensitive.
    Ex: \(zshString: "value contains 'ulou'"). true when value: "Loulou", false when value: "Riri"

    \(subheader: "isIn")
    (string)
    true when the left operand matches a value given in the right operand.
    The right operand is a list of string separated with commas. Use backslach to escape a comma in a string.
    Ex: \(zshString: "value isIn 'Riri, Fifi, Loulou'"). true when value: "Riri". false when value: "Donald".

    \(subheader: "hasPrefix")
    (string)
    true when the left operand starts with the right operand. Case sensitive.
    Ex: \(zshString: "value hasPrefix 'Ri'"). true when value: "Riri". false when value: "Fifi"

    \(subheader: "hasSuffix")
    (string)
    true when the left operand ends with the right operand. Case sensitive.
    Ex: \(zshString: "value hasSuffix 'lou'"). true when value: "Loulou". false when value: "Fifi"

    \(subheader: "matches")
    (string)
    true when the left operand matches the regular expression given as the right operand.
    The whole left operand has to match the regular expression to be validated.
    Ex: \(zshString: "value matches '[0-9]{3}'"). true when value: "123". false when value: "1010"

    \(header: "Boolean")
    When the value is a boolean, it's possible to only specify it.
    Ex: \(zshString: "value"). true if value is: true. It's the same as \(zshString: "value == true")
    It's possible to use the 'not' operator to invert a boolean or an expression
    Ex: \(zshString: "!value"). true when value is: false. It's the same as \(zshString: "value == false")
    Ex: \(zshString: "!(value hasPrefix 'To')"). true when value does not start with "To"

    """
}
