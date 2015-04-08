Extension { #name : #String }

{ #category : #'*base32' }
String >> base32Decoded [
	"Decode the receiver from base 32"

	^ Base32MimeConverter mimeDecode: self as: self class
]

{ #category : #'*base32' }
String >> base32Encoded [
	"Encode the receiver as base32"

	^ (Base32MimeConverter mimeEncode: self readStream) contents
]
