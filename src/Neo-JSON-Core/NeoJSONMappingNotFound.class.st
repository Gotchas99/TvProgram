"
I am NeoJSONMappingNotFound.
I am a NotFound exception.

I am signalled when no mapping is found for a schema.
"
Class {
	#name : #NeoJSONMappingNotFound,
	#superclass : #NotFound,
	#category : #'Neo-JSON-Core'
}

{ #category : #printing }
NeoJSONMappingNotFound >> standardMessageText [
	^ String streamContents: [ :stream |
		stream << 'No mapping found for '.
		stream print: self object.
		stream << ' in '.
		stream print: self collection class ]
]
