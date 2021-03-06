Class {
	#name : #PirateRobot,
	#superclass : #WRHttpRobot,
	#category : #'CAs-Pirate-Services'
}

{ #category : #'test code' }
PirateRobot >> foundEpisodes [
	| episodes found |
	episodes := #(
		'Chuck%20S05E09'
		'Chuck%20S05E19' 
		 'Big Bang%20S05E11'
		 'Big Bang%20S05E22').
	found := episodes select: [:e| self foundShow: e].
	^found
]

{ #category : #'test code' }
PirateRobot >> foundShow: aShow [ 
	| found |
	"Transcript show: 'Looking for ', aShow."
	found := (self getShow: aShow) isEmpty not.
	found ifTrue: [Transcript show: aShow , ' - Found!'.Transcript cr.].
	
	^ found.
]

{ #category : #api }
PirateRobot >> getMovie: aString [ 
	| main rows baseUrl suffix searchRows dud |
	
	^self getTorrents: aString category: '201,202,207'.
	
]

{ #category : #api }
PirateRobot >> getShow: aString [ 
	^self getTorrents: aString category: '205,208'.

]

{ #category : #'test code' }
PirateRobot >> getShowImage: aShowname [
	"not working"

	| main rows baseUrl suffix searchRows dud aString |
	baseUrl := 'http://www.addic7ed.com/images/showimages/'.
	suffix := '.jpg'.
	aString := self removeBlanksFrom: aShowname asLowercase.
	[ self newGet: baseUrl , aString , suffix ]
		on: Exception
		do: [ 
			Transcript crShow: 'Exception on newGet'.
			self halt ].
	self checkOk.	"Parse page"
	self parseBody.
	dud := (dom tagOfClass: HtmlH2Node) children second innerContents.
	(dud findString: 'No hits') > 0
		ifTrue: [ ^ Array new ].
	main := dom tagWithId: 'searchResult'.
	searchRows := main tagsOfClass: HtmlTRNode.
	rows := self parseRows: searchRows allButFirst.
	^ rows
]

{ #category : #'test code' }
PirateRobot >> getTest [
	| |
	^self getShow: 'haven%20s02*'.

]

{ #category : #'test code' }
PirateRobot >> getTest: aString [
	| main rows baseUrl suffix searchRows dud |
	baseUrl := 'http://thepiratebay.org/search/'.
	suffix := '/0/9/205,208'.
	self newGet: (baseUrl , aString , suffix ).
	self checkOk.
	
	"Parse page"
	self parseBody.
	dud := (dom tagOfClass: HtmlH2Node) children second innerContents.
	((dud findString: 'No hits') >0) ifTrue: [^Array new].
	main := dom tagWithId: 'searchResult'.
"	sidorHtml := main tagWithId: 'all_pages'."
"	main := main tagWithClass: 'list_mode_thumb'."
	searchRows := main tagsOfClass: HtmlTRNode.
	rows := self parseRows: (searchRows allButFirst) .
"	rowsSorted := rows sort: [:a :b | (a third >= b third)]."
"self halt."
	^rows
	"
	(request url urlString includesSubString: 'WeAreClosed') ifTrue: [self error: 'Closed'].
	form := dom tagWithId: 'loginForm'.
		""Send a post to actually login""
	request openPostTo: form action.
	fields := Dictionary new.

	""Build request""
	request addHeader: 'Content-Type' value: 'application/x-www-form-urlencoded'.
	request entityString: (self argString: fields).

	(request responseBody includesSubString: 'You did something wrong') ifTrue: [self error: 'Something went wrong'].
"
]

{ #category : #private }
PirateRobot >> getTorrents: aString category: categoryString [
	| main rows baseUrl suffix searchRows dud |self halt.
	baseUrl := 'https://' , self host , '/search/'.
	suffix := '/0/7/' , categoryString.
	[ self newGet: baseUrl , aString , suffix ]
		on: Exception
		do: [ :ex | 
			Transcript crShow: 'Exception on newGet: ', ex printString.	self halt.
			^ OrderedCollection new ].
	self checkOk.
	self parseBody.
	dud := (dom tagOfClass: HtmlH2Node) children second innerContents.
	(dud findString: 'No hits') > 0
		ifTrue: [ ^ Array new ].
	main := dom tagWithId: 'searchResult'.
	searchRows := main tagsOfClass: HtmlTRNode.
	searchRows := main children.
	rows := self parseRows: searchRows allButFirst.
	^ rows
]

{ #category : #private }
PirateRobot >> host [
	^ 'thepiratebay.mn'
]

{ #category : #private }
PirateRobot >> parseRows: fullHtml [ 
	| rows title cell2 leechers seeders torrent magnet |
	rows := OrderedCollection new.
	fullHtml
		do: [:html | 
			cell2 := html children second.
			title := cell2 children first children first innerContents.
			torrent := cell2 children second href.
			seeders := html children third innerContents asInteger.
			leechers := html children fourth innerContents asInteger.
			rows
				add: (Array
						with: title
						with: torrent
						with: seeders
						with: leechers)].
	"rows first inspect."
	"self halt."
	^ rows
]
