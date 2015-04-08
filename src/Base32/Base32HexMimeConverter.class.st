Class {
	#name : #Base32HexMimeConverter,
	#superclass : #Base32MimeConverter,
	#category : #Base32
}

{ #category : #'class initialization' }
Base32HexMimeConverter class >> initialize [
	FromCharTable := Array new: 256.	"nils"
	ToCharTable := Array new: 64.
	($0 asciiValue to: $9 asciiValue)
		doWithIndex: [ :val :ind | 
			FromCharTable at: val + 1 put: ind - 1.
			ToCharTable at: ind put: val asCharacter ].
	($A asciiValue to: $V asciiValue)
		doWithIndex: [ :val :ind | 
			FromCharTable at: val + 1 put: ind + 9.
			ToCharTable at: ind + 10 put: val asCharacter ].
	FromCharTable at: $+ asciiValue + 1 put: 62.
	ToCharTable at: 63 put: $+.
	FromCharTable at: $/ asciiValue + 1 put: 63.
	ToCharTable at: 64 put: $/
]
