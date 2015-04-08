Extension { #name : #Text }

{ #category : #'*ston-core' }
Text >> fromSton: stonReader [
	stonReader parseMapDo: [ :instVarName :value |
		self instVarNamed: instVarName put: value ]
]

{ #category : #'*ston-core' }
Text class >> fromSton: stonReader [
	^ self new
		fromSton: stonReader;
		yourself
]

{ #category : #'*ston-core' }
Text >> stonOn: stonWriter [
	stonWriter writeObject: self
]
