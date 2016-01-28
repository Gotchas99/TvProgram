Class {
	#name : #PirateRootMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'pageHolder'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'as yet unclassified' }
PirateRootMorph >> columnWith: aMorph [ 
	^ self newColumn addMorph: aMorph
]

{ #category : #'as yet unclassified' }
PirateRootMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self extent: 400 @ 500;
		 listDirection: #topToBottom;
		 wrapCentering: #topLeft;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 layoutInset: 3;
		 borderColor: Color black;borderWidth:2.
	"Display extent - 100;"
	"pageHolder := PasteUpMorph new behaveLikeHolder extent: self
	extent - self borderWidth"
	"pageHolder := AlignmentMorph new extent: self extent - self
	borderWidth; hResizing: #shrinkWrap."
	self addControls
]

{ #category : #'as yet unclassified' }
PirateRootMorph >> newButton: displayText do: aMessageSelector [ 
	| bb |
	bb := SimpleButtonMorph new target: self;
				 borderColor: Color black;
				 label: displayText translated;
				 actionSelector: aMessageSelector.
	^ bb
]

{ #category : #'as yet unclassified' }
PirateRootMorph >> newColumn [
	^ AlignmentMorph new
		listDirection: #topToBottom;
		extent: 1@1
;color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #topCenter;
		layoutInset: 1

]

{ #category : #'as yet unclassified' }
PirateRootMorph >> newRow [
	^ AlignmentMorph   new listDirection: #leftToRight;
		 extent: 1 @ 1;
		 borderWidth: 0;
		 color: Color transparent;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 wrapCentering: #center;
		 cellPositioning: #topCenter;
		 layoutInset: 1
]

{ #category : #'as yet unclassified' }
PirateRootMorph >> rowWith: aMorph [ 
	^ self newRow addMorph: aMorph
]

{ #category : #'as yet unclassified' }
PirateRootMorph >> wrapperFor: aMorph [

	^self columnWith: (self rowWith: aMorph)
]
