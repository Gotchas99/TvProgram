"
A base class for robot surfing. We hold the current request in an instance variable called 'request' and the DOM (instance variable 'dom') for the last response can be built by sending #parseBody to self.
"
Class {
	#name : #WRHttpRobot,
	#superclass : #Object,
	#instVars : [
		'request',
		'dom',
		'state'
	],
	#category : #WebRobot
}

{ #category : #'as yet unclassified' }
WRHttpRobot >> argString: aDict [
	"Loosely copied from HTTPSocket etc, this is implemented in lots of places...
	We do not include any leading '?'."

	| first |
	^String streamContents: [:stream |
		aDict keysAndValuesDo: [:key :val |
			first ifNil: [ first := false ] ifNotNil: [ stream nextPut: $& ].
			stream nextPutAll: key encodeForHTTP, '=', val encodeForHTTP]]
]

{ #category : #'as yet unclassified' }
WRHttpRobot >> checkOk [

	request isSuccess ifFalse: [WRRobotError new signal: 'Not OK: ', request response statusLine reason ]
]

{ #category : #'as yet unclassified' }
WRHttpRobot >> get: anURL [
	"Create a new request based on the previous and go to URL,"

	request openGetTo: anURL.
	request send.
	request waitOnReady.
	
]

{ #category : #'as yet unclassified' }
WRHttpRobot >> newGet: anURL [
	self newRequest.
	request url: anURL.
	request get
]

{ #category : #'as yet unclassified' }
WRHttpRobot >> newGetWithState: anURL [
	"Create a new request based on the previous and go to URL,"

	self newRequestWithState.
	request openGetTo: anURL.
	request send.
	request waitOnReady.
	"Transcript show: request headerReportString;cr."
]

{ #category : #'as yet unclassified' }
WRHttpRobot >> newRequest [
	request := ZnClient new
		timeout: 10;
		numberOfRetries: 3;
		retryDelay: 2.
	request beOneShot.
	^ request
]

{ #category : #'as yet unclassified' }
WRHttpRobot >> newRequestWithState [

	| |
"	u := request url.
	request := SptHTTPRequest new.
	request setUrl: u.
	request state: state.
	^request".
	self halt.
]

{ #category : #'as yet unclassified' }
WRHttpRobot >> parseBody [
	dom := (HtmlValidator on: request response contents)
		loader: WRDummyLoader new;
		dom
]
