"
This class is a facade that parses XML using a driver and tokenizer. See SAXHandler and XMLDOMParser for ready-made front ends to it.
"
Class {
	#name : #XMLParser,
	#superclass : #Object,
	#instVars : [
		'tokenizer',
		'driver'
	],
	#category : #'XML-Parser'
}

{ #category : #'instance creation' }
XMLParser class >> driver: aDriver on: aStringOrStream [
	^ self new setDriver: aDriver tokenizer: (aDriver tokenizerOn: aStringOrStream)
]

{ #category : #testing }
XMLParser >> atEnd [
	^ self tokenizer atEnd
]

{ #category : #accessing }
XMLParser >> context [
	^ self tokenizer context
]

{ #category : #accessing }
XMLParser >> context: aTokenContext [
	self tokenizer context: aTokenContext
]

{ #category : #accessing }
XMLParser >> currentLineNumber [
	^ self tokenizer currentLineNumber
]

{ #category : #accessing }
XMLParser >> driver [
	^ driver
]

{ #category : #private }
XMLParser >> handleParserError: anError [
	self tokenizer closeStreams.

	(anError isKindOf: XMLParserException)
		ifTrue: [
			anError hasLineNumber
				ifFalse: [anError lineNumber: self currentLineNumber].
			anError shouldPassOnWhenCaught
				ifTrue: [anError pass]]
		ifFalse: [anError pass].
]

{ #category : #parsing }
XMLParser >> parseDocument [
	[[self tokenizer atEnd]
		whileFalse: [self tokenizer nextToken]]
		on: Error
		do: [:error | self handleParserError: error]
]

{ #category : #parsing }
XMLParser >> parseDocumentUntil: aBlock [
	[[self tokenizer atEnd or: [aBlock value]]
		whileFalse: [self tokenizer nextToken]]
		on: Error
		do: [:error | self handleParserError: error]
]

{ #category : #parsing }
XMLParser >> parseDocumentWhile: aBlock [
	[[self tokenizer atEnd not and: [aBlock value]]
		whileTrue: [self tokenizer nextToken]]
		on: Error
		do: [:error | self handleParserError: error]
]

{ #category : #parsing }
XMLParser >> parseToken [
	^ [self tokenizer nextToken]
		on: Error
		do: [:error | self handleParserError: error]
]

{ #category : #initialization }
XMLParser >> setDriver: aDriver tokenizer: aTokenizer [
	driver := aDriver.
	tokenizer := aTokenizer.
]

{ #category : #accessing }
XMLParser >> tokenizer [
	^ tokenizer
]