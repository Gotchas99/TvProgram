Class {
	#name : #BlocketRobot,
	#superclass : #WRHttpRobot,
	#classVars : [
		'MonthMap'
	],
	#category : #'CAs-Blocket'
}

{ #category : #'as yet unclassified' }
BlocketRobot class >> init [
	MonthMap := Dictionary new.
	MonthMap at: 'jan' put: 1.
	MonthMap at: 'feb' put: 2.
	MonthMap at: 'mar' put: 3.
	MonthMap at: 'apr' put: 4.
	MonthMap at: 'maj' put: 5.
	MonthMap at: 'jun' put: 6.
	MonthMap at: 'jul' put: 7.
	MonthMap at: 'aug' put: 8.
	MonthMap at: 'sept' put: 9.
	MonthMap at: 'okt' put: 10.
	MonthMap at: 'nov' put: 11.
	MonthMap at: 'dec' put: 12
]

{ #category : #'as yet unclassified' }
BlocketRobot >> checkIfItemExists: aBlocketItem [
	| main |
	[ self newGet: aBlocketItem url ]
		on: Error
		do: [ :e | 
			self halt.
			self traceCr: 'checkIfItemExist:Error'
			e signal ].
	self checkOk.
	self parseBody.
	(dom innerContents includesSubstring: 'Hittade inte annonsen')
		ifTrue: [ ^ false ].
	main := dom tagWithClass: 'view'.
	main ifNil: [ ^ false ].
	^ true
]

{ #category : #'as yet unclassified' }
BlocketRobot >> getItemFromUrl: url [
	| main |
	[ self newGet: url ]
		on: Error
		do: [ :e | ^ nil ].
	self checkOk.	"Parse page"
	self parseBody.
	(dom innerContents includesSubstring: 'Hittade inte annonsen')
		ifTrue: [ ^ #notFound ].
	main := dom tagWithClass: 'view'.
	main ifNil: [ ^ nil ].
	^ self parseItem: main
]

{ #category : #'as yet unclassified' }
BlocketRobot >> getList: aURL [
	| rows |
	self newGet: aURL.
	self checkOk.
	
	"Parse page"
	self parseBody.
"self halt."
	rows := self parseRows: (dom tagsWithClass: 'item_row') .
	^rows

]

{ #category : #'as yet unclassified' }
BlocketRobot >> getTest [
	| main rows sidorHtml |
	self newGet: 'http://www.blocket.se/goteborg-angransande-lan'.
	self checkOk.
	
	"Parse page"
	self parseBody.
"self halt."
	main := dom tagWithId: 'blocket'.
	sidorHtml := main tagWithId: 'all_pages'.
	main := main tagWithClass: 'list_mode_thumb'.
	rows := self parseRows: (dom tagsWithClass: 'item_row') .
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

{ #category : #'as yet unclassified' }
BlocketRobot >> parseArea: html [
	| pull area |
	pull := html tagWithClass:'pull-left'.
	area := pull children last innerContents.
	area := area copyReplaceAll: ',&nbsp;' with: ''.
	^ area
]

{ #category : #'as yet unclassified' }
BlocketRobot >> parseDate: aString [
	| d split m date |
	aString = 'Igår' ifTrue: [ ^DateAndTime yesterday ].
	aString = 'Idag' ifTrue: [ ^DateAndTime today ].
	split := aString findTokens: ' '.
	d := (split at: 1) asInteger.
	m := MonthMap at: (split at: 2).
	date := Date year: (DateAndTime today year) month: m day: d.
	date > (DateAndTime today) ifTrue: [
		date := Date year: (DateAndTime today year)-1 month: m day: d.
		].
	^date
]

{ #category : #'as yet unclassified' }
BlocketRobot >> parseDesc: html [
		| txt |
		txt:=''.
		html children do: [:i|
			(i tag = 'br') ifTrue:[ txt := txt, '
'].
			i isCDATA ifTrue: [txt := txt, i  innerContents trimmed].
		].
		"first innerContents withBlanksTrimmed."
"		tag := html tagWithClass: 'list_price'.
		(tag = 'a')  ifTrue: [tag := tag children first].
		^tag children first innerContents withBlanksTrimmed"
		^txt
]

{ #category : #'as yet unclassified' }
BlocketRobot >> parseItem: html [
	| flds t details mediaCont  images |
	flds := Dictionary new.
	t := (html tagOfClass: HtmlH1Node) innerContents trimmed.
	flds at: #title put: t.
	t := self parseDesc: (html tagWithClass: 'body').
	flds at: #desc put: t.
	details := html tagWithId: 'price_container'.
			t := (details tagWithId: 'vi_price') innerContents trimmed.
			flds at: #price put: t.
			t := (details tagWithClass: 'text_secondary') .
t ifNotNil:[			flds at: #oldPrice put: t innerContents trimmed].
	images := OrderedCollection new.
	mediaCont := html tagWithClass: 'carousel-inner'.
"	thumbs := mediaCont tagWithId: 'thumbs'."
	mediaCont children do: [ :li | images add: (li children first  attributes at: 'data-src') ].
	flds at: #images put: images.	"	
		dt := html tagWithClass: 'date_image'.
		r date: ( (dt children at: 1) innerContents trimmed).
		r time: ( (dt children at: 2) innerContents trimmed).
		
		cat := title tagWithClass: 'cat_geo'.
		r category: ( ((cat tagsOfClass: HtmlANode) first) innerContents trimmed).
		r area: (self parseArea: cat)."	"		r inspect."	"self halt."
	^ flds
]

{ #category : #'as yet unclassified' }
BlocketRobot >> parseRows: fullHtml [
	| r rows title cat dt imgCont mediaBody |
	rows := OrderedCollection new.
	fullHtml
		do: [ :html | 
			r := BlocketItem new html: html.
			r id: (html attributes at: 'id').
			mediaBody := html children second.
			dt := mediaBody children first children second attributes at: #datetime.
			r dateTime: dt asDateAndTime.
			imgCont := html tagWithClass: 'image_container'.
			r thumb: (imgCont tagWithClass: 'item_image').
			title := mediaBody tagWithClass: 'item_link'.
			r title: title innerContents trimmed.
			r priceCut: (mediaBody tagWithClass: 'blocket-icon-price-lowered') notNil.
			r priceCut
				ifTrue: [ r price: (mediaBody tagWithClass: 'list_price') children first innerContents trimmed ]
				ifFalse: [ r price: (mediaBody tagWithClass: 'list_price') innerContents trimmed ].
			r url: title href.
			cat := mediaBody children first children first children first.
			r category: cat innerContents trimmed.
			r area: (self parseArea: mediaBody).
			rows add: r ].	
	^ rows
]
