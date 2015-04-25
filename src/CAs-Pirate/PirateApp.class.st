Class {
	#name : #PirateApp,
	#superclass : #PostgresObject,
	#classVars : [
		'TheMaid'
	],
	#category : #'CAs-Pirate'
}

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
				ifFalse: [ TheMaid terminate ] ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> startUp: resuming [
	Transcript crShow: self name , ' startUp: ' , resuming printString.
	resuming
		ifTrue: [ 
			Config current initializeFromFile.
			"Workspace
				openContents:
					'PirateVideoFile validateAll.
PirateTorrent setUpAllTorrents.'" ]
]
