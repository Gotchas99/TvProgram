Extension { #name : #SequenceableCollection }

{ #category : #'*ston-core' }
SequenceableCollection class >> fromSton: stonReader [
	^ self streamContents: [ :stream |
		stonReader parseListDo: [ :each |
			stream nextPut: each ] ]
]

{ #category : #'*html' }
SequenceableCollection >> joinOn: aString [

	^ String streamContents:
		[:s |
		self do: [:ea | s nextPutAll: ea asString] separatedBy: [s nextPutAll: aString]]

]

{ #category : #'*ston-core' }
SequenceableCollection >> stonOn: stonWriter [
	self class == STON listClass
		ifTrue: [ stonWriter writeList: self ]
		ifFalse: [ super stonOn: stonWriter ]
]
