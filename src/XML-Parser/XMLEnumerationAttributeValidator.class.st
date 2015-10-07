"
This class validates attributes that can have any value taken from a list like ""(one|two|thee)"".
"
Class {
	#name : #XMLEnumerationAttributeValidator,
	#superclass : #XMLAttributeValidator,
	#instVars : [
		'allowedValues'
	],
	#category : #'XML-Parser-Validation'
}

{ #category : #accessing }
XMLEnumerationAttributeValidator >> allowedValues [
	^ allowedValues ifNil: [allowedValues := Set new]
]

{ #category : #'private ' }
XMLEnumerationAttributeValidator >> enumerationListParserClass [
	^ DTDEnumerationListParser
]

{ #category : #'private ' }
XMLEnumerationAttributeValidator >> errorInvalidValue: aValue [
	XMLValidationException
		formatSignal: 'Invalid value "{1}" for attribute "{2}"'
		with: aValue
		with: self attribute
]

{ #category : #testing }
XMLEnumerationAttributeValidator >> isEnumerationValidator [
	^ true
]

{ #category : #accessing }
XMLEnumerationAttributeValidator >> setAllowedValuesFromString: aString [
	allowedValues := (self enumerationListParserClass on: aString) parse
]

{ #category : #validating }
XMLEnumerationAttributeValidator >> validateAttributeValue: aValue [
	(self allowedValues includes: aValue)
		ifFalse: [self errorInvalidValue: aValue]
]

{ #category : #validating }
XMLEnumerationAttributeValidator >> validateXMLSpaceAttributeValidator [
	(self allowedValues size <= 2
		and: [self allowedValues allSatisfy: [:each |
			(each = 'preserve') or: [each = 'default']]])
		ifFalse: [self errorInvalidXMLSpaceAttributeValidator]
]