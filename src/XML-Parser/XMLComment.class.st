"
This class represents comment nodes. Comments are ignored during parsing by default. If you want them preserved as comment nodes, use #preservesCommentNodes: with the DOM parser before parsing.
"
Class {
	#name : #XMLComment,
	#superclass : #XMLNode,
	#instVars : [
		'string'
	],
	#category : #'XML-Parser-DOM'
}

{ #category : #'instance creation' }
XMLComment class >> string: aString [
	^ self new string: aString
]

{ #category : #testing }
XMLComment >> isComment [
	^ true
]

{ #category : #private }
XMLComment >> sortKey [
	^ self string
]

{ #category : #accessing }
XMLComment >> string [
	^ string ifNil: [string := '']
]

{ #category : #accessing }
XMLComment >> string: aString [
	string := aString
]

{ #category : #printing }
XMLComment >> writeXMLOn: aWriter [
	aWriter comment: self string
]