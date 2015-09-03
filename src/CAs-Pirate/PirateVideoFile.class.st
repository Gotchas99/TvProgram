Class {
	#name : #PirateVideoFile,
	#superclass : #PostgresObject,
	#instVars : [
		'torrent',
		'video',
		'videoHash',
		'folder',
		'videoFilename',
		'swesub',
		'viewTime'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateVideoFile class >> validateAll [
	PirateVideoFile allInstances do: [ :vf | vf validate ]
]

{ #category : #hashing }
PirateVideoFile >> computeHashForChunk2: fs start: start size: chunkSize [
	| hash buff |
	hash := 0.
	fs position: start.
	1 to: (chunkSize // 8) do: [:i| 
		buff := fs nextLittleEndianNumber: 8.
		hash :=hash + buff.
	].
	^hash
]

{ #category : #printing }
PirateVideoFile >> computeHashForChunk: fs start: start size: chunkSize [
	| hash buff uint |
	hash := UInt64 fromHex: '00'.
	fs position: start.
	1 to: chunkSize // 8 do: [ :i | 
		buff := fs next: 8.
		uint := UInt64 from: buff.
		hash := hash + uint ].
	^ hash
]

{ #category : #'as yet unclassified' }
PirateVideoFile >> deleteSubtitles [
	self video ifNotNil: [ video deleteSubtitles ]
]

{ #category : #'as yet unclassified' }
PirateVideoFile >> doneWithThis [
	viewTime := TimeStamp now.
	torrent ifNotNil: [ torrent doneWithThis ]
]

{ #category : #accessing }
PirateVideoFile >> fileSize [
	| fs s |
	fs := self videoFile.
	fs ifNil: [ ^ nil ].
	s := fs size.
	fs close.
	^ s
]

{ #category : #accessing }
PirateVideoFile >> folder [
	^ folder
		ifNil: [ 
			torrent isNil
				ifFalse: [ folder := torrent folder ] ]
]

{ #category : #accessing }
PirateVideoFile >> folder: aString [
	folder:= aString
]

{ #category : #accessing }
PirateVideoFile >> fullVideoFilename [
	| fname |
	fname := self folder , '/' , videoFilename.
	Smalltalk os isUnix
		ifTrue: [ fname := fname copyReplaceAll: '\' with: '/' ].
	Smalltalk os isWin32
		ifTrue: [ fname := fname copyReplaceAll: '/' with: '\' ].
	^ fname
]

{ #category : #hashing }
PirateVideoFile >> getUint64From: aByteArray [
	"Convert me to an Integer, least significant byte first, little endian"
	
	| integer |
	integer := 0.
	aByteArray reverse do: [ :each | 
		integer :=(integer bitShift: 8) + each ].
	^ integer
]

{ #category : #hashing }
PirateVideoFile >> hash2: fs [
	| hashChunkSize chunkSize size head tail hash |
	fs ifNil: [ ^ nil ].
	fs binary.
	hashChunkSize := 64 * 1024.
	size := fs size.
	chunkSize := size min: hashChunkSize.
	head := self computeHashForChunk2: fs start: 0 size: chunkSize.
	tail := self computeHashForChunk2: fs start: (size - chunkSize max: 0) size: chunkSize.
	hash := (size + head + tail) asInteger.
	fs close.
	^ hash shortHexString
]

{ #category : #hashing }
PirateVideoFile >> hash: fs [
	| hashChunkSize chunkSize size head tail hash |
	fs ifNil: [ ^ nil ].
	fs binary.
	hashChunkSize := 64 * 1024.
	size := fs size.
	chunkSize := size min: hashChunkSize.
	head := self computeHashForChunk: fs start: 0 size: chunkSize.
	tail := self computeHashForChunk: fs start: (size - chunkSize max: 0) size: chunkSize.
	hash := (size + head + tail) asInteger.
	fs close.
	^ hash printStringHex
]

{ #category : #'initialize-release' }
PirateVideoFile >> initialize [
	super initialize .
	
]

{ #category : #testing }
PirateVideoFile >> isSeen [
	viewTime isNil ifFalse:[^true].
	video ifNil: [ ^false ] ifNotNil: [  ^video isViewed].
]

{ #category : #testing }
PirateVideoFile >> isValid [
	^ self folder isNil not and: [ videoFilename isNil not ]
]

{ #category : #printing }
PirateVideoFile >> printOn: aStream [ 
	aStream nextPutAll:  self videoFilename 
]

{ #category : #'as yet unclassified' }
PirateVideoFile >> reset [
	self video: nil.
	self torrent: nil.
	self videoFilename: nil.
]

{ #category : #'not used' }
PirateVideoFile >> swesub [
	^ swesub ifNil: [ swesub := false ]
]

{ #category : #'not used' }
PirateVideoFile >> swesub: aBoolean [
	swesub := aBoolean 
]

{ #category : #accessing }
PirateVideoFile >> torrent [
	^torrent
]

{ #category : #accessing }
PirateVideoFile >> torrent: aTorrent [
	torrent := aTorrent.
	folder := nil.
	
]

{ #category : #'as yet unclassified' }
PirateVideoFile >> validate [
	self validateTorrent.
	self validateVideo
]

{ #category : #'as yet unclassified' }
PirateVideoFile >> validateTorrent [
	torrent isNil
		ifFalse: [ 
			torrent isInServer not
				ifTrue: [ 
					torrent := nil.
					Transcript crShow: 'Removing torrent from: ' , self printString ] ]
]

{ #category : #'as yet unclassified' }
PirateVideoFile >> validateVideo [
	video isNil
		ifTrue: [ ^ self ].
	self isValid
		ifFalse: [ 
			Transcript crShow: 'Disconnecting videoFile from: ' , video printString.
			video videoFile: nil.
			video := nil ]
]

{ #category : #accessing }
PirateVideoFile >> video [
	^video
]

{ #category : #accessing }
PirateVideoFile >> video: aVideo [
	video := aVideo
]

{ #category : #accessing }
PirateVideoFile >> videoFile [
	| fs |
	[ fs := FileSystem disk readStreamOn: self fullVideoFilename ]
		on: Error
		do: [ :ex | 
			Transcript
				crShow: 'PirateVideoFile: ' , self videoFilename;
				crShow: ex printString.
			^ nil ].
	fs ifNil: [ ^ nil ].
	fs binary.
	^ fs
]

{ #category : #accessing }
PirateVideoFile >> videoFilename [
	^videoFilename 
]

{ #category : #accessing }
PirateVideoFile >> videoFilename: aString [
	videoFilename := aString.
	videoHash :=nil.
	viewTime:=nil.
]

{ #category : #hashing }
PirateVideoFile >> videoHash [
	^ videoHash ifNil: [ videoHash := self hash: self videoFile ]
]

{ #category : #accessing }
PirateVideoFile >> viewTime [
	^ viewTime
		ifNil: [ 
			self isSeen
				ifTrue: [ 
					self doneWithThis.
					viewTime := TimeStamp now ] ]
]
