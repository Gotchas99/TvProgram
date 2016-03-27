Class {
	#name : #BlocketItemMorph,
	#superclass : #BlocketRootMorph,
	#instVars : [
		'list',
		'listIndex',
		'model',
		'robot',
		'item',
		'title',
		'thumb',
		'desc',
		'price',
		'oldPrice',
		'imageMorphs'
	],
	#category : #'CAs-Blocket-Morph'
}

{ #category : #'instance creation' }
BlocketItemMorph class >> openOn: aBlockItem [ 
	self new openOn: aBlockItem
]

{ #category : #initialization }
BlocketItemMorph >> addControls [
	| bb r  |

	title := TextMorph new extent: 140@130.
	pageHolder addMorphBack: title.
	price := TextMorph new extent: 140@130.
	pageHolder addMorphBack: price.
	oldPrice := TextMorph new extent: 140@130.
	oldPrice setCharacters: ''.
	pageHolder addMorphBack: oldPrice.

	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'refresh' ;	
		actionSelector: #refresh)).

"	thumb := ImageMorph new. 
	thumb on: #click send: #showImage to: self.
	pageHolder addMorphBack: thumb."

"	desc := TextMorph new extent: 340@130."
	desc := ScrollableField new extent: 440@330.
	pageHolder addMorphBack: desc.
	
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	pageHolder addMorphBack: (self wrapperFor: (bb label: 'visa inte' 
		;	actionSelector: #dontShow)).


	r := AlignmentMorph newRow color: Color transparent; borderWidth: 0; layoutInset: 0.
	r wrapCentering: #center; cellPositioning: #topCenter; 
			hResizing: #shrinkWrap; vResizing: #shrinkWrap; extent: 5@5.
			
	bb := SimpleButtonMorph new target: self; borderColor: Color black.
	r addMorphBack: (self wrapperFor: (bb label: 'Stäng' ;	actionSelector: #delete)).

	r addTransparentSpacerOfSize: 8 @ 0.
	self addMorphFront: r.

]

{ #category : #initialization }
BlocketItemMorph >> columnWith: aMorph [

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
BlocketItemMorph >> dontShow [
	item dontShow
]

{ #category : #initialization }
BlocketItemMorph >> initialize [
	"initialize the state of the receiver"
	super initialize.
	imageMorphs := OrderedCollection new.
	self position: 550@100; extent:  600@500.
"	self listDirection: #topToBottom;
		 wrapCentering: #topLeft;
		 hResizing: #shrinkWrap;
		 vResizing: #shrinkWrap;
		 layoutInset: 3.
	pageHolder := PasteUpMorph new behaveLikeHolder extent: self extent -self borderWidth.
	pageHolder hResizing: #shrinkWrap.
	self addControls.
	self addMorphBack: pageHolder"
]

{ #category : #initialization }
BlocketItemMorph >> openOn: aBlockItem [ 
	item := aBlockItem.
	self updateFields.
	self openInWorld
]

{ #category : #initialization }
BlocketItemMorph >> refresh [
	item refresh.
	self updateFields
]

{ #category : #initialization }
BlocketItemMorph >> rowWith: aMorph [

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
BlocketItemMorph >> showImage [
	| img |
	img := ImageMorph new. 
	img on: #click send: #delete to: img.
	img openInWorld.
]

{ #category : #'as yet unclassified' }
BlocketItemMorph >> showImage: url [
	| img src |
	src := url copyReplaceAll: 'lithumbs' with: 'images_full'.
	src := src copyReplaceAll: 'thumbs' with: 'images'.
	img := ImageMorph new. 
	img on: #click send: #delete to: img.
	img image: (HTTPSocket httpJpeg: src).
	img openInWorld.
]

{ #category : #'as yet unclassified' }
BlocketItemMorph >> showImage: aByteString with: aMouseButtonEvent with: anImageMorph [ 
	self showImage: aByteString
]

{ #category : #initialization }
BlocketItemMorph >> updateFields [
	title setCharacters: item title.
"	item thumb ifNotNilDo: [:url | thumb image: (HTTPSocket httpJpeg: url)]."
	item desc ifNotNilDo: [:txt | desc setCharacters: txt].
	item price ifNotNilDo: [:txt | price setCharacters: txt].
	item oldPrice ifNotNilDo: [:txt | oldPrice setCharacters: txt].
	self updateImages: (item images).
]

{ #category : #initialization }
BlocketItemMorph >> updateImages: imageList [
	| img |
	imageMorphs do: [:i| i delete].
	imageList isNil ifFalse: [	imageList do: [:src |
		img := ImageMorph new. 
		img on: #click send: #showImage:with:with: to: self withValue: src.
		img image: (HTTPSocket httpJpeg: src) .
		pageHolder addMorphBack: img.
		imageMorphs add: img.
	] ].
]

{ #category : #initialization }
BlocketItemMorph >> wrapperFor: aMorph [

	^self columnWith: (self rowWith: aMorph)
]
