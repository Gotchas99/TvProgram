Extension { #name : #TimeStamp }

{ #category : #'*ston-core' }
TimeStamp classSide >> fromSton: stonReader [
	"We use a representation from DateAndTime"
	
	^ (super fromSton: stonReader) asTimeStamp
]
