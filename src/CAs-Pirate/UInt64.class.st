"
Very basic functions for Unsigned 64-bit integer.
Read and stored as little endian
"
Class {
	#name : #UInt64,
	#superclass : #Object,
	#instVars : [
		'bytes'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
UInt64 class >> from: aByteArray [
	^self new bytes: aByteArray
]

{ #category : #'as yet unclassified' }
UInt64 class >> fromHex: aHexString [
	| b |
	b := ByteArray readHexFrom: aHexString.
	^ self from: b.

]

{ #category : #'as yet unclassified' }
UInt64 >> + term [
	| r c a b s |
	r := ByteArray new: 8.
	c := 0.
	1 to: 8 do: [:i| 
		a:=(bytes at: i).
		b := (term bytes at:  i) .
		s := a+b+c.
		r at: i put: (s bitAnd: 16rff).
		c := s >> 8.
	].
	^ UInt64 from: r.
]

{ #category : #'as yet unclassified' }
UInt64 >> = uint [
	1 to: 8 do: [:i| (bytes at: i) = (uint bytes at:  i) ifFalse: [ ^false ]].
	
	^ true.
]

{ #category : #'as yet unclassified' }
UInt64 >> adaptToInteger: rcvr andSend: selector [
	"If I am involved in arithmetic with an Integer, convert myself to Integer."
	^ rcvr  perform: selector with: self asInteger 
]

{ #category : #'as yet unclassified' }
UInt64 >> asHex [

	^ self asInteger printStringHex 
]

{ #category : #'as yet unclassified' }
UInt64 >> asInteger [
	| accum |
	accum := 0.
	8 to: 1 by: -1do: [:i| accum :=(accum bitShift: 8) + (bytes at: i) ].
	^ accum
]

{ #category : #'as yet unclassified' }
UInt64 >> bytes [
	^bytes
]

{ #category : #'as yet unclassified' }
UInt64 >> bytes: aByteArray [
	bytes := ByteArray new: 8.
	1 to: (aByteArray size min: 8) do: [:i| bytes at: i put: (aByteArray at:  i)].
	^ self
]

{ #category : #'as yet unclassified' }
UInt64 >> printOn: aStream [ 
	aStream nextPutAll:  'Uint64(', self asHex, ')'
]
