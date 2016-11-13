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

{ #category : #comparing }
PirateSeason >> <= aPirateSeason [
	self species == aPirateSeason species
		ifTrue: [ ^ self fullId caseInsensitiveLessOrEqual: aPirateSeason fullId ]
		ifFalse: [ ^ false ]
]

{ #category : #adding }
PirateSeason >> addEpisode [
	| newEpisode |
	newEpisode := PirateEpisode new.
	newEpisode id: (self maxEpisode + 1) asTwoCharacterString.
	self addEpisode: newEpisode.
	^newEpisode
]

{ #category : #adding }
PirateSeason >> addEpisode: anEpisode [
	anEpisode season: self.
	(episodes isKindOf: SortedCollection)
		ifFalse: [ episodes := episodes asSortedCollection ].
	episodes add: anEpisode
]

{ #category : #adding }
PirateSeason >> addEpisodeNo: anInteger [
	| newEpisode |
	newEpisode := PirateEpisode new.
	newEpisode id: anInteger asTwoCharacterString.
	self addEpisode: newEpisode.
	^newEpisode
]

{ #category : #adding }
PirateSeason >> addEpisodes: newMax [
	[ self maxEpisode < newMax ] whileTrue: [ self addEpisode ]
]

{ #category : #actions }
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

{ #category : #testing }
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

{ #category : #accessing }
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

{ #category : #initialization }
PirateSeason >> initialize [
	super initialize.
	episodes := SortedCollection new.
]

{ #category : #testing }
PirateSeason >> isViewed [
	^ episodes isEmptyOrNil
		ifTrue: [ ^ true ]
		ifFalse: [ episodes last isViewed ]
]

{ #category : #actions }
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

{ #category : #accessing }
PirateSeason >> newFound [
	^ episodes
		select: [:i | i newFound]
]

{ #category : #accessing }
PirateSeason >> notSeen [
	^ episodes
		select: [:i | i isViewable]
]

{ #category : #printing }
PirateSeason >> printOn: aStream [ 
	aStream
		nextPutAll:  self seasonId
]

{ #category : #actions }
PirateSeason >> removeEpisode: anEpisode [
	episodes remove: anEpisode.

]

{ #category : #temporaries }
PirateSeason >> resetUplinks: up [
	show := up.
	^ episodes
		do: [:i | i resetUplinks: self]
]

{ #category : #accessing }
PirateSeason >> seasonId [
	^ 'S' , self id
]

{ #category : #accessing }
PirateSeason >> setFullId [
	(show isNotNil and: [ id isNotNil ])
		ifTrue: [ fullId := show name , ' S' , self id ]
]

{ #category : #temporaries }
PirateSeason >> setSortedCollection [
	episodes := episodes asSortedCollection
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
