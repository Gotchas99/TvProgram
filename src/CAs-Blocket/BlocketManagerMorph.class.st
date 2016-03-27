Class {
	#name : #BlocketManagerMorph,
	#superclass : #BlocketRootMorph,
	#instVars : [
		'list',
		'listIndex',
		'model'
	],
	#category : #'CAs-Blocket-Morph'
}

{ #category : #'as yet unclassified' }
BlocketManagerMorph class >> test [
	self new openInWorld
]

{ #category : #'as yet unclassified' }
BlocketManagerMorph >> addControls [
	| bb r  lst |

"	title := TextMorph new extent: 140@130.
	pageHolder addMorphBack: title."
lst := PluggableMultiColumnListMorph 
on: self "I am the model that has a list to display"
list: #list "This is how the morph gets the list from me"
selected: #listIndex "This is how the morph knows which item to highlight"
changeSelected: #listIndex: "This is how the morph informs me of a user selection"
menu: #listMenu:. "This is how the morph requests a menu for the list"
lst doubleClickSelector: #dblClick.
lst color: Color white.
	lst extent: 240@330.
	self addMorphBack: lst.
	
"	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'refresh' 
		translated;	actionSelector: #refresh)).
"

	r := AlignmentMorph newRow color: Color transparent; borderWidth: 0; layoutInset: 0.
	r wrapCentering: #center; cellPositioning: #topCenter; 
			hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
			
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Stäng' translated;	actionSelector: #delete)).

	r addTransparentSpacerOfSize: 8 @ 0.
	self addMorphFront: r.

]

{ #category : #'as yet unclassified' }
BlocketManagerMorph >> dblClick [
"	self inform: 'dubbelclickade'."
	(listIndex > 0) ifTrue: [ (BlocketMorph on: (model at: listIndex)) openInWorld.].
"	self updateList"
]

{ #category : #'as yet unclassified' }
BlocketManagerMorph >> initialize [
	model := BlocketManager current projects.
	super initialize.

]

{ #category : #'as yet unclassified' }
BlocketManagerMorph >> list [
	model ifNil: [^nil] .
	^Array with: (model collect:  [:i | i name]).
"	^ #(#date #title #isViewed #price #oldPrice) 
		collect: [ :f | 
			model collect: [:i| i perform: f ] ].
"
]

{ #category : #'as yet unclassified' }
BlocketManagerMorph >> listIndex [
	^listIndex ifNil: [listIndex:=0].
]

{ #category : #'as yet unclassified' }
BlocketManagerMorph >> listIndex: anInteger [
	listIndex := anInteger.
	self changed: #listIndex
]
