Class {
	#name : #PirateVideoFile,
	#superclass : #Object,
	#instVars : [
		'video',
		'videoHash',
		'folder',
		'videoFilename',
		'swesub',
		'viewTime',
		'subTitles'
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

{ #category : #hashing }
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

{ #category : #subtitles }
PirateVideoFile >> deleteSubtitles [
	| ref |
	ref := self srtFileName.
	ref
		ifNotNil: [ 
			ref exists
				ifTrue: [ ref delete ] ].
	subTitles := nil
]

{ #category : #'initialize-release' }
PirateVideoFile >> disconnect [
	self video ifNotNil: [ video videoFile: nil ].
	self reset
]

{ #category : #'as yet unclassified' }
PirateVideoFile >> doneWithThis [
	viewTime := DateAndTime now.

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
	(folder isKindOf: String)
		ifTrue: [ folder := folder asFileReference ].
	^ folder
]

{ #category : #accessing }
PirateVideoFile >> folder: aString [
	folder:= aString
]

{ #category : #accessing }
PirateVideoFile >> fullVideoFilename [
	| fname |
	self folder ifNil: [ ^ nil ].
	self videoFilename ifNil: [ ^ nil ].
	fname := self folder / videoFilename.
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

{ #category : #subtitles }
PirateVideoFile >> hasSubtitle [
	| ref |
	ref := self srtFileName.
	ref ifNotNil: [ ^ ref exists ] ifNil: [ ^ false ]
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
	^ viewTime isNil not
		"	video ifNil: [ ^ false ] ifNotNil: [ ^ video isViewed ]" 
]

{ #category : #testing }
PirateVideoFile >> isValid [
	| ref |
	self folder ifNil: [ ^ false ].
	videoFilename ifNil: [ ^ false ].
	ref := self fullVideoFilename .
	^ ref exists
]

{ #category : #subtitles }
PirateVideoFile >> needsSubtitle [
	| ref |
	ref := self srtFileName.
	ref ifNotNil: [ ^ ref exists not ] ifNil: [ ^ false ]
]

{ #category : #printing }
PirateVideoFile >> printOn: aStream [ 
	aStream nextPutAll:  self videoFilename 
]

{ #category : #'initialize-release' }
PirateVideoFile >> reset [
	self deleteSubtitles.
	self video: nil.
	self videoFilename: nil
]

{ #category : #subtitles }
PirateVideoFile >> setSub: aText [
	| srtName fs |
	srtName := self srtFileName.
	fs := FileSystem disk openFileStream: srtName writable: true.
	fs nextPutAll: aText.
	fs close
]

{ #category : #subtitles }
PirateVideoFile >> srtFileName [
	^ self fullVideoFilename 
		ifNotNilDo: [ :fname | fname withExtension: 'srt' ] 
		ifNil: [ ^ nil ]
]

{ #category : #'not used' }
PirateVideoFile >> swesub [
	^ swesub ifNil: [ swesub := false ]
]

{ #category : #'not used' }
PirateVideoFile >> swesub: aBoolean [
	swesub := aBoolean 
]

{ #category : #validation }
PirateVideoFile >> validate [
	self validateVideo
]

{ #category : #validation }
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
				crShow: 'Error: PirateVideoFile: ' , self videoFilename printString ;
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
				ifTrue: [ self doneWithThis ] ]
]
