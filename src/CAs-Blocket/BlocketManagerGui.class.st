Class {
	#name : #BlocketManagerGui,
	#superclass : #ComposableModel,
	#instVars : [
		'theButton',
		'theList'
	],
	#category : #'CAs-Blocket-Gui'
}

{ #category : #'as yet unclassified' }
BlocketManagerGui class >> defaultSpec [
	^ SpecLayout composed
		newRow: [ :row | 
					row
						newColumn: [ :column | column add: #theList ];
						newColumn: [ :column | column add: #theButton ] ];
		yourself
]

{ #category : #'as yet unclassified' }
BlocketManagerGui class >> example [
	self new openWithSpec.
]

{ #category : #'as yet unclassified' }
BlocketManagerGui class >> title [

	^ 'Blocket'
]

{ #category : #'as yet unclassified' }
BlocketManagerGui >> initializePresenter [
	theList whenSelectedItemChanged: [ :new | theButton enabled: new isNil not ].
	theButton action: [ self openIt: theList selectedItem ]
]

{ #category : #'as yet unclassified' }
BlocketManagerGui >> initializeWidgets [
	(theButton := self newButton)
		label: 'Öppna';
		disable.
	theList := NewListModel new.
	self focusOrder
		add: theButton;
		add: theList.
	theList items: self items
]

{ #category : #'as yet unclassified' }
BlocketManagerGui >> items [
	^ BlocketManager current projects ."collect: [ :i | i printString ]"
]

{ #category : #'as yet unclassified' }
BlocketManagerGui >> openIt: aProject [
	(BlocketProjectGui on: aProject) openWithSpec
]

{ #category : #'as yet unclassified' }
BlocketManagerGui >> theButton [
	^theButton
]

{ #category : #'as yet unclassified' }
BlocketManagerGui >> theList [
	^theList
]
