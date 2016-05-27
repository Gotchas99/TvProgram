Class {
	#name : #PirateVideo,
	#superclass : #Object,
	#instVars : [
		'id',
		'torrent',
		'falseTorrents',
		'viewed',
		'torrents',
		'videoFile',
		'prevPosition'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateVideo class >> getAllSubtitles [
	| needsSubs delay viewables |
	delay := Delay forSeconds: 5.	"self halt."
	viewables := PirateShow allViewableEpisodes.
	needsSubs := viewables reject: [ :ep | ep hasSubtitle ].
	needsSubs := needsSubs reject: [ :ep | ep videoFile isNil ].
	needsSubs := needsSubs select: [ :ep | ep videoFile isValid ].
	needsSubs
		do: [ :ep | 
			ep topSubtitles.
			delay wait ]
]

{ #category : #'as yet unclassified' }
PirateVideo class >> havingTorrentHash: aHash [
	| t eps ep |
	eps := PirateShow allEpisodes.
	t := eps select: [ :e | e torrent isNotNil ].
	t isEmptyOrNil
		ifTrue: [ ^ nil ].
	t := t select: [ :e | e torrent torrentHash = aHash ].
	t isEmptyOrNil
		ifTrue: [ ^ nil ].
	ep := t first.
	^ ep
]

{ #category : #'as yet unclassified' }
PirateVideo class >> validateAll [
	self validateAllTorrents.
	self validateAllVideoFiles
]

{ #category : #torrents }
PirateVideo >> addFalseTorrent: aTorrentArray [
	self falseTorrents add: aTorrentArray.

]

{ #category : #torrents }
PirateVideo >> convertTorrent [
	torrent class = PirateTorrent
		ifTrue: [ ^ self ].
	torrent = PirateTorrent
		ifTrue: [ ^ torrent := nil ].
	torrent isString
		ifTrue: [ 
			torrent := {'???'.
			torrent.
			0.
			0} ].
	^ torrent := PirateTorrent from: torrent
]

{ #category : #'initialize-release' }
PirateVideo >> delete [
	self deleteSubtitles.
	torrent ifNotNil: [ torrent delete.torrent:=nil ].
	torrents := nil.
	falseTorrents := nil.
	videoFile
		ifNotNil: [ 
			videoFile reset.
			videoFile := nil ].
	viewed:=false.
]

{ #category : #subtitles }
PirateVideo >> deleteSubtitles [
	self videoFile ifNotNil: [ :vf | vf deleteSubtitles ]
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
	^ self isViewed or: [ self torrents isEmpty not or: [ videoFile isNil not ] ]
]

{ #category : #torrents }
PirateVideo >> getTopTorrent [
	self torrent: self torrents first.
	self download
]

{ #category : #torrents }
PirateVideo >> getTorrents [
	self subclassResponsibility 
]

{ #category : #subtitles }
PirateVideo >> hasSubtitle [
	^ videoFile 
			ifNotNil: [ :vf | vf hasSubtitle ] 
			ifNil: [ ^ false ]
]

{ #category : #'initialize-release' }
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

{ #category : #testing }
PirateVideo >> isDownloaded [
	videoFile ifNotNil: [ ^ true ].
	torrent ifNil: [ ^ false ].
	^ torrent isDownloadComplete
]

{ #category : #testing }
PirateVideo >> isDownloading [
	torrent isNil
		ifTrue: [ ^ false ].
	^ torrent isDownloading
]

{ #category : #testing }
PirateVideo >> isPaused [
	^ prevPosition isNotNil and: [ prevPosition > 0 ]
]

{ #category : #testing }
PirateVideo >> isViewable [
	self isViewed
		ifTrue: [ ^ false ].
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

{ #category : #testing }
PirateVideo >> needsTorrent [
	self isViewed
		ifTrue: [ ^ false ].
	videoFile ifNotNil: [ ^ false ].
	^ self torrent isNil
]

{ #category : #torrents }
PirateVideo >> newFound [
	self isViewed ifTrue: [ ^false].
	^ (torrent isNil) and: [ self torrents isEmptyOrNil not ]
]

{ #category : #playing }
PirateVideo >> play [
	| fname v |
	self isViewable
		ifFalse: [ ^ self ].
	fname := self videoFilename fullName.
	v := VlcClient new.
	v when: #stoppedAt: send: #playbackStoppedAt: to: self.
	v play: fname atPos: (prevPosition ifNil: [ 0 ])
]

{ #category : #'as yet unclassified' }
PirateVideo >> playOld [
	| args proc fname player d |
	self isViewable
		ifFalse: [ ^ self ].
	player := Config current vlcFolder.
	fname := self videoFilename fullName.
	args := ' --fullscreen --extraintf rc -I qt --rc-host 127.0.0.1:9092 "' , fname , '" '.
	proc := OSProcess command: player , args.
	d := Delay forMilliseconds: 200.
	proc ifNil: [ ^ self ].
	[ proc isComplete ]
		whileFalse: [ 
			d wait.
			proc update: #runState ].
	^ proc
]

{ #category : #playing }
PirateVideo >> playbackStoppedAt: aPosition [
	prevPosition := aPosition.
	self triggerEvent: #stopped
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
	"Dummy .should remove"
]

{ #category : #torrents }
PirateVideo >> status [
	| s |
	s := self statusCode .
	s= -1 ifTrue: [^ '-'].
	s=0 ifTrue: [^'Paused/Done'].
	s=3 ifTrue: [^'Queued'].
	s=4 ifTrue: [^'Downloading'].
	s=5 ifTrue: [^'QueuedSeed'].
	s=6 ifTrue: [^'Seeding'].
	s=7 ifTrue: [^'Paused'].
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
			(retryCount := retryCount - 1) > 0
				ifTrue: [ 
					Transcript crShow: 'retrying subtitles, count left:' , retryCount printString.
					Transcript crShow: self fullPrintString .
					Transcript crShow: ex printString.
					(Delay forMilliseconds: 500) wait.
					ex retry ]
				ifFalse: [ ^ #() ] ].
	subs := listHash , listTitle.
	^ subs
]

{ #category : #subtitles }
PirateVideo >> topSubtitles [
	| os subs topSub text |
	self isDownloaded
		ifFalse: [ ^ self ].
	subs := self subtitles: 'eng'.
	subs ifEmpty: [ ^ self ].
	topSub := subs first.
	os := OpenSubClient current.
	text := os downloadSubtitle: topSub.
	text ifNil: [ ^ self ].
	self videoFile setSub: text.
	Transcript crShow: 'setting subtitles for ' , self fullId
]

{ #category : #torrents }
PirateVideo >> torrent [
	torrent ifNil: [^ nil].
	torrent class = PirateTorrent ifFalse: [self convertTorrent] .
	^ torrent
]

{ #category : #torrents }
PirateVideo >> torrent: aTorrent [
	torrent = aTorrent
		ifTrue: [ ^ self ].
	torrent ifNotNil: [ torrent delete ].
	torrent := PirateTorrent asTorrent: aTorrent.
	videoFile ifNotNil: [ self videoFile: nil ].
	self changed
]

{ #category : #torrents }
PirateVideo >> torrents [
	torrents ifNil: [ torrents := OrderedCollection new ].
	^ torrents 
]

{ #category : #torrents }
PirateVideo >> tpbString [
	"tpb = The Pirate Bay "

	^ self fullId urlEncoded
]

{ #category : #'as yet unclassified' }
PirateVideo >> unViewed [
	viewed := false.
	self changed.
	self torrent ifNotNil: [ :t | t download ].
	^ self
]

{ #category : #validation }
PirateVideo >> validateTorrent [
	| t |
	torrent ifNil: [ ^ self ].
	self isViewed
		ifTrue: [ 
			videoFile ifNotNil: [ videoFile doneWithThis ].
			torrent doneWithThis ].
	torrent isInServer
		ifFalse: [ 
			self download.
			Transcript crShow: 'Adding torrent to Transmission: ' , self printString ]
		ifTrue: [ 
			t := PirateTorrent at: torrent torrentHash.
			t
				ifNil: [ 
					PirateTorrent allTorrents add: torrent.
					Transcript crShow: 'Adding torrent from: ' , self printString ]
				ifNotNil: [ 
					t = torrent
						ifFalse: [ 
							self torrent: t.
							Transcript crShow: 'Replacing torrent from: ' , self printString ] ] ]
]

{ #category : #validation }
PirateVideo >> validateVideofile [
	videoFile ifNil: [ ^ self ].
	self isViewed
		ifTrue: [ ^ self ].
	videoFile class = PirateVideoFile
		ifFalse: [ 
			self videoFile: nil.
			Transcript crShow: 'Removing videoFile (wrong class) from: ' , self printString.
			^ self ].
	videoFile isValid
		ifFalse: [ 
			self videoFile: nil.
			Transcript crShow: 'Removing videoFile (invalid state) from: ' , self printString ]
]

{ #category : #accessing }
PirateVideo >> videoFile [
	videoFile ifNotNil: [ ^ videoFile ].
	torrent ifNil: [ ^ nil ].
	torrent isDownloadComplete
		ifFalse: [ ^ nil ].
	torrent isSingleVideoFile
		ifFalse: [ ^ nil ].
"	self videoFile: torrent videoFile.
	videoFile video: self."
	^ videoFile
]

{ #category : #accessing }
PirateVideo >> videoFile: aVideoFile [
	videoFile
		ifNotNil: [ 
			videoFile class = PirateVideoFile
				ifTrue: [ videoFile reset ] ].
	videoFile := aVideoFile
]

{ #category : #accessing }
PirateVideo >> videoFilename [
	self videoFile ifNil: [ ^ nil ] ifNotNil: [ :vf | ^ vf fullVideoFilename ]
]

{ #category : #'as yet unclassified' }
PirateVideo >> viewed [
	viewed := true.
	self changed.
	self deleteSubtitles.
	self videoFile ifNotNil: [ self videoFile doneWithThis ].
	torrent ifNotNil: [ torrent doneWithThis ].
	^ self
]
