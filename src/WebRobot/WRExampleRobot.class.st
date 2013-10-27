"
This is a class showing example code. The code does not work! Just use it as inspiration.
"
Class {
	#name : #WRExampleRobot,
	#superclass : #WRHttpRobot,
	#instVars : [
		'loggedIn'
	],
	#category : #WebRobot
}

{ #category : #'initialize-release' }
WRExampleRobot >> initialize [
	loggedIn := false.

]

{ #category : #testing }
WRExampleRobot >> isLoggedIn [
	^loggedIn
]

{ #category : #actions }
WRExampleRobot >> login [
	"Perform a form POST for logging in."

	| form inputs fields anchor hiddens |
	"Get login page"
	self newGet: 'http://www.somewhere.com/login.html'.
	self checkOk.

	"Do some silly check if we get redirected somewhere"
	(request url urlString includesSubString: 'WeAreClosed') ifTrue: [self error: 'Closed'].

	"Parse page"
	self parseBody.

	"Find a specific way to login by finding an anchor and fetching that page"
	anchor := dom anchors detect: [:anc | anc href includesSubString: 'authmethod=pin']
				ifNone: [self error: 'Unexpected HTML'].

	"Finally fetch the right login page"
	self newGetWithState: anchor href; checkOk.
	self parseBody.

	"Find form"
	form := dom tagWithId: 'loginForm'.
	
	"Pick out fields"
	inputs := form tagsOfClass: HtmlINPUTNode.
	
	"Find hidden ones"
	hiddens := inputs select: [:in | (in attributes at: 'type' ifAbsent:[false]) = 'hidden'].

	"Send a post to actually login"
	request openPostTo: form action.
	fields := Dictionary new.
	"Just send values that they contain"
	hiddens do: [:hidden | fields at: hidden name put: (hidden attributes at: 'value')].

	"Fill out fields"
	fields at: inputs first name put: 'myusername';
		at: inputs second name put: 'somepassword'.

	"Build request"
	request addHeader: 'Content-Type' value: 'application/x-www-form-urlencoded'.
	request entityString: (self argString: fields).

	"Fire away!"
	request send; waitOnReady.
	self checkOk.
	self parseBody.
		
	(request responseBody includesSubString: 'You did something wrong') ifTrue: [self error: 'Something went wrong'].

	loggedIn := true
]

{ #category : #viewing }
WRExampleRobot >> responseBody [
	^request responseBody
]

{ #category : #viewing }
WRExampleRobot >> viewResponse [
	"For debugging"

	(StringHolder new contents: request responseBody)
		openLabel: request url urlString
]
