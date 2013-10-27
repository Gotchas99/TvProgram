Extension { #name : #HttpUrl }

{ #category : #'*html' }
HttpUrl >> retrieveContentsArgs: args [
	^self retrieveContentsArgs: args accept: (MIMEDocument guessTypeFromName: self)
]
