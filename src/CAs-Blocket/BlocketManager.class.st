Class {
	#name : #BlocketManager,
	#superclass : #Object,
	#instVars : [
		'projects'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Blocket'
}

{ #category : #'as yet unclassified' }
BlocketManager class >> current [
	Current ifNil: [ Current := self new].
	^Current
]

{ #category : #'as yet unclassified' }
BlocketManager class >> test [
	self new test
]

{ #category : #'as yet unclassified' }
BlocketManager class >> test2 [
"	^Current := self new test2"
]

{ #category : #'as yet unclassified' }
BlocketManager >> addProject: aProject [
	^self projects add: aProject.

]

{ #category : #'as yet unclassified' }
BlocketManager >> initialize [
	projects := SortedCollection new
]

{ #category : #'as yet unclassified' }
BlocketManager >> projects [
	projects ifNil: [projects := SortedCollection new].
	^projects
]

{ #category : #'as yet unclassified' }
BlocketManager >> removeProject: aProject [
	^self projects remove: aProject.

]

{ #category : #'as yet unclassified' }
BlocketManager >> test [
	| b |
	b := BlocketMorph onRobot: (BlocketRobot new).
	b openInWorld
]

{ #category : #'as yet unclassified' }
BlocketManager >> test2 [
	| |
	self addProject: (BlocketProject newBlandare).
"	b := BlocketMorph on: self projects first.
	b openInWorld"
]
