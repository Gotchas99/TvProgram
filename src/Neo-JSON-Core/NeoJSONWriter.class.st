"
I am NeoJSONWriter.
I am a NeoJSONMapper.
I write a JSON representation of Smalltalk objects to a textual stream.

Objects implementing #neoJsonOn: can be encoded.
A number of primitive types, like Strings, Numbers, Booleans and UndefinedObject are treated specially.
Collection are encoded as lists, except for Dictionaries that are encoded as maps.

All other objects need a mapping to help in doing the encoding.

Here are some examples:

	NeoJSONWriter toString: #(1 2 3).
	NeoJSONWriter toString: { Float pi. true. false. 'string' }.
	NeoJSONWriter toStringPretty: (Dictionary new at: #x put: 1; at: #y put: 2; yourself).
	
	String streamContents: [ :stream |
		(NeoJSONWriter on: stream)
			prettyPrint: true;
			mapInstVarsFor: Point;
			nextPut: (Array with: 1@3 with: -1@3) ].
	
"
Class {
	#name : #NeoJSONWriter,
	#superclass : #NeoJSONMapper,
	#instVars : [
		'writeStream',
		'prettyPrint',
		'level',
		'newLine',
		'asciiOnly'
	],
	#category : #'Neo-JSON-Core'
}

{ #category : #'instance creation' }
NeoJSONWriter class >> on: writeStream [
	"Initialize on writeStream, which should be a character stream that 
	implements #nextPut:, #nextPutAll:, #space and (optionally) #close."

	^ self new
		on: writeStream;
		yourself
]

{ #category : #convenience }
NeoJSONWriter class >> toString: object [
	^ String streamContents: [ :stream |
			(self on: stream) nextPut: object ]
]

{ #category : #convenience }
NeoJSONWriter class >> toStringPretty: object [
	^ String streamContents: [ :stream |
			(self on: stream)
				prettyPrint: true; 
				nextPut: object ]
]

{ #category : #'initialize-release' }
NeoJSONWriter >> asciiOnly: boolean [
	asciiOnly := boolean
]

{ #category : #'initialize-release' }
NeoJSONWriter >> close [
	writeStream ifNotNil: [
		writeStream close.
		writeStream := nil ]
]

{ #category : #private }
NeoJSONWriter >> doesCodePointNeedEscaping: code [
	code < 32 ifTrue: [ ^ true ].
	( code = 34 or: [ code = 92 ]) ifTrue: [ ^ true ].
	^ asciiOnly and: [ code > 126 ]	
]

{ #category : #private }
NeoJSONWriter >> encodeChar: char [
	| code |
	code := char codePoint.
	(self doesCodePointNeedEscaping: code)
		ifTrue: [ self escapeChar: code ]
		ifFalse: [ writeStream nextPut: char ]
]

{ #category : #private }
NeoJSONWriter >> encodeKey: key value: value [
	self nextPut: key.
	self prettyPrintSpace.
	writeStream nextPut: $:.
	self prettyPrintSpace.
	self nextPut: value
]

{ #category : #private }
NeoJSONWriter >> encodeKey: key value: value as: valueSchema [
	self nextPut: key.
	self prettyPrintSpace.
	writeStream nextPut: $:.
	self prettyPrintSpace.
	self nextPut: value as: valueSchema
]

{ #category : #private }
NeoJSONWriter >> escapeChar: code [
	code = 34
		ifTrue: [ ^ writeStream nextPutAll: '\"' ].
	code = 92
		ifTrue: [ ^ writeStream nextPutAll: '\\' ].
	code = 47
		ifTrue: [ ^ writeStream nextPutAll: '\/' ].
	code = 8
		ifTrue: [ ^ writeStream nextPutAll: '\b' ].
	code = 12
		ifTrue: [ ^ writeStream nextPutAll: '\f' ].		
	code = 10
		ifTrue: [ ^ writeStream nextPutAll: '\n' ].		
	code = 13
		ifTrue: [ ^ writeStream nextPutAll: '\r' ].		
	code = 9
		ifTrue: [ ^ writeStream nextPutAll: '\t' ].		
	writeStream nextPutAll: '\u'.
	code printOn: writeStream base: 16 nDigits: 4
]

{ #category : #private }
NeoJSONWriter >> indentedDo: block [
	level := level + 1.
	block value.
	level := level - 1
]

{ #category : #'initialize-release' }
NeoJSONWriter >> initialize [
	super initialize.
	self newLine: String cr.
	self prettyPrint: false.
	self asciiOnly: false.
	level := 0
]

{ #category : #private }
NeoJSONWriter >> listElementSeparator [
	writeStream nextPut: $,.
	self newlineIndent

]

{ #category : #private }
NeoJSONWriter >> mapElementSeparator [
	writeStream nextPut: $,.
	self newlineIndent

]

{ #category : #'initialize-release' }
NeoJSONWriter >> newLine: string [
	newLine := string
]

{ #category : #accessing }
NeoJSONWriter >> newline [
	"Write a newline on the stream that I wrap.
	What gets written depends on the configuration, see #newLine:"
	
	writeStream nextPutAll: newLine
]

{ #category : #private }
NeoJSONWriter >> newlineIndent [
	prettyPrint
		ifTrue: [ 
			self newline.
			level timesRepeat: [ writeStream nextPut: Character tab ] ]
]

{ #category : #accessing }
NeoJSONWriter >> nextPut: anObject [
	anObject neoJsonOn: self
]

{ #category : #accessing }
NeoJSONWriter >> nextPut: anObject as: schema [
	"Secondary interface to write JSON.
	Write objects according to schema."
	
	| mapping |
	schema ifNil: [ ^ self nextPut: anObject ].
	mapping := self mappingFor: schema.
	^ mapping writeObject: anObject on: self
]

{ #category : #'initialize-release' }
NeoJSONWriter >> on: aWriteStream [
	"Initialize on aWriteStream, which should be a character stream that 
	implements #nextPut:, #nextPutAll:, #space and (optionally) #close."

	writeStream := aWriteStream

]

{ #category : #'initialize-release' }
NeoJSONWriter >> prettyPrint: boolean [
	prettyPrint := boolean
]

{ #category : #private }
NeoJSONWriter >> prettyPrintSpace [
	prettyPrint
		ifTrue: [ writeStream nextPut: Character space ]
]

{ #category : #writing }
NeoJSONWriter >> writeBoolean: boolean [
	boolean printOn: writeStream
]

{ #category : #writing }
NeoJSONWriter >> writeFloat: float [
	float printOn: writeStream
]

{ #category : #writing }
NeoJSONWriter >> writeInteger: integer [
	integer printOn: writeStream
	
]

{ #category : #writing }
NeoJSONWriter >> writeList: collection [
	self writeListStreamingDo: [ :jsonListWriter |
		collection do: [ :each |
			jsonListWriter writeElement: each ] ]
]

{ #category : #writing }
NeoJSONWriter >> writeListStreamingDo: block [
	writeStream nextPut: $[.
	self writeStreamingDo: block.
	writeStream nextPut: $]
]

{ #category : #writing }
NeoJSONWriter >> writeMap: keyValueCollection [
	self writeMapStreamingDo: [ :jsonMapWriter |
		keyValueCollection keysAndValuesDo: [ :key :value |
			jsonMapWriter writeKey: key value: value ] ]
]

{ #category : #writing }
NeoJSONWriter >> writeMapStreamingDo: block [
	writeStream nextPut: ${.
	self writeStreamingDo: block.
	writeStream nextPut: $}
]

{ #category : #writing }
NeoJSONWriter >> writeNull [
	writeStream nextPutAll: 'null'
]

{ #category : #writing }
NeoJSONWriter >> writeObject: anObject [
	| mapping |
	mapping := self mappingFor: anObject class.
	mapping
		writeObject: anObject
		on: self
]

{ #category : #writing }
NeoJSONWriter >> writeStreamingDo: block [
	| mapWriter |
	mapWriter := NeoJSONStreamingWriter on: self.
	self indentedDo: [
		block value: mapWriter ].
	mapWriter wasUsed
		ifTrue: [ self newlineIndent ]
		ifFalse: [ self prettyPrintSpace ]
]

{ #category : #writing }
NeoJSONWriter >> writeString: string [
	writeStream nextPut: $".
	string do: [ :each |
		self encodeChar: each ].
	writeStream nextPut: $"
]
