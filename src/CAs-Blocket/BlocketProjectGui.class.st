Class {
	#name : #BlocketProjectGui,
	#superclass : #ComposableModel,
	#instVars : [
		'theButton',
		'theList',
		'project',
		'refreshButton'
	],
	#category : #'CAs-Blocket-Gui'
}

{ #category : #'as yet unclassified' }
BlocketProjectGui class >> defaultSpec [
	^ SpecLayout composed
		newRow: [ :row | 
					row
						newColumn: [ :column | column add: #theList ];
						newColumn: [ :column | 
									column
										add: #theButton;
										add: #refreshButton ]
							width: self buttonWidth ];
		yourself
]

{ #category : #'as yet unclassified' }
BlocketProjectGui class >> on: aProject [
	^self new project: aProject.
]

{ #category : #'as yet unclassified' }
BlocketProjectGui class >> title [

	^ 'Blocket'
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> bild [
(ImageMorph fromStream:(
  ZnClient new
    beOneShot;
    url: 'http://cdn.blocket.com/static/1/lithumbs/24/2418980813.jpg';
    get) readStream) openInWorld
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> initializePresenter [
	theList whenSelectedItemChanged: [ :new | theButton enabled: new isNil not ].
	theButton action: [ self openIt: theList selectedItem ].
	refreshButton action: [ self refresh ]
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> initializeWidgets [
	(theButton := self newButton)
		label: 'Öppna';
		disable.
	(refreshButton := self newButton) label: 'Refresh'.
	theList := NewListModel new.
	self focusOrder
		add: theButton;
		add: theList
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> openIt: anItem [
	(BlocketItemGui on: anItem) openWithSpec
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> project: aProject [
	project := aProject.
	self title: aProject printString.
	theList items: project result.

]

{ #category : #action }
BlocketProjectGui >> refresh [
	Cursor wait
		showWhile: [ 
			project refresh.
			theList items: project result ]
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> refreshButton [
	^refreshButton
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> theButton [
	^theButton
]

{ #category : #'as yet unclassified' }
BlocketProjectGui >> theList [
	^theList
]
