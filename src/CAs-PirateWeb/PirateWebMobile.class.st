Class {
	#name : #PirateWebMobile,
	#superclass : #WAComponent,
	#instVars : [
		'model',
		'showsNotStarted',
		'showsStarted',
		'listId'
	],
	#category : #'CAs-PirateWeb'
}

{ #category : #'as yet unclassified' }
PirateWebMobile >> getList [
	| allShows tmp |
	allShows := PirateShow shows.
	model := OrderedCollection new.
	tmp := allShows collect: [:s|s nextEpisode].
	tmp := tmp reject: [:i| i isNil].
	self showsStarted ifTrue: [
		tmp := tmp reject: [:i|
			(i id = '01') and: [i season id = '01']
			]
		].
	model:= tmp.
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> initialize [
	super initialize .
	self refresh.
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> refresh [
	self getList .
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> renderContentOn: html [
	html div jqmHeader ;
		jqmFixedPosition;
		with: [
			html heading: 'TV-program-program' .
			html anchor jqmIcon: 'refresh';
				with: 'Refresh';
				callback: [self refresh] ].
	html div jqmContent ;
		with: [
			"html paragraph: 'hello'."
			self renderTypeSwitchOn: html.
			html paragraph.
			self renderListOn: html.
		].
	html div jqmFooter ;
		jqmFixedPosition;
		with: [html heading level4; 
				with: 'hello'].
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> renderListOn: html [
	listId := html nextId.
"	self halt.
"	html unorderedList 
		jqmListView ;
		id: listId;
		with: [
			model do: [ :s |
				html listItem: [
					html anchor
						callback: [];
						with: s season show name , ' - ' ,  s season id.
					]
				]
			]
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> renderTypeSwitchOn: html [
	html form
	with: [
"	self renderFormElementsOn: html element: ["
		html fieldSet
			jqmControlGroup;
			jqmHorizontal;
			with: [
				html label 
					for: html nextId;
					with: 'New'.
				html checkbox
					value: self showsNotStarted;
					id: html lastId.
				html label 
					for: html nextId;
					with: 'Started'.
				html checkbox
					value: self showsStarted;
					id: html lastId.
				]
		]
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> showsNotStarted [
	^ showsNotStarted ifNil: [showsNotStarted:=false]
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> showsNotStarted: aBoolean [
	showsNotStarted := aBoolean
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> showsStarted [
	^ showsStarted ifNil: [showsStarted:=true]
]

{ #category : #'as yet unclassified' }
PirateWebMobile >> showsStarted: aBoolean [
	showsStarted := aBoolean
]
