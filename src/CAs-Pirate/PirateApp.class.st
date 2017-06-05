Class {
	#name : #PirateApp,
	#superclass : #Object,
	#classVars : [
		'Checked',
		'TheMaid'
	],
	#category : #'CAs-Pirate'
}

{ #category : #repair }
PirateApp class >> cleanupTorrents [
	| seen t  |
	seen := PirateShow allEpisodes select: [ :e | e isViewed ].
			t := seen reject: [ :e | e torrent isNil ] thenCollect: [ :e | e torrent ].
			t do: [ :torr | torr doneWithThis ] 
]

{ #category : #files }
PirateApp class >> fileName [
	| fileName |
	fileName := Config current torrentFolder asFileReference / 'TVshows'.
	^ fileName
]

{ #category : #background }
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

{ #category : #initialize }
PirateApp class >> initialize [ 
	super initialize .
	self initializeStartupShutdown.
]

{ #category : #initialize }
PirateApp class >> initializeStartupShutdown [
	self environment
		at: #SessionManager
		ifPresent: [ :manager | manager default registerUserClassNamed: self name ]
		ifAbsent: [ Smalltalk
				addToStartUpList: self;
				addToShutDownList: self ].

]

{ #category : #installation }
PirateApp class >> install_notes [
"
Monticello -> Smalltalkhub repo: 
MCSmalltalkhubRepository
	owner: 'Gotchas'
	project: 'TvProgram'
	user: 'Gotchas'
	password: 'Gotchas987'
---
ConfigurationOfTvProgram loadDevelopment.
Config current initializeFromFile .
PirateManagerMorph new openInWorld .
PirateApp readFromNewFile.
eller
PirateApp readFromNewFileSTON.
"
]

{ #category : #'upgrading to v5' }
PirateApp class >> lookForTimeStamps [
	Checked := Set new.
	self lookForTimeStampsIn: PirateTorrent DeathRow.
	self lookForTimeStampsIn: PirateTorrent allTorrents.
	self lookForTimeStampsIn: PirateShow shows.
	Checked := nil
]

{ #category : #'upgrading to v5' }
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

{ #category : #background }
PirateApp class >> lookForUpdates [
	[ Gofer new
		smalltalkhubUser: 'Gotchas' project: 'TvProgram';
		package: 'ConfigurationOfTvProgram';
		update ]
		on: HTTPProgress
		do: [ :progress | progress isEmpty
						ifFalse: [Transcript crShow:  progress percentage printString  ].progress resume ]
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

{ #category : #background }
PirateApp class >> runMaidTasks [
	[ Transcript crShow: 'Starting to update statuses'.
	PirateTorrent updateStatuses.
	Transcript crShow: 'Starting validate videofiles'.
	PirateEpisode validateAllVideoFiles.
	Transcript crShow: 'Starting to get videofiles'.
	PirateEpisode getVideoFiles.
	Transcript crShow: 'Removing old torrents'.
	PirateTorrent cleanUpSeedingDoneOnce.
	Transcript crShow: 'Starting to get subtitles'.
	PirateVideo getAllSubtitles.
	Transcript crShow: 'Starting to check if show is inproduction'.
	PirateShow checkInProduction.
	Transcript crShow: 'Starting to get episode count from TMDB'.
	PirateShow setEpisodesFromTmdb ]
		on: Error
		do: [ :exception | WorldState
	addDeferredUIMessage: [ 		Transcript
				crShow: 'Exception on MaidTask:';
				crShow: exception description ]]
]

{ #category : #'startup - shutdown' }
PirateApp class >> shutDown: quitting [
	quitting
		ifTrue: [ 
			TheMaid
				ifNotNil: [ 
					TheMaid terminate.
					TheMaid := nil ] ]
]

{ #category : #'startup - shutdown' }
PirateApp class >> startUp: resuming [
	resuming
		ifFalse: [ ^ self ].
	Socket initializeNetwork.
	Config current initializeFromFile.
	[ self cleanupTorrents ] fork.
	self initMaid.
self lookForUpdates 
]

{ #category : #'upgrading to v5' }
PirateApp class >> updateScript [
	"
		Gofer new
		smalltalkhubUser: 'Gotchas' project: 'TvProgram';
		package: 'ConfigurationOfTvProgram';
		update.
ConfigurationOfTvProgram project development load.
"

	
]

{ #category : #repair }
PirateApp class >> validateState [
	PirateTorrent validateAll.
	PirateEpisode validateAll.
	PirateVideoFile validateAll
]

{ #category : #files }
PirateApp class >> writeToNewFile [
	| stuff fname |
	Transcript
		crShow: 'Writing file'.
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
