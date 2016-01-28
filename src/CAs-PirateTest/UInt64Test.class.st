Class {
	#name : #UInt64Test,
	#superclass : #TestCase,
	#instVars : [
		'u1',
		'u2'
	],
	#category : #'CAs-PirateTest'
}

{ #category : #'as yet unclassified' }
UInt64Test >> setUp [
"	self assert: (full includes: 6). 
	self deny: (full includes: 5)"
	| b |
	b := ByteArray readHexFrom: '0102000000000000'.
	u1 := UInt64 from: b.
	b := ByteArray readHexFrom: '0304000000000000'.
	u2 := UInt64 from: b.
]

{ #category : #'as yet unclassified' }
UInt64Test >> testAdd [
	self assert: ((u1 + u2) asInteger =  1540).
]

{ #category : #'as yet unclassified' }
UInt64Test >> testCreate [
"	self assert: (full includes: 6). 
	self deny: (full includes: 5)"
	| b u |
	b := ByteArray readHexFrom: '0102000000000000'.
	self assert: (b size = 8).
	u := UInt64 from: b.
]

{ #category : #'as yet unclassified' }
UInt64Test >> testEqual [
	self assert: (u1 = u1).
]

{ #category : #'as yet unclassified' }
UInt64Test >> testFromHex [
"	self assert: (full includes: 6). 
	self deny: (full includes: 5)"
	| b x y |
	b := ByteArray readHexFrom: '0102000000000000'.
	x := UInt64 from: b.
	y := UInt64 fromHex: '0102000000000000'.
	self assert: (x = y).
]

{ #category : #'as yet unclassified' }
UInt64Test >> testInt [
"	self assert: (full includes: 6). 
	self deny: (full includes: 5)"
	| b u |
	b := ByteArray readHexFrom: '0102000000000000'.
	self assert: (b size = 8).
	u := UInt64 from: b.
	self assert: (u asInteger = 513).
]

{ #category : #'as yet unclassified' }
UInt64Test >> testNotEqual [
	self assert: ((u1 = u2) not).
]

{ #category : #'as yet unclassified' }
UInt64Test >> testToHex [
"	self assert: (full includes: 6). 
	self deny: (full includes: 5)"
	| h1 |
	h1 := u1 asHex.
	self assert: (h1 = 513 printStringHex).
]
