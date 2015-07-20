Extension { #name : #Character }

{ #category : #'*CAs-Pirate' }
Character >> widthToDisplayInList: aList [

	^ aList font widthOfStringOrText: self asString
]
