"
This is a base class for attribute default value validators that implement the constraints (like #REQUIRED) from the default declaration.
"
Class {
	#name : #XMLAttributeDefaultValidator,
	#superclass : #Object,
	#instVars : [
		'defaultValue',
		'attribute'
	],
	#category : #'XML-Parser-Validation'
}

{ #category : #'instance creation' }
XMLAttributeDefaultValidator class >> attribute: anAttribute [
	^ self attribute: anAttribute defaultValue: ''
]

{ #category : #'instance creation' }
XMLAttributeDefaultValidator class >> attribute: anAttribute defaultValue: aDefaultValue [
	^ self new setAttribute: anAttribute defaultValue: aDefaultValue
]

{ #category : #accessing }
XMLAttributeDefaultValidator >> attribute [
	^ attribute
]

{ #category : #accessing }
XMLAttributeDefaultValidator >> defaultValue [
	^ defaultValue
]

{ #category : #printing }
XMLAttributeDefaultValidator >> printOn: aStream [
	super printOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: self attribute;
		nextPutAll: '="';
		nextPutAll: self defaultValue;
		nextPutAll: '")'.
]

{ #category : #initialization }
XMLAttributeDefaultValidator >> setAttribute: anAttribute defaultValue: aDefaultValue [
	attribute := anAttribute.
	defaultValue := aDefaultValue.
]

{ #category : #validating }
XMLAttributeDefaultValidator >> validateAttributeDefaultIn: anAttributeDictionary [
	self subclassResponsibility
]