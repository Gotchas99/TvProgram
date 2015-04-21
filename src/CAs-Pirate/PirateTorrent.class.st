Class {
	#name : #PirateTorrent,
	#superclass : #PostgresObject,
	#instVars : [
		'name',
		'magnet',
		'torrentHash',
		'seeders',
		'leechers',
		'status',
		'downloaded',
		'videoFiles',
		'folder'
	],
	#classVars : [
		'AllTorrents',
		'DeathRow',
		'Reaper'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateTorrent class >> DeathRow [
	^DeathRow ifNil: [DeathRow:= Set new].
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> allTorrents [ 
	^AllTorrents ifNil: [AllTorrents:= Set new].
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> at: aHash [
	| x |
	"	all := self allInstances."
	x := self allTorrents detect: [ :i | i torrentHash = aHash ] ifNone: [ nil ].
	^ x
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> cleanUpSeedingDone [
	 | delay |
	delay := Delay forSeconds: 10.
	[[DeathRow isEmpty not]	
		whileTrue: [
			DeathRow copy do: [:i | i removeIfSeedComplete].
			delay wait].
		Reaper:=nil]
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> cleanUpSeedingDoneOnce [
	| done |
	done := self DeathRow select: [ :i | i isSeedingComplete ].
	done
		do: [ :i | 
			i removeTorrentAndData.
			DeathRow remove: i ifAbsent: [  ].
			Transcript
				show: 'deleting torrent:' , i name;
				cr.
			GrowlMorph openWithLabel: 'Torrent deleted' contents: i name ]
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> folder [
	| folder  |
	"OSPlatform isUnix ifTrue: [ folder := '/media/cm1store/Torrent/' ].
	OSPlatform isWin32 ifTrue: [ folder := 'O:\Torrent\' ]."
	folder := Config current torrentFolder.
	^folder
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> from: anArrayOf4 [
	^ self new 
		name: anArrayOf4 first ;
		magnet: anArrayOf4 second;
		seeders: anArrayOf4 third;
		leechers: anArrayOf4 fourth;
		yourself.
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> magnet: aMagnetString [
	^ self new
		magnet: aMagnetString;
		yourself
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> new [
	| n |
	n := super new initialize.

	^ n
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> setUpAllTorrents [
	AllTorrents := Set new.
	self allInstances
		do: [ :i | 
			i isInServer
				ifTrue: [ AllTorrents add: i ] ]
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> updateStatuses [
	| allStats notInServer |
	allStats := TransmissionClient current getAll.
	allStats
		do: [ :s | 
			| t |
			t := self at: (s at: #hashString).
			t ifNotNilDo: [ :i | i status: (s at: #status) ] ].
	notInServer := self allTorrents
		reject: [ :t | allStats anySatisfy: [ :each | (each at: #hashString) = t torrentHash ] ].
	notInServer do: [ :t | t status: -1 ]
]

{ #category : #testing }
PirateTorrent >> allVideosSeen [
	videoFiles ifNil: [ ^true ].
	^ videoFiles allSatisfy: [ :f | f isSeen ].
]

{ #category : #'as yet unclassified' }
PirateTorrent >> checkStatus [
	^self status: (TransmissionClient current getStatus: self torrentHash).

]

{ #category : #converting }
PirateTorrent >> createVideoFile [
	| f |
	self isSingleVideoFile
		ifFalse: [ self halt ].
	f := PirateVideoFile new.
	videoFiles := OrderedCollection with: f.
	f
		torrent: self;
		videoFilename: self videoFilenames first;
		folder: self folder.
	^ f
]

{ #category : #converting }
PirateTorrent >> createVideoFiles [
	| f |
	videoFiles := OrderedCollection new.
	self videoFilenames
		do: [ :fname | 
			f := PirateVideoFile new.
			f
				torrent: self;
				videoFilename: fname;
				folder: self folder.
			videoFiles add: f ].
	^ videoFiles
]

{ #category : #accessing }
PirateTorrent >> delete [
	self removeTorrentAndData
]

{ #category : #'as yet unclassified' }
PirateTorrent >> doneWithThis [
	self allVideosSeen
		ifFalse: [ ^ self ].
	(TransmissionClient current isTorrentInServer: self torrentHash)
		ifFalse: [ ^ self ].
	self checkStatus.
	(#(3 4) includes: status)
		ifTrue: [ self delete ]
		ifFalse: [ 
			DeathRow isNil
				ifTrue: [ DeathRow := Set new ].
			DeathRow add: self.
			self startReaper ]
]

{ #category : #'as yet unclassified' }
PirateTorrent >> download [
	TransmissionClient current addTorrent: self magnet uri.
	self class allTorrents add: self
]

{ #category : #accessing }
PirateTorrent >> folder [
	| tmp |
	"^ folder
		ifNil: [" 
			tmp := TransmissionClient current getDir: self torrentHash.
			tmp isEmptyOrNil ifTrue:[^nil].
			tmp := tmp copyReplaceAll: self serverRoot with: self localFolder.
			tmp := tmp copyReplaceAll: self serverRoot2 with: self localFolder.
			tmp := tmp copyReplaceAll: '\' with: '/'.
			tmp := tmp copyReplaceAll: '//' with: '/'.
			(tmp endsWith: '/') ifFalse: [ tmp := tmp ,'/' ].
			OSPlatform isWin32 ifTrue: [ tmp := tmp copyReplaceAll: '/' with: '\'. ].
			folder := tmp.
			 "]"
		^folder
]

{ #category : #testing }
PirateTorrent >> isASample: aFilename size: anInt [
	^ anInt < 50e6

]

{ #category : #testing }
PirateTorrent >> isAVideoFile: aFilename [
	| lastDot ext |
	lastDot := aFilename findLastOccurrenceOfString: '.' startingAt: 1. 
	ext := aFilename copyFrom: lastDot+1 to: aFilename size. 
	^ #( 'mp4' 'avi' 'mkv' 'wmv') includes: ext.

]

{ #category : #testing }
PirateTorrent >> isDownloadComplete [
	^downloaded ifNil: [ downloaded := false ].
	"(downloaded isNil or: [ downloaded not ])
		ifTrue: [ downloaded := TransmissionClient current isComplete: self torrentHash ]	.
	^downloaded."
	"^#(0 5 6) includes: self status"
]

{ #category : #testing }
PirateTorrent >> isDownloaded [
"	downloaded ifNil: [downloaded := false].
	downloaded ifFalse: [
		downloaded := TransmissionClient current isComplete: self torrentHash.].
	^downloaded."
	^#(3 4 5 6) includes: self status
]

{ #category : #testing }
PirateTorrent >> isDownloading [
	^ #(3 4) includes: self status
]

{ #category : #testing }
PirateTorrent >> isInServer [
	^TransmissionClient current isHashInServer: self torrentHash .
]

{ #category : #testing }
PirateTorrent >> isSeedingComplete [
	| times overtime |
	times := self videoFiles collect: [ :vf | vf viewTime ].
	times := times reject: [ :t | t isNil ].
	times isEmpty
		ifTrue: [ overtime := false ]
		ifFalse: [ overtime := times allSatisfy: [ :t | TimeStamp now - t > (Duration days: 45) ] ].
	^ overtime or: [ TransmissionClient current isSeedingComplete: self torrentHash ]
]

{ #category : #testing }
PirateTorrent >> isSingleVideoFile [
	| files |
	files := self videoFilenames.
	(0= files size) ifTrue:[self halt].
	^ (1= files size)
]

{ #category : #accessing }
PirateTorrent >> leechers: anInteger [
	leechers := anInteger 
]

{ #category : #accessing }
PirateTorrent >> localFolder [
	^self class folder
]

{ #category : #accessing }
PirateTorrent >> magnet [
	magnet
		ifNotNilDo: [ :i| 
			magnet class = Magnet
				ifFalse: [ magnet := Magnet from: magnet ] ]
		ifNil: [ 
			self torrentHash ifNil: [ self halt ].
			magnet := Magnet from: (TransmissionClient current getMagnet: self torrentHash) ].
	^ magnet
]

{ #category : #accessing }
PirateTorrent >> magnet: aString [ 
	magnet := Magnet from: aString  
]

{ #category : #accessing }
PirateTorrent >> name [
	name isNil
		ifFalse: [ ^ name ].
	name := TransmissionClient current getTitle: self torrentHash.
	name isNil
		ifFalse: [ ^ name ].
	^ magnet name
]

{ #category : #accessing }
PirateTorrent >> name: aString [
	name := aString 
]

{ #category : #printing }
PirateTorrent >> printOn: aStream [ 
	aStream nextPutAll:  self name
]

{ #category : #'as yet unclassified' }
PirateTorrent >> removeIfSeedComplete [
self halt. "kolla alla videofiler först"
	(self isSeedingComplete or: [ self isInServer not ])
	ifTrue: [
		self removeTorrentAndData.
		DeathRow remove: self ifAbsent: [].
		Transcript show:'deleting torrent:',name;cr] 
]

{ #category : #'as yet unclassified' }
PirateTorrent >> removeTorrentAndData [
	| h |
	videoFiles := nil.
	h := self torrentHash.
	h isEmptyOrNil
		ifTrue: [ ^ self ].	
	TransmissionClient current removeTorrent: h.
	self class allTorrents remove: self	 ifAbsent: [  ]
]

{ #category : #accessing }
PirateTorrent >> seeders: anInteger [
	seeders := anInteger 
]

{ #category : #testing }
PirateTorrent >> serverRoot [
	^TransmissionClient current getDownloadDir
]

{ #category : #testing }
PirateTorrent >> serverRoot2 [
	^'/media/store2tb/Torrent'
]

{ #category : #'as yet unclassified' }
PirateTorrent >> startReaper [
	| delay |
	Reaper isNil
		ifFalse: [ self stopReaper ].
	delay := Delay forSeconds: 10.
	Reaper := [ 
	[ DeathRow isEmpty not ]
		whileTrue: [ 
			self class cleanUpSeedingDoneOnce.
			delay wait ].
	Reaper := nil ] newProcess.
	Reaper
		priority: Processor userBackgroundPriority;
		name: #reaper;
		resume
]

{ #category : #accessing }
PirateTorrent >> status [
	^status ifNil: [-1]
]

{ #category : #accessing }
PirateTorrent >> status: anInt [
	status = anInt
		ifFalse: [ 
			status := anInt.
			downloaded := false.
			(#(5 6) includes: status)
				ifTrue: [ downloaded := true ].
			(#(0) includes: status)
				ifTrue: [ downloaded := (TransmissionClient current getTotalSize: self torrentHash) > 0 ].
			downloaded
				ifTrue: [ [ self videoHash ] forkAt: Processor userBackgroundPriority ] ].
	^ status
]

{ #category : #'as yet unclassified' }
PirateTorrent >> stopReaper [
	Reaper isNil ifTrue: [^self].
	Reaper terminate.
	Reaper := nil.
]

{ #category : #accessing }
PirateTorrent >> torrentHash [
	| m |
	torrentHash ifNotNil: [ ^ torrentHash ].
	m := self magnet.
	m isNil
		ifTrue: [ 
			self halt.
			^ '' ].
	torrentHash := m infoHash.
	^ torrentHash
]

{ #category : #accessing }
PirateTorrent >> torrentHash: aHash [
	torrentHash := aHash asLowercase.

]

{ #category : #'to_videofile' }
PirateTorrent >> videoFilename [
| files max fname |
self halt.
	files:= TransmissionClient current getFiles: self torrentHash.
	files isEmptyOrNil ifTrue: [^nil].
	max:=0.
	files do: [:f| (f at: #length)>max ifTrue: [fname:= f at: #name. max:=f at: #length]].
	^ self folder , fname.

]

{ #category : #'as yet unclassified' }
PirateTorrent >> videoFilenames [
	| files fnames |
"	videoFiles ifNotNil: [ ^videoFiles  ]."
	files:= TransmissionClient current getFiles: self torrentHash.
	files isEmptyOrNil ifTrue: [^#()].
	files := files select: [:f| self isAVideoFile: (f at: 'name')].
	files := files reject: [ :f | self isASample: (f at: 'name') size: (f at: 'length')].
	fnames := files collect: [ :file| file at: 'name' ].
	^ fnames sort.
]

{ #category : #accessing }
PirateTorrent >> videoFiles [
	^videoFiles ifNil: [ self createVideoFiles ]
]

{ #category : #accessing }
PirateTorrent >> videoHash [
	self videoFiles do: [ :vf | vf videoHash].
]