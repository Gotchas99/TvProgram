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
			mainColumn
				newRow: [ :rowName | 
					rowName
						add: #listMain].
			mainColumn
				newRow: [ :rowTitle | 
					rowTitle
							newRow: [ :rowTitleButtons | 
							rowTitleButtons
								add: #btnRefresh;
								add: #btnPlay;
								add: #btnSubs;
								add: #btnTopSub;
								add: #chkOnlyOld ] ] ];
		"Adding Main column"
			yourself
]

{ #category : #specs }
PirateViewable class >> title [
	^'Viewables'
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

	btnRefresh action: [ listMain items: self refresh ].
	btnPlay action: [ self play ]
]

{ #category : #initialization }
PirateViewable >> initializeWidgets [
	self
		instantiateModels:
			#(listMain ListModel btnRefresh ButtonModel btnPlay ButtonModel btnSubs ButtonModel btnTopSub ButtonModel chkOnlyOld CheckBoxModel).
	btnRefresh
		label: 'Refresh';
		enable.
	btnPlay
		label: 'Play';
		enable.
	btnSubs
		label: 'Subtitles';
		disable.
	btnTopSub
		label: 'Top Subtitle';
		disable.
	chkOnlyOld
		label: 'The show must go on';
		state: true.
	listMain
		autoDeselect: false;
		beSingleSelection;
		items: self refresh

	"	labelGreeting label: ''.
	textName autoAccept: true.
	buttonGreet
		label: 'Greet Me!';
		disable.
	self setupTitleRadioButtons.
	labelName label: 'Your name, please?'.
	labelTitle label: 'Your title, please?'"
]

{ #category : #accessing }
PirateViewable >> listMain [
	^ listMain
]

{ #category : #accessing }
PirateViewable >> listMain: anObject [
	listMain := anObject
]

{ #category : #playing }
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
		ifTrue: [ playingEp viewed .
			[playingEp season show lookForAll ]fork].
	playingEp removeActionsWithReceiver: self.
	self refresh.
	self changed: #list	"(self confirm: 'Subtitles OK?') ifTrue: [  ]."
]

{ #category : #refreshing }
PirateViewable >> refresh [
	| tmp |
	tmp := (PirateShow shows) collect: [ :s | s nextToSee ].
	tmp := tmp reject: [ :i | i isNil ].
	tmp := tmp select: [ :e | e isViewable ].
	"self showsStarted"
	(chkOnlyOld state)
		ifTrue: [ tmp := tmp reject: [ :i | i id = '01' and: [ i season id = '01' ] ] ]
		ifFalse: [ tmp := tmp select: [ :i | i id = '01' and: [ i season id = '01' ] ] ].
	^ tmp.
]
