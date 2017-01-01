Class {
	#name : #PirateApp,
	#superclass : #Object,
	#classVars : [
		'Checked',
		'TheMaid'
	],
	#category : #'CAs-Pirate'
}

{ #category : #files }
PirateApp class >> fileName [
	| fileName |
	fileName := Config current torrentFolder asFileReference / 'TVshows'.
	^ fileName
]

{ #category : #'as yet unclassified' }
PirateApp class >> initMaid [
	| delay plist |
	plist := Process allInstances reject: [ :p | p isTerminated ].
	(plist anySatisfy: [ :p | p name = #theMaid ])
		ifTrue: [ 
			Transcript crShow: 'TheMaid is already running'.
			^ self ].
	delay := Delay forSeconds: 60 * 60.	"60 minutes"
	TheMaid := [ 
	[ 
	self runMaidTasks.
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
	self environment
		at: #SessionManager
		ifPresent: [ :manager | manager default registerUserClassNamed: self name ]
		ifAbsent: [ 
			Smalltalk
				addToStartUpList: self;
				addToShutDownList: self ].
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self.
	self environment
		at: #SessionManager
		ifPresent: [ :manager | manager default unregisterClassNamed: PirateShow ]
		ifAbsent: [ Smalltalk removeFromShutDownList: PirateShow ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> lookForTimeStamps [
	Checked := Set new.
	self lookForTimeStampsIn: PirateTorrent DeathRow.
	self lookForTimeStampsIn: PirateTorrent allTorrents.
	self lookForTimeStampsIn: PirateShow shows.
	Checked := nil
]

{ #category : #'as yet unclassified' }
PirateApp class >> lookForTimeStampsIn: obj [
	| ivar dt |
	obj ifNil: [ ^ self ].
	(obj isKindOf: String)
		ifTrue: [ ^ self ].
	(obj isKindOf: Number)
		ifTrue: [ ^ self ].
	(obj isKindOf: Boolean)
		ifTrue: [ ^ self ].
	(Checked includes: obj)
		ifTrue: [ ^ self ].
	Checked add: obj.
	(obj isKindOf: Collection)
		ifTrue: [ obj do: [ :each | self lookForTimeStampsIn: each ] ]
		ifFalse: [ 
			1 to: obj class instSize do: [ :i | 
				ivar := obj instVarAt: i.
				ivar class name = #TimeStamp
					ifTrue: [ 
						dt := DateAndTime fromSeconds: ivar asSeconds.
						obj instVarAt: i put: dt ]
					ifFalse: [ self lookForTimeStampsIn: ivar ] ] ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> lookForTimeStampsIn_old: aColl [
	| tmp ivar |
	(aColl isKindOf: String)
		ifTrue: [ ^ self ].
	(aColl isKindOf: Dictionary)
		ifTrue: [ tmp := aColl keys , aColl values ]
		ifFalse: [ tmp := aColl ].
	tmp
		do: [ :each | 
			1 to: each class instSize do: [ :i | 
				ivar := each instVarAt: i.
				(ivar isKindOf: Collection)
					ifTrue: [ self lookForTimeStampsIn: ivar ]
					ifFalse: [ 
						ivar class = TimeStamp
							ifTrue: [ each inspect ] ] ] ].
	self traceCr: 'looked for timestamps'
]

{ #category : #files }
PirateApp class >> readFromNewFile [
	| stuff fname |
	fname := (self fileName withExtension: 'fuel') pathString.
	stuff := FLMaterializer materializeFromFileNamed: fname.
	PirateShow shows: (stuff at: #shows).
	PirateTorrent allTorrents: (stuff at: #allTorrents).
	PirateTorrent DeathRow: (stuff at: #deathRow).
	Transcript crShow: 'File read'
]

{ #category : #files }
PirateApp class >> readFromNewFileSTON [
	| stuff fname |
	fname := (self fileName withExtension: 'ston') asFileReference.
	fname readStreamDo: [ :stream | stuff := STON fromStream: stream ].
	PirateShow shows: (stuff at: #shows).
	PirateTorrent allTorrents: (stuff at: #allTorrents).
	PirateTorrent DeathRow: (stuff at: #deathRow).	"	PirateShow reSort."
	Transcript
		show: 'File read from STON';
		cr
]

{ #category : #'as yet unclassified' }
PirateApp class >> runMaidTasks [
	Transcript crShow: 'Starting to update statuses'.
	PirateTorrent updateStatuses.
	Transcript crShow: 'Starting to get videofiles'.
	PirateEpisode getVideoFiles.
	Transcript crShow: 'Starting to get subtitles'.
	PirateVideo getAllSubtitles.
	Transcript crShow: 'Starting to check if show is inproduction'.
	PirateShow checkInProduction.
	Transcript crShow: 'Starting to get episode count from TMDB'.
	PirateShow setEpisodesFromTmdb
]

{ #category : #'as yet unclassified' }
PirateApp class >> shutDown: quitting [
	quitting
		ifTrue: [ 
			TheMaid
				ifNotNil: [ 
					TheMaid terminate.
					TheMaid := nil ] ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> startUp: resuming [
	| seen t |
	resuming
		ifTrue: [ 
			Config current initializeFromFile.
			[ 
			seen := PirateShow allEpisodes select: [ :e | e isViewed ].
			t := seen reject: [ :e | e torrent isNil ] thenCollect: [ :e | e torrent ].
			t do: [ :torr | torr doneWithThis ] ] fork.
			self initMaid.
			Gofer new
				smalltalkhubUser: 'Gotchas' project: 'TvProgram';
				package: 'ConfigurationOfTvProgram';
				update ]
]

{ #category : #'as yet unclassified' }
PirateApp class >> updateScript [
	"
ConfigurationOfTvProgram project development load.
"

	
]

{ #category : #'as yet unclassified' }
PirateApp class >> validateState [
	PirateTorrent validateAll.
	PirateEpisode validateAll.
	PirateVideoFile validateAll
]

{ #category : #files }
PirateApp class >> writeToNewFile [
	| stuff fname |
	fname := (self fileName withExtension: 'fuel') pathString.
	stuff := Dictionary
		newFrom:
			{(#shows -> PirateShow shows).
			(#allTorrents -> PirateTorrent allTorrents).
			(#deathRow -> PirateTorrent DeathRow)}.
	FLSerializer serialize: stuff toFileNamed: fname.
	Transcript
		crShow: 'File written';
		cr.
	GrowlMorph openWithLabel: 'File written' contents: ''
]

{ #category : #files }
PirateApp class >> writeToNewFileSTON [
	| stuff fname |
	fname := (self fileName withExtension: 'ston') asFileReference.
	stuff := Dictionary
		newFrom:
			{(#shows -> PirateShow shows).
			(#allTorrents -> PirateTorrent allTorrents).
			(#deathRow -> PirateTorrent DeathRow)}.
	fname writeStreamDo: [ :stream | STON put: stuff onStream: stream ].
	Transcript
		show: 'File written to STON';
		cr.
	GrowlMorph openWithLabel: 'File written' contents: 'to STON'
]
