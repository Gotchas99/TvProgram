Class {
	#name : #PirateApp,
	#superclass : #Object,
	#classVars : [
		'TheMaid'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateApp class >> initMaid [
	| delay  plist |
	plist := Process allInstances reject: [ :p | p isTerminated ].
	(plist anySatisfy: [ :p | p name = #theMaid ])
		ifTrue: [ ^ self ].
	delay := Delay forSeconds: 60 * 60.	"60 minutes"
	TheMaid := [ 
	[ 
	PirateTorrent updateStatuses.
	PirateVideo getAllSubtitles.
	delay wait ] repeat ] newProcess.
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
	quitting
		ifTrue: [ 
			TheMaid isNil
				ifFalse: [ 
					TheMaid terminate.
					TheMaid := nil ] ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> startUp: resuming [
	resuming
		ifTrue: [ 
			Config current initializeFromFile.
			self initMaid ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> validateState [
	PirateTorrent validateAll.
	PirateEpisode validateAll.
	PirateVideoFile validateAll
]
