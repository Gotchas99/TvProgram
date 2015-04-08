Class {
	#name : #Base32MimeConverterTest,
	#superclass : #TestCase,
	#instVars : [
		'message'
	],
	#category : #'Base32-Tests'
}

{ #category : #tests }
Base32MimeConverterTest >> assertString: from equalsBase32: to [
	| encoded |
	encoded := Base32MimeConverter mimeEncode: from readStream.
	self assert: encoded contents equals: to.
	self assert: (Base32MimeConverter mimeDecodeToChars: encoded) contents equals: from
]

{ #category : #setup }
Base32MimeConverterTest >> setUp [
	message := 'Hi There!' readStream.
]

{ #category : #tests }
Base32MimeConverterTest >> testBase32Encoded [
	"self run: #testBase32Encoded"
	
	| encoded |
	encoded := (Base32MimeConverter mimeEncode: message) contents.
	self assert: encoded equals: 'Hi There!' base32Encoded.
	
]

{ #category : #tests }
Base32MimeConverterTest >> testMimeEncodeDecode [
	"self run: #testMimeEncodeDecode"
	
	| encoded |
	encoded := Base32MimeConverter mimeEncode: message.
	self assert: encoded contents equals: 'JBUSAVDIMVZGKII='.
      self assert: (Base32MimeConverter mimeDecodeToChars: encoded) contents equals: message contents.

	"Encoding should proceed from the current stream position."
	message reset.
	message skip: 2.
	encoded := Base32MimeConverter mimeEncode: message.
	self assert: encoded contents equals: 'EBKGQZLSMUQQ===='
]

{ #category : #tests }
Base32MimeConverterTest >> testOnByteArray [
	"self run: #testOnByteArray"
	
	self assert: 'Hi There!' base32Encoded equals: 'Hi There!' asByteArray base32Encoded
]

{ #category : #tests }
Base32MimeConverterTest >> testRfc4648Vectors [
	self
		assertString: '' equalsBase32: '';
		assertString: 'f' equalsBase32: 'MY======';
		assertString: 'fo' equalsBase32: 'MZXQ====';
		assertString: 'foo' equalsBase32: 'MZXW6===';
		assertString: 'foob' equalsBase32: 'MZXW6YQ=';
		assertString: 'fooba' equalsBase32: 'MZXW6YTB';
		assertString: 'foobar' equalsBase32: 'MZXW6YTBOI======'
]
