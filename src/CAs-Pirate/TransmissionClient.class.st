Class {
	#name : #TransmissionClient,
	#superclass : #Object,
	#instVars : [
		'xSessionId'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Pirate-Services'
}

{ #category : #'as yet unclassified' }
TransmissionClient class >> current [
	Current isNil
		ifTrue: [Current := self new]. 
	^ Current
]

{ #category : #'as yet unclassified' }
TransmissionClient class >> new [
^ super new initialize
]

{ #category : #'as yet unclassified' }
TransmissionClient class >> statusTxt [
"
paused, torrent, metadata not found,no downloads yet
	percentDone:0, isFinished:false, leftUntilDone:0, status:0, totalSize:0
	
seeding
	percentDone:1, isFinished:false, leftUntilDone:0, status:6, totalSize: 306430027 
	
"
]

{ #category : #action }
TransmissionClient >> addTorrent: aTorrentString [
	"a torrent-URL or a magnet-link"

	| args req |
	args := Dictionary new.
	args at: 'filename' put: aTorrentString.
	args at: 'download-dir' put: self folder pathString .
	args at: 'priority-low' put: #().
	req := Dictionary new.
	req at: 'method' put: 'torrent-add'.
	req at: 'arguments' put: args.
	^ self sendReq: req
]

{ #category : #private }
TransmissionClient >> callMethod: aMethod for: aTorrentId with: aListOfFields [
	| args req resp ts |
	args := Dictionary new.
	args at: 'ids' put: (Array with: aTorrentId).
	args at: 'fields' put: aListOfFields.
	req := Dictionary new.
	req at: 'method' put: aMethod.
	req at: 'arguments' put: args.	
	resp := self sendReq: req.
	ts := (resp at: #arguments) at: #torrents.
	ts isEmptyOrNil
		ifTrue: [ ^ #() ].
	^ ts
]

{ #category : #access }
TransmissionClient >> folder [
	| folder transFolder store fs  path |
	transFolder := self getDownloadDir.
	path := transFolder asPath / '_TvProgram'.
	self isLinuxServer
		ifTrue: [ store:= UnixStore new ]
		ifFalse: [store:= WindowsStore new].
		fs:= FileSystem store:store.
	folder:=(fs referenceTo: path) .
	^ folder
]

{ #category : #access }
TransmissionClient >> getAll [
	| args req resp |
	args := Dictionary new.
	args
		at: 'fields'
		put: {'id' . 'name' . 'totalSize' . 'files' . 'percentDone' . 'hashString' . 'status'}.
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^"
	resp := self sendReq: req.
	^ (resp at: #arguments) at: #torrents
]

{ #category : #access }
TransmissionClient >> getDir: aTorrentId [
	| args req resp ts |
	args := Dictionary new.
	args at: 'ids'	put: (Array with: aTorrentId ). 
	args at: 'fields' put: {'id'. 'name'. 'downloadDir'. 'totalSize'. 'files'. 'percentDone'. 'hashString'} .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	ts := (resp at: #arguments) at: #torrents.
	ts isEmptyOrNil ifTrue: [^#()].
	^ ts first at: #downloadDir.
	
]

{ #category : #access }
TransmissionClient >> getDownloadDir [
	| args req resp dir |
	args := Dictionary new.
	req := Dictionary new.
	req at: 'method' put: 'session-get'.
	req at: 'arguments' put: args.
	
	resp := self sendReq: req.
	dir := (resp at: #arguments) at: 'download-dir'.
	^ dir 
]

{ #category : #access }
TransmissionClient >> getFiles: aTorrentId [
	| args req resp ts |
	args := Dictionary new.
	args at: 'ids'	put: (Array with: aTorrentId ). 
	args at: 'fields' put: {'id'. 'name'. 'downloadDir'. 'totalSize'. 'files'. 'percentDone'. 'hashString'} .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	ts := (resp at: #arguments) at: #torrents.
	ts isEmptyOrNil ifTrue: [^#()].
	^ ts first at: #files.
	
]

{ #category : #access }
TransmissionClient >> getMagnet: aTorrentId [
	| args req resp ts |
	args := Dictionary new.
	args at: 'ids'	put: (Array with: aTorrentId ). 
	args at: 'fields' put: { 'magnetLink' } .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	ts := (resp at: #arguments) at: #torrents.
	ts isEmptyOrNil ifTrue: [^#()].
	^ ts first at: #magnetLink.
	
]

{ #category : #access }
TransmissionClient >> getStatus: aTorrentId [
	| ts fields |
	fields := {'id'.
	'status'}.
	ts := self callMethod: 'torrent-get' for: aTorrentId with: fields.
	ts isEmptyOrNil
		ifTrue: [ ^ -1 ].
	^ ts first at: #status
]

{ #category : #access }
TransmissionClient >> getTitle: aTorrentId [
	| args req resp ts |
	args := Dictionary new.
	args at: 'ids'	put: (Array with: aTorrentId ). 
	args at: 'fields' put: { 'name' } .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	ts := (resp at: #arguments) at: #torrents.
	ts isEmptyOrNil ifTrue: [^nil].
	^ ts first at: #name.
	
]

{ #category : #access }
TransmissionClient >> getTorrents [
	"a torrent-URL or a magnet-link"
	| args req |
	args := Dictionary new.
	args at: 'fields' put: #('id' 'name' 'isFinished' 'downloadDir' 'magnetLink' 'files' ).
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args. 
	^ ((self sendReq: req)
		at: 'arguments') at: 'torrents'
]

{ #category : #access }
TransmissionClient >> getTotalSize: aTorrentId [
	| args req resp ts |
	args := Dictionary new.
	args at: 'ids'	put: (Array with: aTorrentId ). 
	args at: 'fields' put: {'id'.  'totalSize'. } .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	ts := (resp at: #arguments) at: #torrents.
	ts isEmptyOrNil ifTrue: [^#()].
	^ ts first at: #totalSize.
	
]

{ #category : #'initialize - release' }
TransmissionClient >> initialize [
	xSessionId :='dummy' .

]

{ #category : #testing }
TransmissionClient >> isDownloadComplete: aTorrentId [
	| t torrents fields |
	fields := {'id' . 'totalSize' . 'leftUntilDone' . 'isFinished'.
	'percentDone' . 'status'}.
	torrents := self callMethod: 'torrent-get' for: aTorrentId with: fields.
	torrents isEmpty
		ifTrue: [ ^ false ].
	t := torrents first.
	(t at: #totalSize) = 0
		ifTrue: [ ^ false ].
	^ 0 = (t at: #leftUntilDone)
]

{ #category : #testing }
TransmissionClient >> isHashInServer: aMagnet [
	| args req resp torrents |
	args := Dictionary new.
	args
		at: 'ids'
		put:  aMagnet .
"		put: 'recently-active'."
	args at: 'fields' put: {'id'. 'leftUntilDone'. 'isFinished'. 'percentDone'. 'status'} .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	torrents := (resp at: #arguments) at: #torrents.
	^torrents isEmpty not.
]

{ #category : #private }
TransmissionClient >> isLinuxServer [
	| folder |
	folder:= self getDownloadDir .
	^folder beginsWith: '/'
]

{ #category : #testing }
TransmissionClient >> isSeedingComplete: aTorrentId [
	| args req resp t torrents maxSeedTime |
	maxSeedTime := 90 * 24 * 60 * 60.
	args := Dictionary new.
	args at: 'ids' put: aTorrentId.
	args
		at: 'fields'
		put:
			{'id' . 'totalSize' . 'leftUntilDone' . 'isFinished' . 'percentDone' . 'secondsSeeding'.
			'status'}.
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.	"^"
	resp := self sendReq: req.
	torrents := (resp at: #arguments) at: #torrents.
	torrents isEmpty
		ifTrue: [ ^ true ].
	t := torrents first.
	(t at: #totalSize) = 0
		ifTrue: [ ^ false ].
	(t at: #isFinished)
		ifTrue: [ ^ true ].
	(t at: #secondsSeeding) > maxSeedTime
		ifTrue: [ ^ true ].
	^ 0 = (t at: #status)
]

{ #category : #private }
TransmissionClient >> newRequest: aString [
	| request anURL |
	anURL := 'http://' , Config current host , ':' , Config current port asString , '/transmission/rpc'.
	request := ZnClient new
		timeout: 10;
		numberOfRetries: 3;
		retryDelay: 2;
		beOneShot .
	request url: anURL.
	request contents: aString.
	request headerAt: 'x-transmission-session-id' put: xSessionId asString.
	^ request
]

{ #category : #action }
TransmissionClient >> removeTorrent: aTorrentId [ 
	| args req |
	args := Dictionary new.
	args
		at: 'ids'
		put: (Array with: aTorrentId ). 
	args at: 'delete-local-data' put: 'true'.
	req := Dictionary new.
	req at: 'method' put: 'torrent-remove'.
	req at: 'arguments' put: args.
	^ self sendReq: req 
]

{ #category : #private }
TransmissionClient >> sendReq: aJSON [
	| request resp reqString |
	(aJSON isKindOf: String)
		ifTrue: [ reqString := aJSON ]
		ifFalse: [ reqString := NeoJSONWriter toString: aJSON ].
	request := self newRequest: reqString.
	request post.
	request response code = 409
		ifTrue: [ 
			self setSessionIdFrom: request.
			request := self newRequest: reqString.
			request post ].
	resp := NeoJSONReader fromString: request contents readStream.
	request close.
	^ resp
]

{ #category : #private }
TransmissionClient >> setSessionIdFrom: aRequest [
	| headers |
	headers := aRequest response headers.
	(headers includesKey: 'x-transmission-session-id')
		ifTrue: [ xSessionId := headers at: 'x-transmission-session-id' ]
]
