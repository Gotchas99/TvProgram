Extension { #name : #Association }

{ #category : #'*ston-core' }
Association >> stonOn: stonWriter [
	stonWriter writeAssociation: self
]
