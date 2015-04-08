Class {
	#name : #Base32MimeConverter,
	#superclass : #MimeConverter,
	#instVars : [
		'data',
		'multiLine'
	],
	#classVars : [
		'FromCharTable',
		'ToCharTable'
	],
	#category : #Base32
}

{ #category : #'as yet unclassified' }
Base32MimeConverter class >> decodeInteger: mimeString [ 
	"Decode the MIME string into an integer of any length"
	| bytes sum |
	bytes := (Base32MimeConverter mimeDecodeToBytes: mimeString readStream) contents.
	sum := 0.
	bytes reverseDo: [ :by | sum := sum * 256 + by ].
	^ sum
]

{ #category : #'as yet unclassified' }
Base32MimeConverter class >> encodeInteger: int [
	| strm |
	"Encode an integer of any length and return the MIME string"

	strm := ReadWriteStream on: (ByteArray new: int digitLength).
	1 to: int digitLength do: [:ii | strm nextPut: (int digitAt: ii)].
	strm reset.
	^ ((self mimeEncode: strm) contents) copyUpTo: $=	"remove padding"
]

{ #category : #'class initialization' }
Base32MimeConverter class >> initialize [
	FromCharTable := Array new: 256.	"nils"
	ToCharTable := Array new: 64.
	($A asciiValue to: $Z asciiValue)
		doWithIndex: [ :val :ind | 
			FromCharTable at: val + 1 put: ind - 1.
			ToCharTable at: ind put: val asCharacter ].
	($2 asciiValue to: $7 asciiValue)
		doWithIndex: [ :val :ind | 
			FromCharTable at: val + 1 put: ind + 25.
			ToCharTable at: ind + 26 put: val asCharacter ].
	FromCharTable at: $+ asciiValue + 1 put: 62.
	ToCharTable at: 63 put: $+.
	FromCharTable at: $/ asciiValue + 1 put: 63.
	ToCharTable at: 64 put: $/
]

{ #category : #'as yet unclassified' }
Base32MimeConverter class >> mimeDecodeToBytes: aStream [ 
	"Return a RWBinaryOrTextStream of the original ByteArray.  aStream has only 33 innocuous character values.  aStream is not binary.  (See class comment). 8 bytes in aStream goes to 3 bytes in output."

	| me |
	aStream position: 0.
	me := self new mimeStream: aStream.
	me dataStream: (RWBinaryOrTextStream on: (ByteArray new: aStream size * 3 // 2)).
	me mimeDecodeToByteArray.
	me dataStream position: 0.
	^ me dataStream
]

{ #category : #'as yet unclassified' }
Base32MimeConverter class >> mimeDecodeToChars: aStream [ 
	"Return a ReadWriteStream of the original String.  aStream has only 33 innocuous character values.  It is not binary.  (See class comment). 8 bytes in aStream goes to 3 bytes in output."

	| me |
	aStream position: 0.
	me := self new mimeStream: aStream.
	me dataStream: (ReadWriteStream on: (String new: aStream size * 3 // 2)).
	me mimeDecode.
	me dataStream position: 0.
	^ me dataStream
]

{ #category : #convenience }
Base32MimeConverter class >> mimeEncode: aStream [
	"Return a ReadWriteStream of characters.  The data of aStream is encoded as 65 innocuous characters.  (See class comment). 3 bytes in aStream goes to 4 bytes in output."

	^self mimeEncode: aStream multiLine: true
]

{ #category : #'as yet unclassified' }
Base32MimeConverter class >> mimeEncode: aStream multiLine: aBool [
	"Return a ReadWriteStream of characters.  The data of aStream is encoded as 33 innocuous characters.  (See class comment). 3 bytes in aStream goes to 8 bytes in output."

	| me |
	me := self new dataStream: aStream.
	me multiLine: aBool.
	me mimeStream: (ReadWriteStream on: (String new: aStream size + 20 * 4 // 2)).
	me mimeEncode.
	me mimeStream position: 0.
	^ me mimeStream
]

{ #category : #initialization }
Base32MimeConverter >> initialize [ 
	super initialize.
		
	multiLine := true.
]

{ #category : #conversion }
Base32MimeConverter >> mimeDecode [
	"Convert a stream in base 32 with only A-Z,2-7,+,/ to a full byte stream of characters.  Reutrn a whole stream for the user to read."

	| nibA nibB nibC nibD nibE nibF nibG nibH |
	[ mimeStream atEnd ]
		whileFalse: [ 
			(nibA := self nextValue) ifNil: [ ^ dataStream ].
			(nibB := self nextValue) ifNil: [ ^ dataStream ].
			dataStream nextPut: ((nibA bitShift: 3) + (nibB bitShift: -2)) asCharacter.
			nibB := nibB bitAnd: 16r3.
			(nibC := self nextValue) ifNil: [ ^ dataStream ].
			(nibD := self nextValue) ifNil: [ ^ dataStream ].
			dataStream nextPut: ((nibB bitShift: 6) + (nibC bitShift: 1) + (nibD bitShift: -4)) asCharacter.
			nibD := nibD bitAnd: 16rF.
			(nibE := self nextValue) ifNil: [ ^ dataStream ].
			dataStream nextPut: ((nibD bitShift: 4) + (nibE bitShift: -1)) asCharacter.
			nibE := nibE bitAnd: 16r1.
			(nibF := self nextValue) ifNil: [ ^ dataStream ].
			(nibG := self nextValue) ifNil: [ ^ dataStream ].
			dataStream nextPut: ((nibE bitShift: 7) + (nibF bitShift: 2) + (nibG bitShift: -3)) asCharacter.
			nibG := nibG bitAnd: 16r7.
			(nibH := self nextValue) ifNil: [ ^ dataStream ].
			dataStream nextPut: ((nibG bitShift: 5) + nibH) asCharacter ].
	^ dataStream
]

{ #category : #conversion }
Base32MimeConverter >> mimeDecodeToByteArray [
	"Convert a stream in base 64 with only a-z,A-Z,0-9,+,/ to a full ByteArray of 0-255 values.  Reutrn a whole stream for the user to read."

	| nibA nibB nibC nibD |
	[mimeStream atEnd] whileFalse: [
		(nibA := self nextValue) ifNil: [^ dataStream].
		(nibB := self nextValue) ifNil: [^ dataStream].
		dataStream nextPut: ((nibA bitShift: 2) + (nibB bitShift: -4)).
		nibB := nibB bitAnd: 16rF.
		(nibC := self nextValue) ifNil: [^ dataStream].
		dataStream nextPut: ((nibB bitShift: 4) + (nibC bitShift: -2)).
		nibC := nibC bitAnd: 16r3.
		(nibD := self nextValue) ifNil: [^ dataStream].
		dataStream nextPut: ((nibC bitShift: 6) + nibD).
		].
	^ dataStream
]

{ #category : #conversion }
Base32MimeConverter >> mimeEncode [
	"Convert from data to 6 bit characters."

	| raw nib lineLength numBytes |
	lineLength := 0.
	numBytes := 0.
	[ dataStream atEnd ]
		whileFalse: [ 
			(multiLine and: [ lineLength >= 70 ])
				ifTrue: [ 
					mimeStream cr.
					lineLength := 0 ].
			data := raw := dataStream next asInteger.
			numBytes := numBytes + 1.
			nib := (data bitAnd: 16rF8) bitShift: -3.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			(raw := dataStream next) ifNil: [ raw := 0 ] ifNotNil: [ numBytes := numBytes + 1 ].
			data := ((data bitAnd: 16r7) bitShift: 8) + raw asInteger.
			nib := (data bitAnd: 16r7C0) bitShift: -6.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			nib := (data bitAnd: 16r3E) bitShift: -1.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			(raw := dataStream next) ifNil: [ raw := 0 ] ifNotNil: [ numBytes := numBytes + 1 ].
			data := ((data bitAnd: 16r1) bitShift: 8) + raw asInteger.
			nib := (data bitAnd: 16r1F0) bitShift: -4.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			(raw := dataStream next) ifNil: [ raw := 0 ] ifNotNil: [ numBytes := numBytes + 1 ].
			data := ((data bitAnd: 16rF) bitShift: 8) + raw asInteger.
			nib := (data bitAnd: 16rF80) bitShift: -7.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			nib := (data bitAnd: 16r7C) bitShift: -2.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			(raw := dataStream next) ifNil: [ raw := 0 ] ifNotNil: [ numBytes := numBytes + 1 ].
			data := ((data bitAnd: 16r3) bitShift: 8) + raw asInteger.
			nib := (data bitAnd: 16r3E0) bitShift: -5.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			nib := data bitAnd: 16r1F.
			mimeStream nextPut: (ToCharTable at: nib + 1).
			lineLength := lineLength + 8 ].
	numBytes \\ 5 > 0
		ifTrue: [ 
			mimeStream skip: (#(-7 -6 -4 -3 -1) at: numBytes \\ 5 + 1).
			(#(7 6 4 3 1) at: numBytes \\ 5 + 1) timesRepeat: [ mimeStream nextPut: $= ] ].
	^ mimeStream
]

{ #category : #accessing }
Base32MimeConverter >> multiLine [
	^ multiLine
]

{ #category : #accessing }
Base32MimeConverter >> multiLine: anObject [
	multiLine := anObject
]

{ #category : #conversion }
Base32MimeConverter >> nextValue [
	"The next six bits of data char from the mimeStream, or nil.  Skip all other chars"
	| raw num |
	[raw := mimeStream next.
	raw ifNil: [^ nil].	"end of stream"
	raw == $= ifTrue: [^ nil].
	num := FromCharTable at: raw asciiValue + 1.
	num ifNotNil: [^ num].
	"else ignore space, return, tab, ..."
	true] whileTrue.
]
