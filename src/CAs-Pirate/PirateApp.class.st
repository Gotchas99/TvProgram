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

{ #category : #files }
PirateApp class >> readFromNewFile [
	| stuff |
	stuff := FLMaterializer materializeFromFileNamed: PirateShow fileName , '_new.fuel'.
	PirateShow show: (stuff at: #shows).
	PirateTorrent allTorrents: (stuff at: #allTorrents).
	PirateTorrent DeathRow: (stuff at: #deathRow).
	Transcript crShow: 'File read'
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
			self initMaid.
			Gofer new
				smalltalkhubUser: 'Gotchas' project: 'TvProgram';
				package: 'ConfigurationOfTvProgram';
				update ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> validateState [
	PirateTorrent validateAll.
	PirateEpisode validateAll.
	PirateVideoFile validateAll
]

{ #category : #files }
PirateApp class >> writeToNewFile [
	| stuff |
	stuff := Dictionary
		newFrom:
			{(#shows -> PirateShow shows).
			(#allTorrents -> PirateTorrent allTorrents).
			(#deathRow -> PirateTorrent DeathRow)}.
	FLSerializer serialize: stuff toFileNamed: PirateShow fileName , '_new.fuel'.
	Transcript
		show: 'File written';
		cr.
	GrowlMorph openWithLabel: 'File written' contents: ''
]
