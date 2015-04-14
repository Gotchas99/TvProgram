Class {
	#name : #PirateNewMorph,
	#superclass : #BlocketRootMorph,
	#instVars : [
		'shows',
		'listIndex',
		'model'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'as yet unclassified' }
PirateNewMorph >> addControls [
	| r lst btnPanel morph |
	self
		addMorphBack: (StringMorph contents: 'Title: ').

	lst := PluggableMultiColumnListMorph
				on: self
				list: #list
				selected: #listIndex
				changeSelected: #listIndex:.
		"		menu: #listMenu:."
	lst doubleClickSelector: #dblClick.
	lst wrapSelector: #getEpisodeText:  .
	lst color: Color white.
	lst extent: 400 @ 500.
	self addMorphBack: lst.
	
	btnPanel := self newRow.
	btnPanel color: Color transparent;
		 borderWidth: 0;
		 layoutInset: 2;
		 wrapCentering: #center;
		 cellPositioning: #topCenter;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 extent: 5 @ 5.
	self addMorphBack: btnPanel.
	btnPanel
		addMorphBack: (self newButton: 'Refresh' do: #refresh).
"	btnPanel
		addMorphBack: (self newButton: 'Play' do: #play).
	btnPanel
		addMorphBack: (self newButton: 'Subtitles...' do: #subtitles).
"	"------------------------------------"
	r := AlignmentMorph newRow color: Color transparent;
				 borderWidth: 0;
				 layoutInset: 0.
	r wrapCentering: #center;
		 cellPositioning: #topCenter;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 extent: 5 @ 5.
	r
		addMorphBack: (self newButton: 'Close' do: #delete).
	r addTransparentSpacerOfSize: 8 @ 0.
	self addMorphFront: r
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> dblClick [
	self open 
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> getEpisodeText: anEpisode [

 ^{anEpisode season show name.
	anEpisode season id.
	anEpisode id. 
	(anEpisode hasSubtitle)ifTrue:['subs']ifFalse:[' - '].
	}.
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> icon [
	^ nil
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> list [
	model
		ifNil: [^ nil].
	^ model
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> listIndex [
	^ listIndex
		ifNil: [listIndex := 0]
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> listIndex: aSmallInteger [ 
	listIndex := aSmallInteger.
	self changed: #listIndex.
	
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> model:  allShows [ 
	shows := allShows.
	self refresh.

]

{ #category : #'as yet unclassified' }
PirateNewMorph >> open [
	| m ep |
	listIndex > 0
		ifTrue: [m := PirateEpisodeMorph new.
			ep := model at: listIndex.
			m model: ep.
			m openInWorld.
			]
]

{ #category : #'as yet unclassified' }
PirateNewMorph >> refresh [
	| tmp |
	model := OrderedCollection new.
	tmp := shows collect: [:s|s newEpisode].
	model := tmp reject: [:i| i isNil].
	self changed: #list.

]
