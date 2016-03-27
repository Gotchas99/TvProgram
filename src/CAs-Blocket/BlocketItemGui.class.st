Class {
	#name : #BlocketItemGui,
	#superclass : #ComposableModel,
	#instVars : [
		'list',
		'listIndex',
		'model',
		'theButton',
		'theList',
		'item',
		'refreshButton'
	],
	#category : #'CAs-Blocket-Gui'
}

{ #category : #'as yet unclassified' }
BlocketItemGui class >> defaultSpec [
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
BlocketItemGui class >> on: anItem [
	^self new item: anItem
]

{ #category : #'as yet unclassified' }
BlocketItemGui >> initializePresenter [
	theList whenSelectedItemChanged: [ :new | theButton enabled: new isNil not ].
	theButton action: [ self openIt: theList selectedItem ].
	refreshButton action: [ self refresh ]
]

{ #category : #'as yet unclassified' }
BlocketItemGui >> initializeWidgets [
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
BlocketItemGui >> item: anItem [
	item := anItem.
	self title: anItem printString.
	theList items: #(1 2 3 4 5)

]

{ #category : #'as yet unclassified' }
BlocketItemGui >> refreshButton [
	^refreshButton
]

{ #category : #'as yet unclassified' }
BlocketItemGui >> theButton [
	^theButton
]

{ #category : #'as yet unclassified' }
BlocketItemGui >> theList [
	^theList
]
