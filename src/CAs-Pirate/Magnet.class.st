Class {
	#name : #Magnet,
	#superclass : #Object,
	#instVars : [
		'uri',
		'infoHash',
		'name'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
Magnet class >> from: anUri [
	anUri isEmptyOrNil
		ifTrue: [ ^ nil ].
	^ self new from: anUri
]

{ #category : #'as yet unclassified' }
Magnet >> = aMagnet [
	^ self species == aMagnet species and: [ self infoHash = aMagnet infoHash ]
]

{ #category : #'as yet unclassified' }
Magnet >> from: anUri [
	uri:= anUri
]

{ #category : #'as yet unclassified' }
Magnet >> hashX [
self halt.
	^ self infoHash
]

{ #category : #'as yet unclassified' }
Magnet >> infoHash [
	| parts xt hash |
	^ infoHash
		ifNil: [ 
			(uri includesSubstring: '?')
				ifFalse: [ hash := uri ]
				ifTrue: [ 
					parts := (uri substrings: '?') second substrings: '&'.
					xt := parts select: [ :i | i beginsWith: 'xt=urn:btih:' ].
					hash := (xt first substrings: ':') third ].
			hash size = 32
				ifTrue: [ hash := (Base32MimeConverter mimeDecodeToChars: hash readStream) contents asByteArray hex ].
			infoHash := hash asLowercase ]
]

{ #category : #'as yet unclassified' }
Magnet >> name [
	| parts xt |
	^ name
		ifNil: [ 
			(uri includesSubstring: '?')
				ifFalse: [ name := '<Unknown>' ]
				ifTrue: [ 
					parts := (uri substrings: '?') second substrings: '&'.
					xt := parts select: [ :i | i beginsWith: 'dn=' ].
					name := (xt first substrings: '=') second ] ]
]

{ #category : #'as yet unclassified' }
Magnet >> uri [
	^ uri
]
