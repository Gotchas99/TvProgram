Class {
	#name : #BlocketSearchTerm,
	#superclass : #Object,
	#instVars : [
		'url',
		'title'
	],
	#category : #'CAs-Blocket'
}

{ #category : #accessing }
BlocketSearchTerm >> <= aSearchTerm [
	^self title <= aSearchTerm title
]

{ #category : #accessing }
BlocketSearchTerm >> = aSearchTerm [
	^ url = aSearchTerm url
]

{ #category : #accessing }
BlocketSearchTerm >> title [
	^ title ifNil: [ url ]
]

{ #category : #accessing }
BlocketSearchTerm >> title: anObject [
	title := anObject
]

{ #category : #accessing }
BlocketSearchTerm >> url [
	^ url
]

{ #category : #accessing }
BlocketSearchTerm >> url: anObject [
	url := anObject
]
