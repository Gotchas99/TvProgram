Extension { #name : #Object }

{ #category : #'*ston-core' }
Object class >> fromSton: stonReader [
	"Create a new instance and delegate decoding to instance side.
	Override only when new instance should be created directly (see implementors). "
	
	^ self new
		fromSton: stonReader;
		yourself
]

{ #category : #'*ston-core' }
Object >> fromSton: stonReader [
	"Decode non-variable classes from a map of their instance variables and values.
	Override to customize and add a matching #toSton: (see implementors)."
	
	self class isVariable 
		ifTrue: [
			self subclassResponsibility ]
		ifFalse: [
			stonReader parseMapDo: [ :instVarName :value |
				self instVarNamed: instVarName put: value ] ]

]

{ #category : #'*ston-core' }
Object >> isStonReference [
	^ false
]

{ #category : #'*ston-core' }
Object >> stonContainSubObjects [
	"Return true if I contain subObjects that should be processed, false otherwise.
	Overwrite when necessary. See also #stonProcessSubObjects:"
	
	^ true
]

{ #category : #'*ston-core' }
Object >> stonOn: stonWriter [
	"Encode non-variable classes with a map of their instance variable and values.
	Override to customize and add a matching #fromSton: (see implementors)."

	self class isVariable 
		ifTrue: [
			self subclassResponsibility ]
		ifFalse: [
			stonWriter writeObject: self ]

]

{ #category : #'*ston-core' }
Object >> stonProcessSubObjects: block [
	"Execute block to (potentially) change each of my subObjects.
	In general, all instance and indexable variables are processed.
	Overwrite when necessary. Not used when #stonContainSubObjects returns false."
	
	1 to: self class instSize do: [ :each |
		self instVarAt: each put: (block value: (self instVarAt: each)) ].
	(self class isVariable and: [ self class isBytes not ])
		ifTrue: [
			1 to: self basicSize do: [ :each |
				self basicAt: each put: (block value: (self basicAt: each)) ] ]
]

{ #category : #'*ston-core' }
Object >> stonShouldWriteNilInstVars [
	"Return true if my instance variables that are nil should be written out, 
	false otherwise. Overwrite when necessary. By default, return false."
	
	^ false
]
