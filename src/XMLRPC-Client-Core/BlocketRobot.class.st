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
	MonthMap at:  'okt' put: 10.
	MonthMap at: 'nov' put: 11.
	MonthMap at: 'dec' put: 12 .
]

{ #category : #'as yet unclassified' }
BlocketRobot >> getItemFromUrl: url [
	| main |
	[self newGet: url] on: Error do: [:e| ^nil].
	self checkOk.
	"Parse page"
	self parseBody.

	main := dom tagWithClass: 'view'.
	^self parseItem: main.
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
		| |
		^html children first innerContents withBlanksTrimmed
"		tag := html tagWithClass: 'list_price'.
		(tag = 'a')  ifTrue: [tag := tag children first].
		^tag children first innerContents withBlanksTrimmed"
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
			i isCDATA ifTrue: [txt := txt, i  innerContents withBlanksTrimmed].
		].
		"first innerContents withBlanksTrimmed."
"		tag := html tagWithClass: 'list_price'.
		(tag = 'a')  ifTrue: [tag := tag children first].
		^tag children first innerContents withBlanksTrimmed"
		^txt
]

{ #category : #'as yet unclassified' }
BlocketRobot >> parseItem: html [
	| flds t details mediaCont thumbs images |
	flds := Dictionary new.
	t := (html tagOfClass: HtmlH2Node) innerContents withBlanksTrimmed.
	flds at: #title put: t.

"	t := (html tagWithClass: 'body') children first innerContents withBlanksTrimmed."
	t:= self parseDesc:  (html tagWithClass: 'body').
	flds at: #desc put: t.
	
	details := html tagWithClass: 'details'.
	(details tagWithClass: 'red_text') notNil ifTrue: [
			t := (details tagWithClass: 'red_text')  innerContents withBlanksTrimmed.
			flds at: #price put: t.
			t := (details tagWithClass: 'line_through')  innerContents withBlanksTrimmed.
			flds at: #oldPrice put: t.
		].
	
	images := OrderedCollection new.
	mediaCont := html tagWithClass: 'media_container'.
	thumbs := mediaCont tagWithId: 'thumbs'.
	thumbs children do: [:li| images add: ((li children first children first) attributes at: #src)].
	flds at: #images put: images.
"	
		dt := html tagWithClass: 'date_image'.
		r date: ( (dt children at: 1) innerContents withBlanksTrimmed).
		r time: ( (dt children at: 2) innerContents withBlanksTrimmed).
		
		cat := title tagWithClass: 'cat_geo'.
		r category: ( ((cat tagsOfClass: HtmlANode) first) innerContents withBlanksTrimmed).
		r area: (self parseArea: cat)."

"		r inspect."
		"self halt."
	^flds
	
	
]

{ #category : #'as yet unclassified' }
BlocketRobot >> parseRows: fullHtml [
	| r rows title cat dt imgCont |
	rows := OrderedCollection new.
	fullHtml do: [ :html |
		r := BlockItem new html: html.
		
		r id: (html attributes at: 'id') .
		
		dt := html tagWithClass: 'date_image'.
		r date: (self parseDate: ( (dt children at: 1) innerContents withBlanksTrimmed)).
		r time: ( (dt children at: 2) innerContents withBlanksTrimmed).
		
		imgCont := html tagWithClass: 'image_container'.
		r thumb: ( (imgCont tagWithClass: 'ad_image')  ).
		
		title := html children at: 3.
		r title: ( (title children at: 1) innerContents withBlanksTrimmed).
		r priceCut: ( (title tagWithClass: 'sprite_list_icon_price_arrow') notNil ).
		r priceCut 
			ifTrue: [r price: ( (title tagWithClass: 'list_price') children first  innerContents withBlanksTrimmed).]
			ifFalse:[r price: ( (title tagWithClass: 'list_price') innerContents withBlanksTrimmed).].

		r url: ( (title children at: 1) href).
	
		cat := title tagWithClass: 'cat_geo'.
		r category: ( ((cat tagsOfClass: HtmlANode) first) innerContents withBlanksTrimmed).
		r area: (self parseArea: cat).

"		r inspect."
		"self halt."
		
		rows add: r.
	].
"rows first inspect."
"self halt."
	^rows
	
	
]
