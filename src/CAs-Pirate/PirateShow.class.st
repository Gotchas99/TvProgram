Class {
	#name : #PirateShow,
	#superclass : #Object,
	#instVars : [
		'name',
		'seasons',
		'currentSeason',
		'archived',
		'in_production',
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

{ #category : #files }
PirateShow class >> allEpisodes [
	| ep sh |
	sh := self shows reject: [ :s | s archived ].
	ep := sh collect: [ :s | s allEpisodes ].
	^ ep flattened
]

{ #category : #files }
PirateShow class >> allViewableEpisodes [
	| ep |
	ep := self allEpisodes select: [ :e | e isViewable ].
	^ ep
]

{ #category : #'as yet unclassified' }
PirateShow class >> at: aTitle [
	^self shows detect: [ :s | s name = aTitle ]
]

{ #category : #'as yet unclassified' }
PirateShow class >> checkInProduction [
	| s tmdb delay |
	delay := Delay forSeconds: 5.
	self setTmdbId.
	tmdb := TheMovieDb new.
	s := PirateShow shows select: [ :sh | sh tmdb isNotNil ].
	s
		do: [ :sh | 
			sh in_production: (tmdb isInProduction: sh tmdb).
			delay wait ]
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
	self shows
		do: [ :sh | 
			sh seasons reSort.
			sh seasons do: [ :seas | seas episodes reSort ] ].
	^ self
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
PirateShow class >> setEpisodesFromTmdb [
	| s tmdb delay |
	delay := Delay forSeconds: 5.
	self setTmdbId.
	tmdb := TheMovieDb new.
	s := PirateShow shows select: [ :sh | sh tmdb isNotNil ].
	s
		do: [ :sh | 
			sh setEpisodesFromTmdb.
			delay wait ]
]

{ #category : #temporary }
PirateShow class >> setFullId [
	PirateShow shows do: [ :show | show seasons do: [ :seas | seas setFullId ] ].
	PirateShow allEpisodes do: [ :each | each setFullId ]
]

{ #category : #temporary }
PirateShow class >> setSortedCollections [
	PirateShow shows do: [ :show | show setSortedCollection ]
]

{ #category : #'as yet unclassified' }
PirateShow class >> setTmdbId [
	| s tmdb i delay |
	delay := Delay forSeconds: 5.
	tmdb := TheMovieDb new.
	s := PirateShow shows select: [ :sh | sh in_production ].
	i := s select: [ :sh | sh imdb isNotNil ].
	i := i select: [ :sh | sh tmdb isNil ].
	i
		do: [ :sh | 
			sh tmdb: (tmdb getTmdbFromImdb: sh imdb).
			delay wait ]
]

{ #category : #'as yet unclassified' }
PirateShow class >> shows [
	Shows isNil ifTrue: [Shows := SortedCollection new].
	^Shows
]

{ #category : #'as yet unclassified' }
PirateShow class >> shows: aShowList [
	Shows := aShowList
]

{ #category : #'as yet unclassified' }
PirateShow class >> shutDown: quitting [
	self deprecated: 'Moved to PirateApp'
]

{ #category : #'as yet unclassified' }
PirateShow class >> startUp: resuming [
	self deprecated: 'Moved to PirateApp'
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
	self species == aPirateShow species
		ifTrue: [ ^ self name caseInsensitiveLessOrEqual: aPirateShow name ]
		ifFalse: [ ^ false ]
]

{ #category : #'as yet unclassified' }
PirateShow >> addSeason [
	| newSeasonId |
	newSeasonId := self maxSeason + 1.
	^ self addSeasonNo: newSeasonId
]

{ #category : #'as yet unclassified' }
PirateShow >> addSeason: aSeason [
	aSeason show: self.
	(seasons isKindOf: SortedCollection)
		ifFalse: [ seasons := seasons asSortedCollection ].
	seasons add: aSeason.
	seasons reSort
]

{ #category : #'as yet unclassified' }
PirateShow >> addSeasonNo: aSeasonNumber [
	| newSeason |
	aSeasonNumber isNumber ifTrue:[aSeasonNumber:=aSeasonNumber asTwoCharacterString].
	newSeason := PirateSeason new.
	newSeason id: aSeasonNumber.
	self addSeason: newSeason.
	^ newSeason
]

{ #category : #accessing }
PirateShow >> addTag: aString [
	self tags addIfNotPresent: aString 
]

{ #category : #'as yet unclassified' }
PirateShow >> allEpisodes [
	| ep |
	ep := seasons collect: [ :s | s episodes ].
	^ ep flattened
]

{ #category : #accessing }
PirateShow >> archived [
	^ archived ifNil: [ archived := false ]
]

{ #category : #accessing }
PirateShow >> archived: aBool [
	archived:= aBool .
]

{ #category : #'as yet unclassified' }
PirateShow >> currentSeason [
	| next |
	next := self nextEpisode.
	next ifNil: [ ^ nil ].
	^ next season
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
PirateShow >> imdb: aString [
	"can accept a full url, an id like tt2741602, 
	or just the numeric part like 2741602 in the previous example"

	aString isEmptyOrNil
		ifTrue: [ ^ imdb := nil ]
		ifFalse: [ 
			(aString beginsWith: 'http')
				ifTrue: [ ^ imdb := aString asUrl segments at: 2 ].
			(aString beginsWith: 'tt')
				ifTrue: [ ^ imdb := aString ].
			aString isAllDigits
				ifTrue: [ ^ imdb := 'tt' , aString ] ]
]

{ #category : #accessing }
PirateShow >> in_production [
	^ in_production ifNil: [ ^ true ]
]

{ #category : #accessing }
PirateShow >> in_production: aBoolean [
	in_production := aBoolean
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
PirateShow >> lastSeen [
	| seen |
	seen := self allEpisodes select: [ :e | e isViewed ].
	seen isEmpty
		ifTrue: [ ^ nil ]
		ifFalse: [ ^ seen last ]
]

{ #category : #'as yet unclassified' }
PirateShow >> lookForAll [
	"^ seasons
		do: [:i | i lookForAll]"

	| unseen first episodesToDownload |
	episodesToDownload := 10.
	unseen := self allEpisodes reject: [ :e | e isViewed ].
	first := unseen first: (episodesToDownload min: unseen size).
	first do: [ :e | e lookForItIfNotFound ]
]

{ #category : #accessing }
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
PirateShow >> nextToSee [
	| notSeen |
	notSeen := self allEpisodes reject: [ :each | each isViewed ].
	notSeen isEmptyOrNil
		ifTrue: [ ^ nil ]
		ifFalse: [ ^notSeen first ]	"last := self lastSeen.
	last ifNil: [ ^ self allEpisodes first ] ifNotNil: [ ^ self allEpisodes after: last ifAbsent: [ nil ] ]"
]

{ #category : #'as yet unclassified' }
PirateShow >> notSeenCount [
	| sum |
	sum := 0.
	seasons do: [ :s | sum := sum + s notSeen size ].
	^ sum
]

{ #category : #special }
PirateShow >> printOn: aStream [ 
	aStream nextPutAll: (self name contractTo: 45)
]

{ #category : #'as yet unclassified' }
PirateShow >> removeSeason: aSeason [
	seasons remove: aSeason.
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

{ #category : #deprecated }
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
			season := s at: 1 ifAbsent: [ self addSeasonNo: key ].
			season addEpisodes: (dict at: key) ]
]

{ #category : #special }
PirateShow >> setSortedCollection [
	seasons := seasons asSortedCollection.
	^ seasons do: [ :i | i setSortedCollection ]
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
