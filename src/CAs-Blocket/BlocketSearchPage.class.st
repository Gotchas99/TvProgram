Class {
	#name : #BlocketSearchPage,
	#superclass : #BlocketPageRoot,
	#instVars : [
		'project'
	],
	#category : #'CAs-Blocket-Web'
}

{ #category : #'as yet unclassified' }
BlocketSearchPage >> addSearch [
	| s |
	s := self request: 'Söksträng'.
	s isEmptyOrNil
		ifFalse: [ project addSearch: s ]
]

{ #category : #'as yet unclassified' }
BlocketSearchPage >> project:aBlocketProject [
	project:= aBlocketProject 
]

{ #category : #'as yet unclassified' }
BlocketSearchPage >> removeSearch: aString [
	(self confirm: 'Är du säker på att du vill ta bort?')
		ifTrue: [ project removeSearch: aString ]
]

{ #category : #'as yet unclassified' }
BlocketSearchPage >> renderContentOn: html [
	|  p |
	html div
		class: #pageHeader;
		with: project printString.
	html
		paragraph: [ 
			html anchor
				callback: [ self back ];
				with: 'Tillbaka'.

			html heading level3 with: 'Söksträngar'.
			html anchor
				callback: [ self addSearch ];
				with: [ html heading level4 with: 'Ny sökning' ].
			p := project searches
				do: [ :s | 
					html text: s , '   -   '.
					html anchor
						callback: [ self removeSearch: s ];
						with: [ 
									html image
										class: 'delete-icon';
										url: (BlocketFileLibrary urlOf: #deletePng) ].
					html break ] ].
"	html div
		class: #pageHeader;
		with: 'Resultatet'."
	"p := project result reject: [ :i | i isDontShow ].
	html unorderedList
		class: #results;
		with: [ p reverse do: [ :i | self renderItem: i on: html ] ]"
]
