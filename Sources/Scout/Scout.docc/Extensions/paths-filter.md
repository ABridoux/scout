# ``Scout/PathsFilter``

@Metadata {
    @DocumentationExtension(mergeBehavior: append)
}

## Overview

Allows to target single or group values, specific keys with regular expressions and values with predicates.

When filtering keys or values, it's always possible to specify single, group values or both.

## Topics

### No filter

- ``noFilter``
- ``targetOnly(_:)``
- ``ValueTarget``

### Filter keys

- ``key(regex:)``
- ``key(regex:target:)``
- ``key(pattern:target:)``

### Filter values

- ``value(_:)``
- ``value(_:_:)-8tfx1``
- ``value(_:_:)-2wxh0``

### Filter keys and values

- ``keyAndValue(pattern:valuePredicate:)``
- ``keyAndValue(keyRegex:valuePredicate:)``
- ``keyAndValue(keyRegex:valuePredicates:)``
- ``keyAndValue(keyRegex:valuePredicates:_:)``
- ``keyAndValue(pattern:valuePredicatesFormat:_:)``

### Predicates

- ``ValuePredicate``
- ``ExpressionPredicate``
- ``FunctionPredicate``

