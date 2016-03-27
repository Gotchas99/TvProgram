Class {
	#name : #BlocketProjPage,
	#superclass : #BlocketPageRoot,
	#instVars : [
		'project'
	],
	#category : #'CAs-Blocket-Web'
}

{ #category : #'as yet unclassified' }
BlocketProjPage >> dontShow: anItem [
	anItem dontShow 
]

{ #category : #'as yet unclassified' }
BlocketProjPage >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
BlocketProjPage >> project:aBlocketProject [
	project:= aBlocketProject 
]

{ #category : #'as yet unclassified' }
BlocketProjPage >> refresh [
	project refresh
]

{ #category : #'as yet unclassified' }
BlocketProjPage >> renderContentOn: html [
	| p |
	html div
		class: #pageHeader;
		with: project printString.
	html
		paragraph: [ 
			html anchor
				callback: [ self back ];
				with: 'Tillbaka'.
			html anchor
				callback: [ self showSearch ];
				with: 'Visa sökningar'.
			html div
				style: 'float:right';
				with: [ 
							html anchor
								callback: [ self refresh ];
								with: 'Uppdatera' ] ].
	html div
		class: #pageHeader;
		with: 'Resultat'.
	p := project result reject: [ :i | i isDontShow ].
	html unorderedList
		class: #results;
		with: [ p reverse do: [ :i | self renderItem: i on: html ] ]
]

{ #category : #'as yet unclassified' }
BlocketProjPage >> renderItem: i on: html [
	^ html listItem
		class: 'item-box';
		with: [ 
					html div
						class: 'thumb-div';
						with: [ 
									html div
										class: #new;
										with: i newMark.
									html div
										class: #gone;
										with: i goneMark.
									i thumb
										ifNotNil: [ 
											html anchor
												callback: [ self showItem: i ];
												with: [ 
															html image
																class: #thumb;
																url: i thumb ] ].
									i isStarred
										ifTrue: [ 
											html image
												class: 'star-icon';
												url: (BlocketFileLibrary urlOf: #stargold48Png) ] ].
					html div
						class: 'title-box';
						with: [ 
									html div
										class: #title;
										with: [ 
													html anchor
														callback: [ self showItem: i ];
														class: #title;
														with: i title ].
									html div
										class: #datum;
										with: i dateTimeString.
									html div
										class: #pris;
										with: i price ].
					html div
						class: 'dont-show';
						with: [ 
									html anchor
										callback: [ self dontShow: i ];
										with: [ 
													html image
														class: 'delete-icon';
														url: (BlocketFileLibrary urlOf: #deletePng) ] ].
					html break.
					html break	"html anchor
						callback: [ self showItem: i ];
						with: [ html span class: 'link-spanner' ] " ]
]

{ #category : #'as yet unclassified' }
BlocketProjPage >> showItem: aBlockItem [ 
	self call:(BlocketItemPage new item:aBlockItem )
]

{ #category : #'as yet unclassified' }
BlocketProjPage >> showSearch [
	self call: (BlocketSearchPage new project: project)
]
