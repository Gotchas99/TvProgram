"
This class validates attributes with lists of unparsed entity name values separated by spaces.
"
Class {
	#name : #XMLEntitiesAttributeValidator,
	#superclass : #XMLEntityAttributeValidator,
	#category : #'XML-Parser-Validation'
}

{ #category : #validating }
XMLEntitiesAttributeValidator >> validateAttributeValue: aValue [
	self
		listValuesIn: aValue
		do: [:each |
			self unparsedEntityValidator
				validateEntityReference: each
				inAttribute: self attribute]
]