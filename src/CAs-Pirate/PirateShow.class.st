Class {
	#name : #PirateShow,
	#superclass : #PostgresObject,
	#instVars : [
		'name',
		'seasons',
		'currentSeason',
		'archived',
		'tags',
		'eztv',
		'imdb',
		'tmdb',
		'kat'
	],
	#classVars : [
		'Shows'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateShow class >> at: aTitle [
	^self shows detect: [ :s | s name = aTitle ]
]

{ #category : #files }
PirateShow class >> fileName [
	| folder fileName |
	"OSPlatform isUnix ifTrue: [ folder := '/media/cm1store/' ].
	OSPlatform isWin32 ifTrue: [ folder := 'O:\' ]."
	folder := Config current torrentFolder.
	fileName := folder, 	'/TVshows'.
	^fileName
]

{ #category : #'initialize-release' }
PirateShow class >> initialize [ 
	super initialize .
	self initializeStartupShutdown.
]

{ #category : #'initialize-release' }
PirateShow class >> initializeStartupShutdown [
"	Not used in startup anymore. moved to new class PirateApp 
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self."

]

{ #category : #'as yet unclassified' }
PirateShow class >> new [
	| n |
	n := super new.
	self shows add: n.
	^n.
]

{ #category : #temporary }
PirateShow class >> reSort [
	self shows reSort.
	^self
]

{ #category : #files }
PirateShow class >> readFromFile [
	Shows := FLMaterializer materializeFromFileNamed: (self fileName,'.fuel').
	Transcript show: 'File read'; cr.

]

{ #category : #files }
PirateShow class >> readFromFileSTON [
	"	Shows := FLMaterializer materializeFromFileNamed: self fileName."

	(self fileName , '.ston') asFileReference
		readStreamDo: [ :stream | Shows := STON fromStream: stream ].
	Transcript
		show: 'File read from STON';
		cr
]

{ #category : #'as yet unclassified' }
PirateShow class >> removeShow: aShow [
	Shows isNil
		ifFalse: [ 
			aShow delete.
			Shows remove: aShow ].
	^ self
]

{ #category : #'as yet unclassified' }
PirateShow class >> reset [
	Shows := nil.
]

{ #category : #temporary }
PirateShow class >> resetEpisodeStatus [
	|  myShows |
	myShows := self shows.
	myShows do: [ 
		:sh | sh seasons do: [
			:season | season episodes do: [
				:episode | episode resetFileAndStatus.
				]
			] 
		]
]

{ #category : #temporary }
PirateShow class >> resetUplinks [
	|  myShows |
	myShows := self shows.
	myShows do: [ 	:sh | sh resetUplinks]
]

{ #category : #'as yet unclassified' }
PirateShow class >> shows [
	Shows isNil ifTrue: [Shows := SortedCollection new].
	^Shows
]

{ #category : #'as yet unclassified' }
PirateShow class >> shutDown: quitting [
	self deprecated: 'Moved to PirateApp'
]

{ #category : #'as yet unclassified' }
PirateShow class >> startUp: resuming [
	self deprecated: 'Moved to PirateApp'
]

{ #category : #'as yet unclassified' }
PirateShow class >> validateAll [
	PirateEpisode validateAll.
	PirateVideoFile validateAll
]

{ #category : #files }
PirateShow class >> writeToFile [
	FLSerializer serialize: self shows toFileNamed: self fileName,'.fuel'.
	Transcript show: 'File written'; cr.
	GrowlMorph openWithLabel: 'File written' contents: ''.
]

{ #category : #files }
PirateShow class >> writeToFileBG [
	[self writeToFile ] forkAt: Processor userBackgroundPriority .

]

{ #category : #files }
PirateShow class >> writeToFileSTON [
	"FLSerializer serialize: self shows toFileNamed: self fileName."
	(self fileName , '.ston') asFileReference writeStreamDo: 
		[ :stream | STON put: self shows onStream: stream ].
	Transcript
		show: 'File written to STON';
		cr.
	GrowlMorph openWithLabel: 'File written' contents: 'to STON'
]

{ #category : #comparing }
PirateShow >> <= aPirateShow [ 
	^(self name) caseInsensitiveLessOrEqual: (aPirateShow name).
]

{ #category : #'as yet unclassified' }
PirateShow >> addSeason [
	| newSeason |
	newSeason := PirateSeason new.
	newSeason id: (self maxSeason + 1) asTwoCharacterString.
	self addSeason: newSeason.
	^ newSeason
]

{ #category : #'as yet unclassified' }
PirateShow >> addSeason: aSeason [ 
	seasons add: aSeason.
	aSeason show: self
]

{ #category : #accessing }
PirateShow >> addTag: aString [
	self tags addIfNotPresent: aString 
]

{ #category : #accessing }
PirateShow >> archived [
	^ archived ifNil: [ archived := false ]
]

{ #category : #accessing }
PirateShow >> archived: aBool [
	archived:= aBool .
]

{ #category : #accessing }
PirateShow >> currentSeason [
	^currentSeason
]

{ #category : #accessing }
PirateShow >> currentSeason: aSeason [
	currentSeason := aSeason
]

{ #category : #'as yet unclassified' }
PirateShow >> delete [
	seasons do: [:s| s delete].
]

{ #category : #deprecated }
PirateShow >> eztv [
	^ eztv
]

{ #category : #deprecated }
PirateShow >> eztv: anIdString [
	eztv := anIdString 
]

{ #category : #accessing }
PirateShow >> imdb [
	^ imdb
]

{ #category : #accessing }
PirateShow >> imdb: anObject [
	 imdb :=anObject isEmptyOrNil
		ifTrue: [ nil ]
		ifFalse: [ anObject ]
]

{ #category : #'initialize-release' }
PirateShow >> initialize [
	super initialize.
	seasons := SortedCollection new.
]

{ #category : #accessing }
PirateShow >> kat [
	^ kat
]

{ #category : #accessing }
PirateShow >> kat: anObject [
	kat := anObject isEmptyOrNil
		ifTrue: [ nil ]
		ifFalse: [ anObject ]
]

{ #category : #'as yet unclassified' }
PirateShow >> lookForAll [
	^ seasons
		do: [:i | i lookForAll]
]

{ #category : #'as yet unclassified' }
PirateShow >> maxSeason [
	"(Array with: '11' asInteger with: '12' asInteger )max ."
	| ids |
	seasons isEmptyOrNil
		ifTrue: [^ 0].
	ids := seasons
				collect: [:e | e id asInteger].
	^ ids max
]

{ #category : #accessing }
PirateShow >> name [
	name isNil ifTrue: [^'undefined'].
	^name
]

{ #category : #accessing }
PirateShow >> name: aByteString [ 
	name := aByteString.
	self class reSort.
]

{ #category : #'as yet unclassified' }
PirateShow >> newEpisode [
	| model |
	model := OrderedCollection new.
	seasons 
		do: [:season| model addAll: (season episodes select: [:e| e newFound] )].
	model isEmpty 
		ifTrue: [^ nil ]
		ifFalse: [^ model first ].
	
]

{ #category : #'as yet unclassified' }
PirateShow >> newEpisodeCount [
	| sum |
	sum := 0.
	seasons
		do: [:s | sum:=sum+(s newFound size)
				].
	^ sum
]

{ #category : #'as yet unclassified' }
PirateShow >> newFound [
	^ seasons
		collect: [:i | i newFound]
]

{ #category : #'as yet unclassified' }
PirateShow >> nextEpisode [
	| model |
	model := OrderedCollection new.
	seasons 
		do: [:season| model addAll: (season episodes select: [:e| e isViewable] )].
	model isEmpty 
		ifTrue: [^ nil ]
		ifFalse: [^ model first ].
	
]

{ #category : #'as yet unclassified' }
PirateShow >> nextNeedsTorrent [
	| model |
	model := OrderedCollection new.
	seasons do: [ :season | model addAll: (season episodes select: [ :e | e needsTorrent ]) ].
	model isEmpty
		ifTrue: [ ^ nil ]
		ifFalse: [ ^ model first ]
]

{ #category : #'as yet unclassified' }
PirateShow >> notSeenCount [
	| sum |
	sum := 0.
	seasons
		do: [:s | sum:=sum+(s notSeen size)
				].
	^ sum
]

{ #category : #special }
PirateShow >> printOn: aStream [ 
	aStream nextPutAll: (self name contractTo: 45)
]

{ #category : #special }
PirateShow >> resetUplinks [
	^ seasons
		do: [:i | i resetUplinks: self]
]

{ #category : #accessing }
PirateShow >> seasons [
	^seasons
]

{ #category : #'as yet unclassified' }
PirateShow >> setEpisodesFromEztv [
	| dict s s_no season |
	self eztv ifNil: [ ^ self ].
	dict := Eztv new getEpisodes: self eztv.
	dict keys sorted
		do: [ :key | 
			s_no := key asTwoCharacterString.
			s := seasons select: [ :each | each id = s_no ].
			season:=s at:1 ifAbsent:[  self addSeason ].
				
			season addEpisodes: (dict at: key) ]
]

{ #category : #'as yet unclassified' }
PirateShow >> setEpisodesFromTmdb [
	| dict s s_no season |
	self tmdb
		ifNil: [ 
			self imdb ifNil: [ ^ self ].
			self tmdb: (TheMovieDb new getTmdbFromImdb: self imdb) ].
	dict := TheMovieDb new getEpisodes: self tmdb.
	dict keys sorted
		do: [ :key | 
			s_no := key asTwoCharacterString.
			s := seasons select: [ :each | each id = s_no ].
			season := s at: 1 ifAbsent: [ self addSeason ].
			season addEpisodes: (dict at: key) ]
]

{ #category : #accessing }
PirateShow >> tags [
	^ tags ifNil: [ tags := SortedCollection new ]
]

{ #category : #accessing }
PirateShow >> tmdb [
	^ tmdb
]

{ #category : #accessing }
PirateShow >> tmdb: anObject [
	tmdb := anObject
]

{ #category : #'as yet unclassified' }
PirateShow >> tpbString [
	"tpb = The Pirate Bay"
	^self name, '%20', (self nextEpisode)
]
