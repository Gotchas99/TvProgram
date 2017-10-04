Class {
	#name : #PirateViewable,
	#superclass : #ComposableModel,
	#instVars : [
		'listMain',
		'btnRefresh',
		'btnPlay',
		'btnSubs',
		'btnTopSub',
		'chkOnlyOld',
		'playingEp'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #specs }
PirateViewable class >> defaultSpec [
	^ SpecLayout composed
		newColumn: [ :mainColumn | 
			mainColumn newRow: [ :rowName | rowName add: #listMain ].
			mainColumn
				newRow: [ :rowTitle | 
					rowTitle
						newRow: [ :rowTitleButtons | 
							rowTitleButtons
								add: #btnRefresh;
								add: #btnPlay;
								add: #btnSubs;
								add: #btnTopSub;
								add: #chkOnlyOld ] ] 
						height: self buttonHeight];
		"Adding Main column"
			yourself
]

{ #category : #specs }
PirateViewable class >> title [
	^'Viewables'
]

{ #category : #initialization }
PirateViewable >> beginFilter [
	^ [ :i | i id = '01' and: [ i season id = '01' ] ]
]

{ #category : #accessing }
PirateViewable >> btnPlay [
	^ btnPlay
]

{ #category : #accessing }
PirateViewable >> btnPlay: anObject [
	btnPlay := anObject
]

{ #category : #accessing }
PirateViewable >> btnRefresh [
	^ btnRefresh
]

{ #category : #accessing }
PirateViewable >> btnRefresh: anObject [
	btnRefresh := anObject
]

{ #category : #accessing }
PirateViewable >> btnSubs [
	^ btnSubs
]

{ #category : #accessing }
PirateViewable >> btnSubs: anObject [
	btnSubs := anObject
]

{ #category : #accessing }
PirateViewable >> btnTopSub [
	^ btnTopSub
]

{ #category : #accessing }
PirateViewable >> btnTopSub: anObject [
	btnTopSub := anObject
]

{ #category : #accessing }
PirateViewable >> chkOnlyOld [
	^ chkOnlyOld
]

{ #category : #accessing }
PirateViewable >> chkOnlyOld: anObject [
	chkOnlyOld := anObject
]

{ #category : #initialization }
PirateViewable >> initializePresenter [
	"	textName whenTextChanged: [ buttonGreet enable ]."

	btnRefresh action: [ self refresh ].
	btnPlay action: [ self play ].
	btnSubs action: [ self subtitles ].
	btnTopSub action: [ self topSubtitles ].
	chkOnlyOld
		whenChangedDo: [ chkOnlyOld state
				ifTrue: [ listMain filteringBlock: [ :a | a reject: self beginFilter ] ]
				ifFalse: [ listMain filteringBlock: [ :a | a select: self beginFilter ] ] ].
]

{ #category : #initialization }
PirateViewable >> initializeWidgets [
	self
		instantiateModels:
			#(listMain MultiColumnListModel btnRefresh ButtonModel btnPlay ButtonModel btnSubs ButtonModel btnTopSub ButtonModel chkOnlyOld CheckBoxModel).
	btnRefresh
		label: 'Refresh';
		enable.
	btnPlay
		label: 'Play';
		enable.
	btnSubs
		label: 'Subtitles';
		enable.
	btnTopSub
		label: 'Top Subtitle';
		enable.
	listMain
		autoDeselect: false;
		beSingleSelection;
		displayBlock: [ :x | 
			{(x isPaused
				ifTrue: [ '⏸ ' ]
				ifFalse: [ '▶' ]).
			x season show displayName.
			x season id.
			x id.
			((x needsSubtitle
				ifFalse: [ 'yes' ]
				ifTrue: [ 'no' ]) , ' subs').
			(x season downloaded
				ifFalse: [ 'episode' ]
				ifTrue: [ 'season' ])} ];
		items: 'loading..'.
	self refresh.
	chkOnlyOld
		label: 'The show must go on';
		click
]

{ #category : #accessing }
PirateViewable >> listMain [
	^ listMain
]

{ #category : #accessing }
PirateViewable >> listMain: anObject [
	listMain := anObject
]

{ #category : #action }
PirateViewable >> play [
	| ep |
	"self listIndex = 0
		ifTrue: [ ^ self ]."
	ep := listMain selectedItem.
	ep isDownloaded
		ifTrue: [ 
			playingEp := ep.
			ep when: #stopped send: #playStopped to: self.
			ep play ]
]

{ #category : #playing }
PirateViewable >> playStopped [
	(self confirm: 'Did you see the entire show?')
		ifTrue: [ playingEp viewed.
			[ playingEp season show lookForAll ] fork ].
	playingEp removeActionsWithReceiver: self.
	self refresh.
	self changed: #list	"(self confirm: 'Subtitles OK?') ifTrue: [  ]."
]

{ #category : #action }
PirateViewable >> refresh [
	| tmp index size |
	index := listMain selectedIndex.
	size := listMain listSize.
	tmp := PirateShow shows collect: [ :s | s nextToSee ].
	tmp := tmp reject: [ :i | i isNil ].
	tmp := tmp select: [ :e | e isViewable ].
	listMain items: tmp.
	listMain listSize = size
		ifFalse: [ index := 0 ].
	listMain setSelectedIndex: index
]

{ #category : #action }
PirateViewable >> subtitles [
	| ep m |
	"(self listIndex = 0) ifTrue: [^self]."
	ep := listMain selectedItem.
	ep isDownloaded
		ifTrue: [ m := PirateSubtitleMorph new.
			m model: ep.
			m openInWorld.
			self changed: #list ]
]

{ #category : #action }
PirateViewable >> topSubtitles [
	| ep |
	"self listIndex = 0
		ifTrue: [ ^ self ]."
	ep := listMain selectedItem.
	ep isDownloaded
		ifTrue: [ 
			ep topSubtitles.
			self changed: #list ]
]
