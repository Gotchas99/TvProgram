Extension { #name : #SmallDictionary }

{ #category : #'*neo-json-core' }
SmallDictionary >> neoJsonOn: neoJSONWriter [
	neoJSONWriter writeMap: self
]
