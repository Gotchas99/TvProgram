Class {
	#name : #PirateViewableMorph,
	#superclass : #PirateRootMorph,
	#instVars : [
		'shows',
		'listIndex',
		'model',
		'showsStarted',
		'playingEp'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'as yet unclassified' }
PirateViewableMorph >> addControls [
	| r lst btnPanel morph started |
	started := CheckboxMorph on: self selected: #showsStarted changeSelected: #showStarted.
	started label: 'Show only started'.
	started height: 20.
	self addMorphBack: started.
	lst := PluggableMultiColumnListMorph
				on: self
				list: #list
				selected: #listIndex
				changeSelected: #listIndex:.
		"		menu: #listMenu:."
	lst doubleClickSelector: #dblClick.
	lst wrapSelector: #getEpisodeText:  .
	lst color: Color white.
	lst extent: 400 @ 400.
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
	btnPanel
		addMorphBack: (self newButton: 'Play' do: #play).
	btnPanel
		addMorphBack: (self newButton: 'Subtitles...' do: #subtitles).
	btnPanel
		addMorphBack: (self newButton: 'Top Sub' do: #topSubtitles).
	"------------------------------------"
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
PirateViewableMorph >> dblClick [
	"	self inform: 'dubbelclickade'."
	listIndex > 0
		ifTrue: [ self play ]
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> getEpisodeText: anEpisode [
	^ {(anEpisode hasSubtitle
		ifTrue: [ '*' ]
		ifFalse: [ '' ]).
	(anEpisode season show name).
	(anEpisode season id).
	(anEpisode id).
	(anEpisode hasSubtitle
		ifTrue: [ 'subs' ]
		ifFalse: [ ' - ' ])}
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> icon [
	^ nil
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> list [
	model
		ifNil: [^ nil].
	^ model
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> listIndex [
	^ listIndex
		ifNil: [listIndex := 0]
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> listIndex: aSmallInteger [ 
	listIndex := aSmallInteger.
	self changed: #listIndex.
	
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> model:  allShows [ 
	shows := allShows.
	self refresh.

]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> play [
	| ep |
	self listIndex = 0
		ifTrue: [ ^ self ].
	ep := model at: listIndex.
	ep isDownloaded
		ifTrue: [ 
			playingEp := ep.
			ep when: #stopped send: #playStopped to: self.
			ep play ]
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> playStopped [
	(self confirm: 'Did you see the entire show?')
		ifTrue: [ playingEp viewed ].
	playingEp removeActionsWithReceiver: self.
	self refresh.
	self changed: #list	"(self confirm: 'Subtitles OK?') ifTrue: [  ]."
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> refresh [
	| tmp |
	model := OrderedCollection new.
	tmp := shows collect: [ :s | s nextToSee ].
	tmp := tmp reject: [ :i | i isNil ].
	tmp := tmp select: [ :e | e isViewable ].
	self showsStarted
		ifTrue: [ tmp := tmp reject: [ :i | i id = '01' and: [ i season id = '01' ] ] ]
		ifFalse: [ tmp := tmp select: [ :i | i id = '01' and: [ i season id = '01' ] ] ].
	model := tmp.
	self changed: #list
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> showStarted [
	showsStarted :=self showsStarted not.
	self refresh.
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> showsStarted [
	showsStarted
		ifNil: [showsStarted := true].
	^ showsStarted
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> step [
	| t |
	t := [ self refresh ] timeToRun.
"	Transcript crShow: 'step... time: ' , t printString"
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> stepTime [
	^2100
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> subtitles [
	| ep m |
		(self listIndex = 0) ifTrue: [^self].

	ep := model at: listIndex.

	ep isDownloaded
		ifTrue: [ 
			m:=PirateSubtitleMorph new.
			m model: ( ep).
			m openInWorld.
			self changed: #list			 
		]
]

{ #category : #'as yet unclassified' }
PirateViewableMorph >> topSubtitles [
	| ep |
	self listIndex = 0
		ifTrue: [ ^ self ].
	ep := model at: listIndex.
	ep isDownloaded
		ifTrue: [ 
			ep topSubtitles.
			self changed: #list ]
]
