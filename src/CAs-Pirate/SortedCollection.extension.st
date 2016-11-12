Extension { #name : #SortedCollection }

{ #category : #'*cas-pirate' }
SortedCollection class >> fromSton: stonReader [
	| collection |
	collection := self new.
	stonReader parseListDo: [ :each |
		collection addLast: each ].
	^ collection
]
