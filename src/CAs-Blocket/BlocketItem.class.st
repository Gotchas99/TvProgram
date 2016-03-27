Class {
	#name : #BlocketItem,
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
BlocketItem >> <= aBlockItem [
	(self dateTime class = DateAndTime)
		ifTrue:[(aBlockItem dateTime class = DateAndTime)
			ifTrue: [^(self dateTime) <= (aBlockItem dateTime)]
			ifFalse: [^true]]
		ifFalse:[(aBlockItem dateTime class = DateAndTime)
			ifTrue: [^true]
			ifFalse:[^(self dateTime) <= (aBlockItem dateTime)]].

]

{ #category : #accessing }
BlocketItem >> = aBlockItem [
	^(self id) = (aBlockItem id)
]

{ #category : #accessing }
BlocketItem >> area: aString [
	self at: #area put: aString
]

{ #category : #'access primitives' }
BlocketItem >> at: key [
	^self at: key ifAbsent: [^nil]
]

{ #category : #'access primitives' }
BlocketItem >> at: key ifAbsent: aBlock [ 
	"Answer the value associated with the key or, if key isn't found,
	answer the result of evaluating aBlock."

	^props at: key ifAbsent: aBlock
	
]

{ #category : #'access primitives' }
BlocketItem >> at: key put: anObject [
	props at: key put: anObject.
	^anObject
]

{ #category : #accessing }
BlocketItem >> category: aString [
	self at: #category put: aString
]

{ #category : #accessing }
BlocketItem >> dateTime [
	^self at: #dateTime
	
]

{ #category : #accessing }
BlocketItem >> dateTime: aDateAndTime [
	^self at: #dateTime put: aDateAndTime
	
]

{ #category : #accessing }
BlocketItem >> dateTimeString [
	| s  |
	s := String new writeStream.
	self dateTime printYMDOn: s.
	s << ' '.
	self dateTime printHMSOn: s.
	^ s contents
]

{ #category : #accessing }
BlocketItem >> desc [
	(self at: #desc) isNil ifTrue: [self refresh].
	self at: #viewed put: DateAndTime now.
	^self at: #desc ifAbsent: [ '<hittar ingen text>' ]
]

{ #category : #accessing }
BlocketItem >> desc: aString [
	^self at: #desc put: aString
]

{ #category : #actions }
BlocketItem >> dontShow [
	self starred: false.
	^ self at: #dontshow put: true
]

{ #category : #actions }
BlocketItem >> gone [
	^(self at: #gone put: true) 
]

{ #category : #testing }
BlocketItem >> goneMark [
	(self at: #gone) isNil ifTrue:[^''] ifFalse:[ ^'Gone' ]
]

{ #category : #accessing }
BlocketItem >> hash [
	^id hash
]

{ #category : #accessing }
BlocketItem >> html: aString [
	html := aString
]

{ #category : #accessing }
BlocketItem >> id [
	^id
]

{ #category : #accessing }
BlocketItem >> id: aString [
	id := aString asSymbol
]

{ #category : #accessing }
BlocketItem >> images [
	(self at: #images) isNil
		ifTrue: [ self refresh ].
	^ self at: #images
]

{ #category : #'initialize-release' }
BlocketItem >> initialize [
	props := Dictionary new.
]

{ #category : #testing }
BlocketItem >> isDontShow [
	^(self at: #dontshow ifAbsent: [ ^false] ) 
]

{ #category : #testing }
BlocketItem >> isGone [
	^(self at: #gone) isNil not
]

{ #category : #testing }
BlocketItem >> isStarred [
	^ (self at: #star) ifNotNil: [ :x | x ] ifNil: [ false ]
]

{ #category : #testing }
BlocketItem >> isViewed [
	^(self at: #viewed) isNil not
]

{ #category : #accessing }
BlocketItem >> listColumns [
	^ Array with: self date with: self title
]

{ #category : #testing }
BlocketItem >> newMark [
	(self at: #viewed) isNil ifTrue:[^'Ny'] ifFalse:[ ^'' ]
]

{ #category : #accessing }
BlocketItem >> oldPrice [
	((self at: #oldPrice) isNil  and: [self at: #priceCut]) ifTrue: [self refresh].
	(self at: #oldPrice) ifNil: [^''].
	^self at: #oldPrice
]

{ #category : #accessing }
BlocketItem >> oldPrice: aString [
	^self at: #oldPrice put: aString
]

{ #category : #accessing }
BlocketItem >> price [
	^self at: #price
]

{ #category : #accessing }
BlocketItem >> price: aString [
	self at: #price put: aString
]

{ #category : #accessing }
BlocketItem >> priceCut [
	^ (self at: #priceCut) 
		or: [(self at: #oldPrice) notNil]
]

{ #category : #accessing }
BlocketItem >> priceCut: aString [
	self at: #priceCut put: aString
]

{ #category : #printing }
BlocketItem >> printOn: aStream [
	aStream
		nextPutAll: 'BlocketItem (';
		nextPutAll: (self title contractTo: 45);
		nextPutAll: ')'
]

{ #category : #printing }
BlocketItem >> printString [
	^self title contractTo: 45
]

{ #category : #actions }
BlocketItem >> refresh [
	| newProps images |
	newProps := BlocketRobot new getItemFromUrl: self url.
	newProps isNil
		ifTrue: [ ^ nil ].
	newProps = #notFound
		ifTrue: [ ^ nil ].
	newProps keysAndValuesDo: [ :key :val | self at: key put: val ].
	images := props at: #images.
	images isEmpty
		ifTrue: [ images add: self thumb ].
	self at: #LastFound: put: DateAndTime now
]

{ #category : #actions }
BlocketItem >> starred [
	^ self at: #star put: self isStarred not
]

{ #category : #actions }
BlocketItem >> starred: aBoolean [
	^ self at: #star put: aBoolean 
]

{ #category : #accessing }
BlocketItem >> thumb [
	thumb isNil ifTrue: [^nil].
	^thumb attributes at: #src
	
]

{ #category : #accessing }
BlocketItem >> thumb: anIMG [
	thumb := anIMG
	
"self attributes at: 'src' "
]

{ #category : #accessing }
BlocketItem >> title [
	^self at: #title ifAbsent:['<okänt item>']
]

{ #category : #accessing }
BlocketItem >> title: aString [
	props at: #title put: aString
]

{ #category : #accessing }
BlocketItem >> url [
	^url
]

{ #category : #accessing }
BlocketItem >> url: aString [
	url := aString
]

{ #category : #actions }
BlocketItem >> viewed [
	^(self at: #viewed put: true) 
]
