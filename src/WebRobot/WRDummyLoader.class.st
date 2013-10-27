"
This is a dummy of HtmlCache used by HtmlValidator. We just don't queue URLs for loading at all. Useful when parsing HTML using HtmlValidator in order to do screen scraping etc - when we aren't interested in downloading referenced documents.
"
Class {
	#name : #WRDummyLoader,
	#superclass : #Object,
	#instVars : [
		'urlToDocument',
		'url'
	],
	#category : #WebRobot
}

{ #category : #accessing }
WRDummyLoader >> canonicalize: aStringOrUrl [

	| href |

	href := aStringOrUrl asString.
	^((href beginsWith: 'http:') or: [(href beginsWith: 'https:') or:[href beginsWith: 'ftp:']]) 
	ifFalse:
	[
		(Url combine: url asString withRelative: href).
	]
	ifTrue: [href].
]

{ #category : #accessing }
WRDummyLoader >> contentsForUrl: anUrl [

	self halt.
	^(self documentForUrl: anUrl) contents
]

{ #category : #accessing }
WRDummyLoader >> documentForUrl: anUrl [

	^(self queueUrl: anUrl) 
]

{ #category : #'initialize-release' }
WRDummyLoader >> initialize [

	super initialize.
	urlToDocument := Dictionary new.
]

{ #category : #accessing }
WRDummyLoader >> queueUrl: anUrl [

"	| absoluteUrl |
	absoluteUrl := self canonicalize: anUrl.
	^urlToDocument at: absoluteUrl ifAbsentPut: 
	[
		absoluteUrl asUrl retrieveContents
	]"	
]

{ #category : #accessing }
WRDummyLoader >> url [
	"Answer the value of url"

	^ url
]

{ #category : #accessing }
WRDummyLoader >> url: anObject [
	"Set the value of url"

	url := anObject
]
