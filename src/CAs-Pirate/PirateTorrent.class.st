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
		'AllStatus',
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
	| done gone |
	done := self DeathRow select: [ :i | i isSeedingComplete ].
	gone := Set new.
	done
		do: [ :i | 
			i removeTorrentAndData.
			gone add: i.
			Transcript crShow: 'deleting torrent:' , i name.
			GrowlMorph openWithLabel: 'Torrent deleted' contents: i name ].
	DeathRow removeAllFoundIn: gone
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> folder [
	| folder |
	folder := Config current torrentFolder.
	^ folder
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
PirateTorrent class >> resetFolder [
	self allTorrents do: #resetFolder.
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
	| allStats  |
	allStats := TransmissionClient current getAll.
	AllStatus := Dictionary new.
	allStats do: [ :s | AllStatus at: (s at: 'hashString') put: (s at: 'status') ].
	PirateShow allEpisodes
		reject: [ :e | e torrent isNil ]
		thenDo: [ :e | e torrent status: (AllStatus at: e torrent torrentHash ifAbsent: [ -1 ]) ]
	
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> updateStatuses_old [
	|  notInServer |
	AllStatus := TransmissionClient current getAll.
	AllStatus
		do: [ :s | 
			| t |
			t := self at: (s at: #hashString).
			t ifNotNil: [ :i | i status: (s at: #status) ] ].
	notInServer := self allTorrents
		reject: [ :t | AllStatus anySatisfy: [ :each | (each at: #hashString) = t torrentHash ] ].
	notInServer do: [ :t | t status: -1 ]
]

{ #category : #'as yet unclassified' }
PirateTorrent class >> validateAll [
	| inValids |
	Transcript crShow: 'Validating torrents.'.
	self allTorrents do: [ :t | t validate ].
	inValids := self allTorrents reject: [ :t | t isValid ].
	inValids
		do: [ :t | 
			Transcript crShow: 'Removing torrent (not in server): ' , t name.
			t removeTorrentAndData ]
]

{ #category : #accessing }
PirateTorrent >> <= aTorrent [
	self species == aTorrent species
		ifTrue: [ ^ self name caseInsensitiveLessOrEqual: aTorrent name ]
		ifFalse: [ ^ false ]
]

{ #category : #accessing }
PirateTorrent >> = aTorrent [
	^ self species == aTorrent species and: [ self magnet = (PirateTorrent asTorrent: aTorrent) magnet ]
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
"	self containsRarFile
		ifTrue: [ 
			self inform: self name , ' is a RAR-file'.
			self crTrace: self name , ' is a RAR-file'.
			^ nil ]."
	vf :=
	self videoFilenames
		collect: [ :fname | 
			f := PirateVideoFile new.
			f
				videoFilename: fname;
				folder: self folder.
			 f ].
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
			"Not needed anymore: self startReaper" ]
]

{ #category : #'as yet unclassified' }
PirateTorrent >> download [
	TransmissionClient current addTorrent: self magnet uri.
	self class allTorrents add: self
]

{ #category : #accessing }
PirateTorrent >> folder [
	| tmp |
	tmp := TransmissionClient current getDir: self torrentHash.
	tmp isEmptyOrNil
		ifTrue: [ ^ nil ].
	tmp := tmp asPath.
	tmp := tmp relativeToPath: self serverRoot asPath.
	tmp := PirateTorrent folder asPath resolve: tmp.
	tmp := tmp asFileReference pathString.	"tmp := TransmissionClient current getDir: self torrentHash.
			tmp isEmptyOrNil ifTrue:[^nil].
			tmp := tmp copyReplaceAll: self serverRoot with: self localFolder.
			tmp := tmp copyReplaceAll: self serverRoot2 with: self localFolder.
			tmp := tmp copyReplaceAll: '\' with: '/'.
			tmp := tmp copyReplaceAll: '//' with: '/'.
			(tmp endsWith: '/') ifFalse: [ tmp := tmp ,'/' ].
			Smalltalk os isWin32 ifTrue: [ tmp := tmp copyReplaceAll: '/' with: '\'. ]."
	folder := tmp.
	^ folder
]

{ #category : #testing }
PirateTorrent >> isARarFile: aFilename [
	| ext |
	ext := (Path from: aFilename) extension asLowercase.
	^ ext = 'rar'
]

{ #category : #testing }
PirateTorrent >> isASample: aFilename size: anInt [
	^ anInt < 80e6
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
	
	self isInServer
		ifFalse: [ ^ false ].
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
		ifNotNil: [ :i | 
			magnet class = Magnet
				ifFalse: [ magnet := Magnet from: magnet ] ]
		ifNil: [ self torrentHash ifNil: [ self halt ].
			magnet := Magnet
				from: (TransmissionClient current getMagnet: self torrentHash) ].
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

{ #category : #OBSOLETE }
PirateTorrent >> removeIfSeedComplete [
self halt. "kolla alla videofiler först"
	(self isSeedingComplete or: [ self isInServer not ])
	ifTrue: [
		self removeTorrentAndData.
		DeathRow remove: self ifAbsent: [].
		Transcript crShow:'deleting torrent:',name] 
]

{ #category : #'as yet unclassified' }
PirateTorrent >> removeTorrentAndData [
	| h |
	videoFiles
		ifNotNil: [ videoFiles do: [ :vf | vf disconnect ].
			videoFiles := nil ].
	h := self torrentHash.
	h isEmptyOrNil
		ifFalse: [ [ TransmissionClient current removeTorrent: h .self class allTorrents remove: self ifAbsent: [  ]] fork ].
	
]

{ #category : #converting }
PirateTorrent >> resetFolder [
	videoFiles ifNotNil: [ :vfs | vfs do: [ :vf | vf folder: self folder ] ]
]

{ #category : #accessing }
PirateTorrent >> seeders: anInteger [
	seeders := anInteger 
]

{ #category : #'as yet unclassified' }
PirateTorrent >> serverRoot [
	^TransmissionClient current getDownloadDir
]

{ #category : #OBSOLETE }
PirateTorrent >> serverRoot2 [
	^'/media/store2tb/Torrent'
]

{ #category : #OBSOLETE }
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

{ #category : #OBSOLETE }
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

{ #category : #validation }
PirateTorrent >> validate [
	| invalidVf |
	self isInServer
		ifFalse: [ ^ self ].
	videoFiles ifNil: [ ^ self ].
 invalidVf := videoFiles reject: [ :f | f isValid ].
			invalidVf do: [ :f | f disconnect ].
			videoFiles := videoFiles select: [ :f | f isValid ].
			videoFiles isEmpty
				ifTrue: [ videoFiles := nil ] 
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
	files size > 1
		ifTrue: [ files := files reject: [ :f | self isASample: (f at: 'name') size: (f at: 'length') ] ].
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
