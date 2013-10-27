Class {
	#name : #BlockItem,
	#superclass : #Object,
	#instVars : [
		'id',
		'props',
		'thumb',
		'phone',
		'mail',
		'notes',
		'html',
		'url'
	],
	#category : #'CAs-Blocket'
}

{ #category : #accessing }
BlockItem >> <= aBlockItem [
	(self dateTime class = DateAndTime)
		ifTrue:[(aBlockItem dateTime class = DateAndTime)
			ifTrue: [^(self dateTime) <= (aBlockItem dateTime)]
			ifFalse: [^true]]
		ifFalse:[(aBlockItem dateTime class = DateAndTime)
			ifTrue: [^true]
			ifFalse:[^(self dateTime) <= (aBlockItem dateTime)]].

]

{ #category : #accessing }
BlockItem >> <= aBlockItem [
	(self dateTime class = DateAndTime)
		ifTrue:[(aBlockItem dateTime class = DateAndTime)
			ifTrue: [^(self dateTime) <= (aBlockItem dateTime)]
			ifFalse: [^true]]
		ifFalse:[(aBlockItem dateTime class = DateAndTime)
			ifTrue: [^true]
			ifFalse:[^(self dateTime) <= (aBlockItem dateTime)]].

]

{ #category : #accessing }
BlockItem >> = aBlockItem [
	^(self id) = (aBlockItem id)
]

{ #category : #accessing }
BlockItem >> = aBlockItem [
	^(self id) = (aBlockItem id)
]

{ #category : #accessing }
BlockItem >> area: aString [
	self at: #area put: aString
]

{ #category : #accessing }
BlockItem >> area: aString [
	self at: #area put: aString
]

{ #category : #'access primitives' }
BlockItem >> at: key [
	^props at: key ifAbsent: [^nil]
]

{ #category : #'access primitives' }
BlockItem >> at: key [
	^props at: key ifAbsent: [^nil]
]

{ #category : #'access primitives' }
BlockItem >> at: key ifAbsent: aBlock [ 
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^props at: key ifAbsent: aBlock
	
]

{ #category : #'access primitives' }
BlockItem >> at: key ifAbsent: aBlock [ 
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^props at: key ifAbsent: aBlock
	
]

{ #category : #'access primitives' }
BlockItem >> at: key put: anObject [
	props at: key put: anObject.
	^anObject
]

{ #category : #'access primitives' }
BlockItem >> at: key put: anObject [
	props at: key put: anObject.
	^anObject
]

{ #category : #accessing }
BlockItem >> category: aString [
	self at: #category put: aString
]

{ #category : #accessing }
BlockItem >> category: aString [
	self at: #category put: aString
]

{ #category : #accessing }
BlockItem >> date [
	(self at: #date) isNil ifTrue: [self refresh].
	^self at: #date
]

{ #category : #accessing }
BlockItem >> date [
	(self at: #date) isNil ifTrue: [self refresh].
	^self at: #date
]

{ #category : #accessing }
BlockItem >> date: aString [
	^self at: #date put: aString
]

{ #category : #accessing }
BlockItem >> date: aString [
	^self at: #date put: aString
]

{ #category : #accessing }
BlockItem >> dateTime [
	(self date class = Date)
		ifTrue: [^DateAndTime date: (self at: #date) time: (self at: #time) asTime ]
		ifFalse: [^(self at: #date) , (self at: #time)].
	
]

{ #category : #accessing }
BlockItem >> dateTime [
	(self date class = Date)
		ifTrue: [^DateAndTime date: (self at: #date) time: (self at: #time) asTime ]
		ifFalse: [^(self at: #date) , (self at: #time)].
	
]

{ #category : #accessing }
BlockItem >> dateTimeString [
	^(self dateTime printString)
]

{ #category : #accessing }
BlockItem >> dateTimeString [
	^(self dateTime printString)
]

{ #category : #accessing }
BlockItem >> desc [
	(self at: #desc) isNil ifTrue: [self refresh].
	self at: #viewed put: DateAndTime now.
	^self at: #desc
]

{ #category : #accessing }
BlockItem >> desc [
	(self at: #desc) isNil ifTrue: [self refresh].
	self at: #viewed put: DateAndTime now.
	^self at: #desc
]

{ #category : #accessing }
BlockItem >> desc: aString [
	^self at: #desc put: aString
]

{ #category : #accessing }
BlockItem >> desc: aString [
	^self at: #desc put: aString
]

{ #category : #testing }
BlockItem >> dontShow [
	^(self at: #dontshow put: true) 
]

{ #category : #testing }
BlockItem >> dontShow [
	^(self at: #dontshow put: true) 
]

{ #category : #accessing }
BlockItem >> html: aString [
	html := aString
]

{ #category : #accessing }
BlockItem >> html: aString [
	html := aString
]

{ #category : #accessing }
BlockItem >> id [
	^id
]

{ #category : #accessing }
BlockItem >> id [
	^id
]

{ #category : #accessing }
BlockItem >> id: aString [
	id := aString asSymbol
]

{ #category : #accessing }
BlockItem >> id: aString [
	id := aString asSymbol
]

{ #category : #accessing }
BlockItem >> images [
	(self at: #images) isNil ifTrue: [self refresh].
	^self at: #images
]

{ #category : #accessing }
BlockItem >> images [
	(self at: #images) isNil ifTrue: [self refresh].
	^self at: #images
]

{ #category : #'initialize-release' }
BlockItem >> initialize [
	props := Dictionary new.
]

{ #category : #'initialize-release' }
BlockItem >> initialize [
	props := Dictionary new.
]

{ #category : #testing }
BlockItem >> isDontShow [
	^(self at: #dontshow ifAbsent: [ ^false] ) 
]

{ #category : #testing }
BlockItem >> isDontShow [
	^(self at: #dontshow ifAbsent: [ ^false] ) 
]

{ #category : #testing }
BlockItem >> isViewed [
	^(self at: #viewed) isNil not
]

{ #category : #testing }
BlockItem >> isViewed [
	^(self at: #viewed) isNil not
]

{ #category : #accessing }
BlockItem >> listColumns [
	^Array with: ( self date) with: (self title)
]

{ #category : #accessing }
BlockItem >> listColumns [
	^Array with: ( self date) with: (self title)
]

{ #category : #testing }
BlockItem >> newMark [
	(self at: #viewed) isNil ifTrue:[^'Ny'] ifFalse:[ ^'' ]
]

{ #category : #testing }
BlockItem >> newMark [
	(self at: #viewed) isNil ifTrue:[^'Ny'] ifFalse:[ ^'' ]
]

{ #category : #accessing }
BlockItem >> oldPrice [
	((self at: #oldPrice) isNil  and: [self at: #priceCut]) ifTrue: [self refresh].
	(self at: #oldPrice) ifNil: [^''].
	^self at: #oldPrice
]

{ #category : #accessing }
BlockItem >> oldPrice [
	((self at: #oldPrice) isNil  and: [self at: #priceCut]) ifTrue: [self refresh].
	(self at: #oldPrice) ifNil: [^''].
	^self at: #oldPrice
]

{ #category : #accessing }
BlockItem >> oldPrice: aString [
	^self at: #oldPrice put: aString
]

{ #category : #accessing }
BlockItem >> oldPrice: aString [
	^self at: #oldPrice put: aString
]

{ #category : #accessing }
BlockItem >> price [
	^self at: #price
]

{ #category : #accessing }
BlockItem >> price [
	^self at: #price
]

{ #category : #accessing }
BlockItem >> price: aString [
	self at: #price put: aString
]

{ #category : #accessing }
BlockItem >> price: aString [
	self at: #price put: aString
]

{ #category : #accessing }
BlockItem >> priceCut [
	^ (self at: #priceCut) 
		or: [(self at: #oldPrice) notNil]
]

{ #category : #accessing }
BlockItem >> priceCut [
	^ (self at: #priceCut) 
		or: [(self at: #oldPrice) notNil]
]

{ #category : #accessing }
BlockItem >> priceCut: aString [
	self at: #priceCut put: aString
]

{ #category : #accessing }
BlockItem >> priceCut: aString [
	self at: #priceCut put: aString
]

{ #category : #printing }
BlockItem >> printString [
	^self title contractTo: 45
]

{ #category : #printing }
BlockItem >> printString [
	^self title contractTo: 45
]

{ #category : #'category name' }
BlockItem >> refresh [
	| newProps images |
	newProps := BlocketRobot new getItemFromUrl: self url.
	newProps isNil ifTrue: [ ^nil ].
	newProps keysAndValuesDo: [:key :val| self at: key put: val].
	images := props at: #images. 
	images isEmpty ifTrue: [images add: (self thumb)].
	self at: #LastFound: put: DateAndTime now
]

{ #category : #'category name' }
BlockItem >> refresh [
	| newProps images |
	newProps := BlocketRobot new getItemFromUrl: self url.
	newProps isNil ifTrue: [ ^nil ].
	newProps keysAndValuesDo: [:key :val| self at: key put: val].
	images := props at: #images. 
	images isEmpty ifTrue: [images add: (self thumb)].
	self at: #LastFound: put: DateAndTime now
]

{ #category : #accessing }
BlockItem >> thumb [
	thumb isNil ifTrue: [^nil].
	^thumb attributes at: #src
	
]

{ #category : #accessing }
BlockItem >> thumb [
	thumb isNil ifTrue: [^nil].
	^thumb attributes at: #src
	
]

{ #category : #accessing }
BlockItem >> thumb: anIMG [
	thumb := anIMG
	
"self attributes at: 'src' "
]

{ #category : #accessing }
BlockItem >> thumb: anIMG [
	thumb := anIMG
	
"self attributes at: 'src' "
]

{ #category : #accessing }
BlockItem >> time: aString [
	^self at: #time put: aString asTime
]

{ #category : #accessing }
BlockItem >> time: aString [
	^self at: #time put: aString asTime
]

{ #category : #accessing }
BlockItem >> title [
	^self at: #title
]

{ #category : #accessing }
BlockItem >> title [
	^self at: #title
]

{ #category : #accessing }
BlockItem >> title: aString [
	props at: #title put: aString
]

{ #category : #accessing }
BlockItem >> title: aString [
	props at: #title put: aString
]

{ #category : #accessing }
BlockItem >> url [
	^url
]

{ #category : #accessing }
BlockItem >> url [
	^url
]

{ #category : #accessing }
BlockItem >> url: aString [
	url := aString
]

{ #category : #accessing }
BlockItem >> url: aString [
	url := aString
]
