Class {
	#name : #PirateSeason,
	#superclass : #PostgresObject,
	#instVars : [
		'show',
		'episodes',
		'id'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateSeason >> addEpisode [
	| newEpisode |
	newEpisode := PirateEpisode new.
	newEpisode id: (self maxEpisode + 1) asTwoCharacterString.
	self addEpisode: newEpisode.
	^newEpisode
]

{ #category : #'as yet unclassified' }
PirateSeason >> addEpisode: anEpisode [
	episodes add: anEpisode.
	anEpisode season: self.
]

{ #category : #'as yet unclassified' }
PirateSeason >> addEpisodeNo: anInteger [
	| newEpisode |
	newEpisode := PirateEpisode new.
	newEpisode id: anInteger asTwoCharacterString.
	self addEpisode: newEpisode.
	^newEpisode
]

{ #category : #'as yet unclassified' }
PirateSeason >> delete [
	episodes do: [:e| e delete].
]

{ #category : #'as yet unclassified' }
PirateSeason >> episodes [ 
	^episodes 
]

{ #category : #'as yet unclassified' }
PirateSeason >> found [
	^ episodes
		select: [ :i  | i found]
]

{ #category : #'as yet unclassified' }
PirateSeason >> fullId [
	^ show name , ' S' , self id
]

{ #category : #'as yet unclassified' }
PirateSeason >> id [
	id isNil
		ifTrue: [^ 'undefined'].
	^ id
]

{ #category : #'as yet unclassified' }
PirateSeason >> id: aString [
	id := aString
]

{ #category : #'as yet unclassified' }
PirateSeason >> initialize [
	super initialize.
	episodes := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
PirateSeason >> lookForAll [
	^ episodes
		do: [:i | i lookForItIfNotFound]
]

{ #category : #accessing }
PirateSeason >> maxEpisode [
	"(Array with: '11' asInteger with: '12' asInteger )max ."
	| ids |
	episodes isEmptyOrNil ifTrue: [^0]. .
	ids := episodes
				collect: [:e | e id asInteger].
	^ ids max
]

{ #category : #'as yet unclassified' }
PirateSeason >> name [
	^show name
]

{ #category : #'as yet unclassified' }
PirateSeason >> newFound [
	^ episodes
		select: [:i | i newFound]
]

{ #category : #'as yet unclassified' }
PirateSeason >> nextEpisode [
	episodes isEmptyOrNil ifTrue: [^'E*'].

^'E*'
]

{ #category : #'as yet unclassified' }
PirateSeason >> notSeen [
	^ episodes
		select: [:i | i isViewable]
]

{ #category : #'as yet unclassified' }
PirateSeason >> printOn: aStream [ 
	aStream
		nextPutAll:  self seasonId
]

{ #category : #'as yet unclassified' }
PirateSeason >> resetUplinks: up [
	show := up.
	^ episodes
		do: [:i | i resetUplinks: self]
]

{ #category : #'as yet unclassified' }
PirateSeason >> seasonId [
	^ 'S' , self id
]

{ #category : #'as yet unclassified' }
PirateSeason >> show [
	^show
]

{ #category : #'as yet unclassified' }
PirateSeason >> show: aShow [
	^show := aShow
]
