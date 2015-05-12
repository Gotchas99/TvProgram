Class {
	#name : #PirateVideo,
	#superclass : #PostgresObject,
	#instVars : [
		'id',
		'torrent',
		'falseTorrents',
		'location',
		'subTitle',
		'viewed',
		'torrents',
		'videoFile'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateVideo class >> getAllSubtitles [
	| needsSubs delay viewables |
	delay := Delay forSeconds: 5.	"self halt."
	viewables := self allSubInstances select: [ :ep | ep isViewable ].
	needsSubs := viewables select: [ :ep | ep hasSubtitle not ].
	needsSubs
		do: [ :ep | 
			ep topSubtitles.
			delay wait ]
]

{ #category : #'as yet unclassified' }
PirateVideo class >> validateAllTorents [
	PirateShow shows do: [ :s | 
		s seasons do: [ :sea | 
			sea episodes do: [ :e | 
				e validateTorrent ] ] ]
]

{ #category : #torrents }
PirateVideo >> addFalseTorrent: aTorrentArray [
	self falseTorrents add: aTorrentArray.

]

{ #category : #obsolete }
PirateVideo >> convertTorrent [
	torrent class = PirateTorrent ifTrue: [^self ] .
	torrent = PirateTorrent ifTrue: [^torrent:=nil ] .
	torrent isString 
		ifTrue: [torrent:={'???'. torrent. 0. 0}].
	torrent := PirateTorrent from: torrent.
]

{ #category : #'as yet unclassified' }
PirateVideo >> delete [
	self deleteSubtitles.
	torrent isNil ifFalse: [torrent delete].
]

{ #category : #subtitles }
PirateVideo >> deleteSubtitles [
	| srtName fname fs |
	self videoFile
		ifNotNil: [ 
			fname := self videoFile fullVideoFilename.
			fname
				ifNotNil: [ 
					srtName := OpenSubClient new srtFromVideo: fname.
					fs := FileDirectory forFileName: srtName.
					fs deleteFileNamed: srtName ] ].
	subTitle := nil
]

{ #category : #torrents }
PirateVideo >> download [
	torrent isNil
		ifTrue: [ ^ self ].
	self torrent download
]

{ #category : #torrents }
PirateVideo >> falseTorrents [
	falseTorrents isNil
		ifTrue: [falseTorrents := OrderedCollection new].
	^ falseTorrents
]

{ #category : #torrents }
PirateVideo >> found [
	^(self isViewed) or: [(self torrents isEmpty not) or: [videoFile isNil not]].
		
]

{ #category : #torrents }
PirateVideo >> getTopTorrent [
	torrent := self torrents first.
	self download
]

{ #category : #torrents }
PirateVideo >> getTorrents [
	self subclassResponsibility 
]

{ #category : #subtitles }
PirateVideo >> hasSubtitle [
	^ (subTitle isNil not)
]

{ #category : #'as yet unclassified' }
PirateVideo >> icon [
	^ nil
]

{ #category : #accessing }
PirateVideo >> id [
	id isNil
		ifTrue: [^ 'undefined'].
	^ id
]

{ #category : #accessing }
PirateVideo >> id: aString [ 
	id := aString
]

{ #category : #'initialize-release' }
PirateVideo >> initialize [
	super initialize.
		
]

{ #category : #torrents }
PirateVideo >> isDownloaded [
	| |
"	self halt."
	videoFile ifNotNil: [ ^true ].
	torrent isNil ifTrue: [^ false].
	^torrent isDownloadComplete
]

{ #category : #torrents }
PirateVideo >> isDownloading [
	torrent isNil
		ifTrue: [ ^ false ].
	^ torrent isDownloading
]

{ #category : #testing }
PirateVideo >> isViewable [
	(self isViewed )ifTrue:[^false].
	
	^ self isDownloaded
]

{ #category : #testing }
PirateVideo >> isViewed [
	viewed ifNil: [viewed:=false].
	^viewed
]

{ #category : #torrents }
PirateVideo >> lookForIt [
	Transcript crShow: self fullId , ' - look for it.'.
	torrents := self getTorrents.
	torrents := self removeFalsesFrom: torrents.
	torrents isEmpty
		ifFalse: [ 
			self getTopTorrent.
			Transcript crShow: self fullId , ' - Found!'.
			GrowlMorph openWithLabel: 'Found' contents: self fullId ].

]

{ #category : #torrents }
PirateVideo >> lookForItIfNotFound [
	self needsTorrent 
		ifTrue: [ self lookForIt ].
]

{ #category : #torrents }
PirateVideo >> magnet [
	torrent isNil
		ifTrue: [^ ''].
	^self torrent magnet uri
]

{ #category : #torrents }
PirateVideo >> needsTorrent [
	self isViewed
		ifTrue: [ ^ false ].
	videoFile isNil
		ifFalse: [ ^ false ].
	^ self torrent isNil
]

{ #category : #torrents }
PirateVideo >> newFound [
	self isViewed ifTrue: [ ^false].
	^ (torrent isNil) and: [ self torrents isEmptyOrNil not ]
]

{ #category : #'as yet unclassified' }
PirateVideo >> play [
	| args proc fname player |
	self isViewable ifFalse: [^self].
	player := Config current vlcFolder.
	fname := self videoFilename.
	args :=  ' --fullscreen --extraintf rc -I qt --rc-host 127.0.0.1:9092 "', fname, '" '.
	proc := OSProcess command: player , args.
	proc ifNil: [^self].
	[proc isComplete] whileFalse:
		[(Delay forMilliseconds: 200) wait.
		proc update: #runState  ].
	^ proc

]

{ #category : #'as yet unclassified' }
PirateVideo >> play2 [
	| args proc fname |
	torrent ifNil:[^self].
	fname := torrent videoFilename.
"	out := FileStream forceNewFileNamed: '/tmp/deleteMe.out'.
	err := FileStream forceNewFileNamed: '/tmp/deleteMe.err'.
	desc := Array
				with: nil
				with: out
				with: err.
"	args := Array
				with: '--fullscreen'
				with: fname.
	proc := UnixProcess
				forkJob: '/usr/bin/vlc'
				arguments: args
				environment: nil
				descriptors: nil.
	proc ifNil: [UnixProcess noAccessorAvailable].
	[proc isComplete] whileFalse:
		[(Delay forMilliseconds: 200) wait.].
"	out close.
	err close."
	^ proc
"	^ self"
]

{ #category : #printing }
PirateVideo >> printOn: aStream [ 
	aStream nextPutAll:  self fullId
]

{ #category : #torrents }
PirateVideo >> removeFalseTorrent: aTorrentArray [
	self falseTorrents remove: aTorrentArray.

]

{ #category : #torrents }
PirateVideo >> removeFalsesFrom: ts [ 
	^ ts reject: [:t| self falseTorrents anySatisfy: [ :f | f second = t second]].
]

{ #category : #torrents }
PirateVideo >> removeTorrentAndData [
	torrent isNil ifTrue: [^ nil].
	self torrent removeTorrentAndData.
	self torrent: nil.
]

{ #category : #subtitles }
PirateVideo >> setSub: aSubtitleDict [
	subTitle := aSubtitleDict .
]

{ #category : #torrents }
PirateVideo >> status [
	| s |
	s := self statusCode .
	s= -1 ifTrue: [^ '-'].
	s=0 ifTrue: [^'Seed done'].
	s=3 ifTrue: [^'Queued'].
	s=4 ifTrue: [^'Downloading'].
	s=6 ifTrue: [^'Seeding'].
	^'x'
]

{ #category : #torrents }
PirateVideo >> statusCode [
	| s |
	torrent isNil ifTrue: [^ -1].
	^ torrent status.

]

{ #category : #subtitles }
PirateVideo >> subtitles: lang [
	| subs listHash listTitle retryCount |
	retryCount := 5.
	[ 
	listHash := self subtitlesByHash: lang.
	listTitle := self subtitlesByTitle: lang ]
		on: Error
		do: [ :ex | 
			ex inspect.
		"	self halt."
			(retryCount := retryCount - 1) > 0
				ifTrue: [ 
					Transcript crShow: 'retrying subtitles, count left:' , retryCount printString.
					(Delay forMilliseconds: 500) wait.
					ex retry ]
				ifFalse: [ ^ #() ] ].
	subs := listHash , listTitle.
	^ subs
]

{ #category : #subtitles }
PirateVideo >> topSubtitles [
	| os subs topSub |
	self isDownloaded
		ifFalse: [ ^ self ].
	subs := self subtitles: 'eng'.
	subs size > 0
		ifTrue: [ 
			topSub := subs first.
			os := OpenSubClient current.
			os login.
			os downloadSubtitle: topSub fileName: self videoFilename.
			[ os logout ] fork.
			Transcript crShow: 'setting subtitles for ', self fullId.
	
			self setSub: topSub ]
]

{ #category : #torrents }
PirateVideo >> torrent [
	torrent isNil ifTrue: [^ nil].
	torrent class = PirateTorrent ifFalse: [self convertTorrent] .
	^ torrent
]

{ #category : #torrents }
PirateVideo >> torrent: aTorrent [
	torrent ifNotNil: [ torrent delete ].
	videoFile
		ifNotNil: [ 
			videoFile reset.
			videoFile := nil ].
	torrent := aTorrent.
	self changed
]

{ #category : #torrents }
PirateVideo >> torrents [
	^ torrents ifNil: [torrents := OrderedCollection new]
]

{ #category : #torrents }
PirateVideo >> tpbString [
	"tpb = The Pirate Bay "
	^ self fullId encodeForHTTP
]

{ #category : #'as yet unclassified' }
PirateVideo >> unViewed [
	viewed:=false.
	self changed.
	self torrent isNil 
		ifFalse: [torrent download].
	^self
]

{ #category : #'as yet unclassified' }
PirateVideo >> validateTorrent [
	| t |
	torrent ifNil: [ ^ self ].
	self isViewed 
		ifTrue: [ ^ self ].
	torrent isInServer
		ifFalse: [ 
			torrent := nil.
			Transcript crShow: 'Removing torrent from: ' , self printString ]
		ifTrue: [ 
			t := PirateTorrent at: torrent torrentHash.
			t isNil
				ifTrue: [ 
					PirateTorrent allTorrents add: torrent.
					Transcript crShow: 'Adding torrent from: ' , self printString ]
				ifFalse: [ 
					torrent := t.
					Transcript crShow: 'Replacing torrent from: ' , self printString ] ]
]

{ #category : #accessing }
PirateVideo >> videoFile [
	((videoFile isNil and: [ torrent notNil ]) and: [ torrent isDownloadComplete ])
		ifTrue: [ 
			self videoFile: torrent createVideoFile.
			videoFile video: self ].
	^ videoFile
]

{ #category : #accessing }
PirateVideo >> videoFile: aVideoFile [
	videoFile := aVideoFile .
]

{ #category : #accessing }
PirateVideo >> videoFilename [
	^self videoFile fullVideoFilename
]

{ #category : #'as yet unclassified' }
PirateVideo >> viewed [
	viewed:=true.
	self changed.
	self deleteSubtitles.
	torrent ifNotNil: [ torrent doneWithThis ].
	self videoFile ifNotNil: [ self videoFile doneWithThis ].
"	[self videoFile doneWithThis. ] forkAt: Processor userBackgroundPriority."
	^self
]
