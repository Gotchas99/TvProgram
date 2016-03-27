Class {
	#name : #BlocketMorph,
	#superclass : #AlignmentMorph,
	#instVars : [
		'pageHolder',
		'listIndex',
		'model',
		'project',
		'title'
	],
	#category : #'CAs-Blocket-Morph'
}

{ #category : #'as yet unclassified' }
BlocketMorph class >> on: aBlocketProject [
	^self  new on: aBlocketProject
]

{ #category : #'as yet unclassified' }
BlocketMorph class >> onRobot: aBlocketRobot [
	^self  new on: aBlocketRobot
]

{ #category : #'as yet unclassified' }
BlocketMorph >> addControls [

	| bb r lst |
	listIndex :=0.

	title := TextMorph new extent: 140@130.
	pageHolder addMorphBack: title.

 	lst := PluggableMultiColumnListMorph 
on: self "I am the model that has a list to display"
list: #list "This is how the morph gets the list from me"
selected: #listIndex "This is how the morph knows which item to highlight"
changeSelected: #listIndex: "This is how the morph informs me of a user selection"
menu: #listMenu:. "This is how the morph requests a menu for the list"
lst doubleClickSelector: #dblClick.
lst color: Color white.
	lst extent: 540@530.
	pageHolder addMorphBack: lst.

	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'hämta' 
		translated;	actionSelector: #updateList)).

"	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'Koda' 
		translated;	actionSelector: #encode)).
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'Skicka' 
		translated;	actionSelector: #send)).
	textOut := TextMorph new borderWidth: 2; extent: (textIn extent); setCharacters: '<Tryck på Koda>'.
	pageHolder addMorphBack: textOut.
	stepValue := TextMorph new borderWidth: 2; extent: (textIn extent); setCharacters: '1'.
	pageHolder addMorphBack: stepValue.
	textLog := TextMorph new borderWidth: 2; extent: (textIn extent); 
		setCharacters: '<Inget har hänt än>'.
	pageHolder addMorphBack: (self columnWith: textLog)."
	"-----------------------------------"
	r := AlignmentMorph newRow color: Color transparent; borderWidth: 0; layoutInset: 0.
	r wrapCentering: #center; cellPositioning: #topCenter; 
			hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
"	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Okay' translated;	actionSelector: #acceptSort))."
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Stäng' translated;	actionSelector: #delete)).

	r addTransparentSpacerOfSize: 8 @ 0.
"	r addMorphBack: (self wrapperFor: (aButton := UpdatingThreePhaseButtonMorph checkBox)).
	aButton
		target: self;
		actionSelector: #togglePartsBinStatus;
		arguments: #();
		getSelector: #getPartsBinStatus.
	str := StringMorph contents: 'Parts bin' translated.
	r addMorphBack: (self wrapperFor: str lock).
"
	self addMorphFront: r.

]

{ #category : #'as yet unclassified' }
BlocketMorph >> addControlsold [

	| bb r lst |
	listIndex :=0.
 	lst := PluggableListMorph 
on: self "I am the model that has a list to display"
list: #list "This is how the morph gets the list from me"
selected: #listIndex "This is how the morph knows which item to highlight"
changeSelected: #listIndex: "This is how the morph informs me of a user selection"
menu: #listMenu:. "This is how the morph requests a menu for the list"
lst doubleClickSelector: #dblClick.
lst color: Color white.
	lst extent: 440@530.
	pageHolder addMorphBack: lst.

	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'hämta' 
		translated;	actionSelector: #updateList)).

"	textIn := TextMorph new extent: 140@130.
	pageHolder addMorphBack: textIn.
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'Koda' 
		translated;	actionSelector: #encode)).
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'Skicka' 
		translated;	actionSelector: #send)).
	textOut := TextMorph new borderWidth: 2; extent: (textIn extent); setCharacters: '<Tryck på Koda>'.
	pageHolder addMorphBack: textOut.
	stepValue := TextMorph new borderWidth: 2; extent: (textIn extent); setCharacters: '1'.
	pageHolder addMorphBack: stepValue.
	textLog := TextMorph new borderWidth: 2; extent: (textIn extent); 
		setCharacters: '<Inget har hänt än>'.
	pageHolder addMorphBack: (self columnWith: textLog)."
	"-----------------------------------"
	r := AlignmentMorph newRow color: Color transparent; borderWidth: 0; layoutInset: 0.
	r wrapCentering: #center; cellPositioning: #topCenter; 
			hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
"	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Okay' translated;	actionSelector: #acceptSort))."
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Stäng' translated;	actionSelector: #delete)).

	r addTransparentSpacerOfSize: 8 @ 0.
"	r addMorphBack: (self wrapperFor: (aButton := UpdatingThreePhaseButtonMorph checkBox)).
	aButton
		target: self;
		actionSelector: #togglePartsBinStatus;
		arguments: #();
		getSelector: #getPartsBinStatus.
	str := StringMorph contents: 'Parts bin' translated.
	r addMorphBack: (self wrapperFor: str lock).
"
	self addMorphFront: r.

]

{ #category : #'as yet unclassified' }
BlocketMorph >> columnWith: aMorph [

	^AlignmentMorph newColumn
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #topCenter;
		layoutInset: 1;
		addMorph: aMorph

]

{ #category : #'as yet unclassified' }
BlocketMorph >> dblClick [
"	self inform: 'dubbelclickade'."
	(listIndex > 0) ifTrue: [ 
		BlocketItemMorph openOn: (model at: listIndex).
		self updateList
	].
	
]

{ #category : #'as yet unclassified' }
BlocketMorph >> getStuff [
	self  halt.
]

{ #category : #'as yet unclassified' }
BlocketMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	self extent: "Display extent - 100;" 400@500;
		 listDirection: #topToBottom;
		 wrapCentering: #topLeft;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 layoutInset: 3.
	pageHolder := PasteUpMorph new behaveLikeHolder extent: self extent -self borderWidth.
	pageHolder hResizing: #shrinkWrap.
	self addControls.
	self addMorphBack: pageHolder
]

{ #category : #'as yet unclassified' }
BlocketMorph >> list [
	| |
	model ifNil: [^nil] .
	^ #(#date #title #newMark #price #oldPrice) 
		collect: [ :f | 
			model collect: [:i| i perform: f ] ].

]

{ #category : #'as yet unclassified' }
BlocketMorph >> listIndex [
	^listIndex
]

{ #category : #'as yet unclassified' }
BlocketMorph >> listIndex: anInteger [
	listIndex := anInteger.
	self changed: #listIndex
]

{ #category : #'as yet unclassified' }
BlocketMorph >> on: aProject [
	project := aProject.
	self updateList
]

{ #category : #'as yet unclassified' }
BlocketMorph >> rowWith: aMorph [

	^AlignmentMorph newColumn
		color: Color transparent;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		wrapCentering: #center;
		cellPositioning: #topCenter;
		layoutInset: 1;
		addMorph: aMorph

]

{ #category : #'as yet unclassified' }
BlocketMorph >> updateList [
	title setCharacters: project name.
	model := project refresh result.
	model := model reject: [:i| i isDontShow].
	self changed: #list
]

{ #category : #'as yet unclassified' }
BlocketMorph >> wrapperFor: aMorph [

	^self columnWith: (self rowWith: aMorph)
]
