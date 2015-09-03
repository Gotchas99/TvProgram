Class {
	#name : #PirateApp,
	#superclass : #PostgresObject,
	#classVars : [
		'TheMaid'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateApp class >> initMaid [
	| delay |
	TheMaid isNil
		ifFalse: [ ^ self ].
	delay := Delay forSeconds: 60 * 60.	"60 minutes"
	TheMaid := [ 
	[ 
	delay wait.
	PirateVideo getAllSubtitles ] repeat ] newProcess.
	TheMaid
		priority: Processor userBackgroundPriority;
		name: #theMaid;
		resume.
	Transcript crShow: 'Started TheMaid'
]

{ #category : #'as yet unclassified' }
PirateApp class >> initialize [ 
	super initialize .
	self initializeStartupShutdown.
]

{ #category : #'as yet unclassified' }
PirateApp class >> initializeStartupShutdown [
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self.
	"Remove startup from PirateShow where it used top be"
	Smalltalk removeFromStartUpList: PirateShow .
	Smalltalk removeFromShutDownList: PirateShow .

]

{ #category : #'as yet unclassified' }
PirateApp class >> shutDown: quitting [
	Transcript crShow: self name , ' shutDown: ' , quitting printString.
	quitting
		ifTrue: [ 
			TheMaid isNil
				ifFalse: [ 
					TheMaid terminate.
					TheMaid := nil ] ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> startUp: resuming [
	Transcript crShow: self name , ' startUp: ' , resuming printString.
	resuming
		ifTrue: [ 
			Config current initializeFromFile.
			self initMaid ]
]
