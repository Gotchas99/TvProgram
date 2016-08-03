Class {
	#name : #PirateTorrent,
	#superclass : #Object,
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
PirateTorrent class >> DeathRow: aSet [
	DeathRow := aSet
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> allTorrents [ 
	^AllTorrents ifNil: [AllTorrents:= Set new].
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> allTorrents: aSet [
	AllTorrents := aSet
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> asTorrent: aPossibleTorrent [
	"Accepts a PirateTorrent or an array of 4 items (see from: ) "

	aPossibleTorrent ifNil: [ ^ nil ].
	aPossibleTorrent class = PirateTorrent
		ifTrue: [ ^ aPossibleTorrent ].
	aPossibleTorrent = PirateTorrent
		ifTrue: [ ^ nil ].
	aPossibleTorrent isString
		ifTrue: [ 
			^ {'???'.
			aPossibleTorrent.
			0.
			0} ].	"assumed to be a Magnet string"
	^ PirateTorrent from: aPossibleTorrent
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> at: aHash [
	| x |
	"	all := self allInstances."
	x := self allTorrents detect: [ :i | i torrentHash = aHash ] ifNone: [ nil ].
	^ x
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> atAllInstances: aHash [
	| x all |
	all := self allInstances.
	x := all detect: [ :i | i torrentHash = aHash ] ifNone: [ nil ].
	^ x
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> cleanUpSeedingDoneOnce [
	| done |
	done := self DeathRow select: [ :i | i isInServer not or: [ i isSeedingComplete ] ].
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
	| t hasTorrent all inServer |
	all := Set new.
	hasTorrent := PirateShow allEpisodes select: [ :ep | ep torrent isNotNil ].
	hasTorrent do: [ :ep | ep torrent checkStatus ].
	inServer := hasTorrent
		select: [ :item | 
			t := item torrent.
			t isInServer ].
	inServer
		do: [ :ep | 
			t := ep torrent.
			ep isViewed
				ifTrue: [ t doneWithThis ]
				ifFalse: [ all add: t ] ].
	self allTorrents: all
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

{ #category : #'as yet unclassified' }
PirateTorrent class >> validateAll [
	|  inValids |
	Transcript crShow: 'Validating torrents.'.
	inValids := self allTorrents reject: [ :t | t isValid ].
	inValids 
		do: [ :t | 
			Transcript crShow: 'Removing torrent (not in server): ' , t name.
			t removeTorrentAndData ]
]

{ #category : #accessing }
PirateTorrent >> = aTorrent [
	aTorrent ifNil: [ ^ false ].
	^ self magnet infoHash = (PirateTorrent asTorrent: aTorrent) magnet infoHash
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

{ #category : #testing }
PirateTorrent >> containsRarFile [
	| files |
	files := TransmissionClient current getFiles: self torrentHash.
	files isEmptyOrNil
		ifTrue: [ ^ false ].
	^ files anySatisfy: [ :f | self isARarFile: (f at: 'name') ]
]

{ #category : #converting }
PirateTorrent >> createVideoFiles [
	| f vf |
	self isDownloadComplete
		ifFalse: [ ^ nil ].
	self containsRarFile
		ifTrue: [ 
			self inform: self name , ' is a RAR-file'.
			self log: self name , ' is a RAR-file'.
			^ nil ].
	vf := OrderedCollection new.
	self videoFilenames
		do: [ :fname | 
			f := PirateVideoFile new.
			f
				videoFilename: fname;
				folder: self folder.
			vf add: f ].
	^ videoFiles := vf
]

{ #category : #accessing }
PirateTorrent >> delete [
	self removeTorrentAndData
]

{ #category : #'as yet unclassified' }
PirateTorrent >> doneWithThis [
	self allVideosSeen
		ifFalse: [ ^ self ].
	self isInServer
		ifFalse: [ ^ self ].
	self checkStatus.
	(#(3 4) includes: status)
		ifTrue: [ self delete ]
		ifFalse: [ 
			self class DeathRow add: self.
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
			Smalltalk os isWin32 ifTrue: [ tmp := tmp copyReplaceAll: '/' with: '\'. ].
			folder := tmp.
			 "]"
		^folder
]

{ #category : #testing }
PirateTorrent >> isARarFile: aFilename [
	| ext |
	ext := (Path from: aFilename) extension asLowercase.
	^ ext = 'rar'
]

{ #category : #testing }
PirateTorrent >> isASample: aFilename size: anInt [
	^ anInt < 40e6

]

{ #category : #testing }
PirateTorrent >> isAVideoFile: aFilename [
	| ext |
	ext := (Path from: aFilename) extension asLowercase.
	^ #('mp4' 'avi' 'mkv' 'wmv') includes: ext
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
PirateTorrent >> isDownloading [
	^ #(3 4) includes: self status
]

{ #category : #testing }
PirateTorrent >> isInServer [
	^TransmissionClient current isHashInServer: self torrentHash .
]

{ #category : #testing }
PirateTorrent >> isSeedingComplete [
	| times overtime files |
	self isInServer
		ifFalse: [ ^ true ].
	files := self videoFiles.
	files ifNil: [ ^ true ].
	times := files collect: [ :vf | vf viewTime ].
	times := times reject: [ :t | t isNil ].
	times isEmpty
		ifTrue: [ overtime := false ]
		ifFalse: [ overtime := times allSatisfy: [ :t | DateAndTime now - t > (Duration days: 45) ] ].
	^ overtime or: [ TransmissionClient current isSeedingComplete: self torrentHash ]
]

{ #category : #testing }
PirateTorrent >> isSingleVideoFile [
	| files |
	files := self videoFiles.
	files ifNil: [ ^false ].
"	0 = files size
		ifTrue: [ self halt ]."
	^ 1 = files size
]

{ #category : #testing }
PirateTorrent >> isValid [
	| invalidVf |
	self isInServer
		ifFalse: [ ^ false ].
	videoFiles
		ifNotNil: [ 
			invalidVf := videoFiles reject: [ :f | f isValid ].
			invalidVf
				do: [ :f | 
					videoFiles remove: f.
					f disconnect ].
			videoFiles isEmpty
				ifTrue: [ videoFiles := nil ] ].
	^ true
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
	name ifNotNil: [ ^ name ].
	name := TransmissionClient current getTitle: self torrentHash.
	name ifNotNil: [ ^ name ].
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
	videoFiles
		ifNotNil: [ 
			videoFiles do: [ :vf | vf disconnect ].
			videoFiles := nil ].
	h := self torrentHash.
	h isEmptyOrNil
		ifFalse: [ TransmissionClient current removeTorrent: h ].
	self class allTorrents remove: self ifAbsent: [  ]
]

{ #category : #accessing }
PirateTorrent >> seeders: anInteger [
	seeders := anInteger 
]

{ #category : #'as yet unclassified' }
PirateTorrent >> serverRoot [
	^TransmissionClient current getDownloadDir
]

{ #category : #'as yet unclassified' }
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
			(#(-1) includes: status)
				ifTrue: [ self removeTorrentAndData ].
			(#(0) includes: status)
				ifTrue: [ 
					(TransmissionClient current isDownloadComplete: self torrentHash)
						ifTrue: [ downloaded := true ]
						ifFalse: [ 
							"paused. this state is not in transmission, only here"
							status := 7.
							downloaded := false ] ].
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

{ #category : #accessing }
PirateTorrent >> videoFile [
	| vf |
	vf := self videoFiles.
	vf size = 1
		ifTrue: [ ^ vf first ]
		ifFalse: [ 
			"self halt "
			^ nil ]
]

{ #category : #accessing }
PirateTorrent >> videoFilenames [
	| files fnames |
	"	videoFiles ifNotNil: [ ^videoFiles  ]."
	files := TransmissionClient current getFiles: self torrentHash.
	files isEmptyOrNil
		ifTrue: [ ^ #() ].
	files := files select: [ :f | self isAVideoFile: (f at: 'name') ].
	files := files reject: [ :f | self isASample: (f at: 'name') size: (f at: 'length') ].
	fnames := files collect: [ :file | file at: 'name' ].
	^ fnames sort
]

{ #category : #accessing }
PirateTorrent >> videoFiles [
	^videoFiles ifNil: [ self createVideoFiles ]
]

{ #category : #accessing }
PirateTorrent >> videoHash [
	self videoFiles do: [ :vf | vf videoHash].
]
