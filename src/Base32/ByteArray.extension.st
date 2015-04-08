Extension { #name : #ByteArray }

{ #category : #'*base32' }
ByteArray >> base32Encoded [
	"Encode the receiver as base 32"

	^ (Base32MimeConverter mimeEncode: self readStream) contents
]
