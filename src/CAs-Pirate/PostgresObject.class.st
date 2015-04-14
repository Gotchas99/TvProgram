Class {
	#name : #PostgresObject,
	#superclass : #Object,
	#instVars : [
		'uuid'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PostgresObject >> initialize [
	super initialize.
	"uuid := UUID new."
]

{ #category : #'as yet unclassified' }
PostgresObject >> save [
	uuid isNil 
		ifTrue: [
			uuid := UUID new.
			]
		ifFalse: [  ].
]

{ #category : #'as yet unclassified' }
PostgresObject >> uuid [
	^uuid "ifNil: [uuid := UUID new.]"
]
