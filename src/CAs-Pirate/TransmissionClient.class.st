Class {
	#name : #TransmissionClient,
	#superclass : #Object,
	#instVars : [
		'xSessionId'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Pirate'
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

{ #category : #'as yet unclassified' }
TransmissionClient >> folder [
	| folder transFolder  |
	transFolder := self getDownloadDir.
	folder := transFolder asFileReference / '_TvProgram'.
	^ folder
]

{ #category : #'as yet unclassified' }
TransmissionClient >> getAll [
	| args req resp t torrents |
	args := Dictionary new.
	args at: 'fields' put: {'id'. 'name'. 'totalSize'. 'files'. 'percentDone'. 'hashString'. 'status'} .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	^torrents := (resp at: #arguments) at: #torrents
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
TransmissionClient >> getStatus: aTorrentId [
	| args req resp ts |
	args := Dictionary new.
	args at: 'ids'	put: (Array with: aTorrentId ). 
	args at: 'fields' put: {'id'. 'status'. } .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	ts := (resp at: #arguments) at: #torrents.
	ts isEmptyOrNil ifTrue: [^#()].
	^ ts first at: #status.
	
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
TransmissionClient >> initialize [
	xSessionId :='dummy' .

]

{ #category : #'as yet unclassified' }
TransmissionClient >> isComplete: aTorrentId [ 
	| args req resp t torrents |
	args := Dictionary new.
	args
		at: 'ids'
		put:  aTorrentId .
"		put: 'recently-active'."
	args at: 'fields' put: {'id'. 'totalSize'. 'leftUntilDone'. 'isFinished'. 'percentDone'. 'status'} .
	req := Dictionary new.
	req at: 'method' put: 'torrent-get'.
	req at: 'arguments' put: args.
	"^" 
	resp:=self sendReq: req .
	torrents := (resp at: #arguments) at: #torrents.
	torrents isEmpty ifTrue: [^false].
	t := torrents first.
	( t at: #totalSize)= 0 ifTrue: [ ^false ].
	Transcript show: (t at: #status).
	^ 0 = (t at: #leftUntilDone).
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
TransmissionClient >> isMagnetInServer: aHash [
	| args req resp torrents |
	args := Dictionary new.
	args
		at: 'ids'
		put:  aHash .
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

{ #category : #'as yet unclassified' }
TransmissionClient >> isSeedingComplete: aTorrentId [
	| args req resp t torrents maxSeedTime |
	maxSeedTime := 90*24*60*60.
	args := Dictionary new.
	args at: 'ids' put: aTorrentId.	"		put: 'recently-active'."
	args
		at: 'fields'
		put:
			{'id'.
			'totalSize'.
			'leftUntilDone'.
			'isFinished'.
			'percentDone'.
			'secondsSeeding'.
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
	(t at: #secondsSeeding) > maxSeedTime
		ifTrue: [ ^ true ].
	^ 0 = (t at: #status)
]

{ #category : #'as yet unclassified' }
TransmissionClient >> isTorrentInServer: aHash [
	| args req resp torrents |
	args := Dictionary new.
	args
		at: 'ids'
		put:  aHash .
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

{ #category : #'as yet unclassified' }
TransmissionClient >> newRequest: aString [
	| request anURL |
	anURL := 'http://' , Config current host , ':' , Config current port asString , '/transmission/rpc'.
	request := ZnClient new
		timeout: 10;
		numberOfRetries: 3;
		retryDelay: 2.
	request url: anURL.
	request contents: aString.
	request headerAt: 'x-transmission-session-id' put: xSessionId asString.
	^ request
]

{ #category : #'as yet unclassified' }
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

{ #category : #'as yet unclassified' }
TransmissionClient >> removeTorrentX: aTorrentId [ 
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

{ #category : #'as yet unclassified' }
TransmissionClient >> sendReq: aJSON [
	| request resp reqString |
	(aJSON isKindOf: String)
		ifTrue: [ reqString := aJSON ]
		ifFalse: [ reqString :=NeoJSONWriter toString: aJSON ].	"		ifFalse: [reqString := Json render: aJSON].
"
	request := self newRequest: reqString.
	request post.
	request response code = 409
		ifTrue: [ 
			self setSessionIdFrom: request.
			request := self newRequest: reqString.
			request post ].	"	resp := Json readFrom: request contents readStream.
"
	resp := NeoJSONReader fromString: request contents readStream.
	request close.
	^ resp
]

{ #category : #'as yet unclassified' }
TransmissionClient >> setSessionIdFrom: aRequest [ 
	| headers | 
	headers := aRequest response headers.
	(headers includesKey: 'x-transmission-session-id')
		ifTrue: [xSessionId := headers at: 'x-transmission-session-id']
]

{ #category : #'as yet unclassified' }
TransmissionClient >> test [
	| req |
	host := 'cm1'.
	port := 9091.
	req := '{ 
	         "arguments": {
	             "fields": [ "id", "name", "totalSize" ],
	             "ids": [ 7, 10 ]
	         },
	         "method": "torrent-get",
	         "tag": 39693
	      }'.
"	self halt."
	^self sendReq: req
]
