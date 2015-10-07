"
This class places security limits on input. Setting a limit to nil disables it, and removeAll disables all.
"
Class {
	#name : #XMLParserLimits,
	#superclass : #Object,
	#instVars : [
		'documentReadLimit',
		'maxEntityReplacementDepth'
	],
	#classInstVars : [
		'defaultReadLimit'
	],
	#category : #'XML-Parser'
}

{ #category : #accessing }
XMLParserLimits class >> defaultDocumentReadLimit [
	^ self defaultReadLimit
]

{ #category : #accessing }
XMLParserLimits class >> defaultMaxEntityReplacementDepth [
	^ 10
]

{ #category : #accessing }
XMLParserLimits class >> defaultReadLimit [
	^ defaultReadLimit
]

{ #category : #accessing }
XMLParserLimits class >> defaultReadLimit: aReadLimit [
	defaultReadLimit := aReadLimit
]

{ #category : #'class initialization' }
XMLParserLimits class >> initialize [
	"self initialize"

	defaultReadLimit := 10000000
]

{ #category : #accessing }
XMLParserLimits >> documentReadLimit [
	^ documentReadLimit
]

{ #category : #accessing }
XMLParserLimits >> documentReadLimit: aLimit [
	documentReadLimit := aLimit
]

{ #category : #initialization }
XMLParserLimits >> initialize [
	super initialize.

	documentReadLimit := self class defaultDocumentReadLimit.
	maxEntityReplacementDepth := self class defaultMaxEntityReplacementDepth.
]

{ #category : #accessing }
XMLParserLimits >> maxEntityReplacementDepth [
	^ maxEntityReplacementDepth
]

{ #category : #accessing }
XMLParserLimits >> maxEntityReplacementDepth: aLimit [
	maxEntityReplacementDepth := aLimit
]

{ #category : #removing }
XMLParserLimits >> removeAll [
	documentReadLimit := nil.
	maxEntityReplacementDepth := nil.
]