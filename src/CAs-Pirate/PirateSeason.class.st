Class {
	#name : #PirateSeason,
	#superclass : #Object,
	#instVars : [
		'show',
		'episodes',
		'id',
		'fullId'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateSeason >> <= aPirateSeason [
	^(self fullId) caseInsensitiveLessOrEqual: (aPirateSeason fullId).
]

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
	anEpisode season: self.
	(episodes isKindOf: SortedCollection)
		ifFalse: [ episodes := episodes asSortedCollection ].
	episodes add: anEpisode
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
PirateSeason >> addEpisodes: newMax [
	[ self maxEpisode < newMax ] whileTrue: [ self addEpisode ]
]

{ #category : #'as yet unclassified' }
PirateSeason >> delete [
	| ep |
	"episodes do: [:e| e delete]. Doesn't work to change the collection you iterate over"
	[ episodes size > 0 ]
		whileTrue: [ 
			ep := episodes at: 1.
			ep delete ].
	show removeSeason: self.
	show := nil	
"	super delete."
]

{ #category : #'as yet unclassified' }
PirateSeason >> downloaded [
	"Is the entire season download, i.e. viewed or viewable"

	| complete |
	complete := episodes noneSatisfy: [ :ep | ep isViewed not and: [ ep isViewable not ] ].
	^ complete
]

{ #category : #accessing }
PirateSeason >> episodes [ 
	^episodes 
]

{ #category : #'as yet unclassified' }
PirateSeason >> found [
	^ episodes
		select: [ :i  | i found]
]

{ #category : #accessing }
PirateSeason >> fullId [
	^ fullId 
]

{ #category : #accessing }
PirateSeason >> id [
	id isNil
		ifTrue: [ ^ 'undefined' ].
	^ id
]

{ #category : #accessing }
PirateSeason >> id: aString [
	id := aString.
	self setFullId
]

{ #category : #'as yet unclassified' }
PirateSeason >> initialize [
	super initialize.
	episodes := SortedCollection new.
]

{ #category : #'as yet unclassified' }
PirateSeason >> isViewed [
	^ episodes isEmptyOrNil
		ifTrue: [ ^ true ]
		ifFalse: [ episodes last isViewed ]
]

{ #category : #'as yet unclassified' }
PirateSeason >> lookForAll [
	self isViewed
		ifFalse: [ episodes do: [ :i | i lookForItIfNotFound ] ]
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

{ #category : #accessing }
PirateSeason >> name [
	^show name
]

{ #category : #'as yet unclassified' }
PirateSeason >> newFound [
	^ episodes
		select: [:i | i newFound]
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
PirateSeason >> removeEpisode: anEpisode [
	episodes remove: anEpisode.

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

{ #category : #accessing }
PirateSeason >> setFullId [
	fullId := show name , ' S' , self id
]

{ #category : #accessing }
PirateSeason >> show [
	^show
]

{ #category : #accessing }
PirateSeason >> show: aShow [
	show := aShow.
	self setFullId
]
