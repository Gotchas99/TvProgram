Class {
	#name : #BlocketProject,
	#superclass : #Object,
	#instVars : [
		'name',
		'searches',
		'result'
	],
	#category : #'CAs-Blocket'
}

{ #category : #'as yet unclassified' }
BlocketProject class >> newBlandare [
	| p |
	p := self new.
	p name: 'Blandare'.
	p addSearch: 'http://www.blocket.se/goteborg?q=*duschblandare*&cg=2000&w=1&st=s&ca=15&l=0&md=th'.

	p addSearch: 'http://www.blocket.se/goteborg?q=*termostat*+*blandare*&cg=2000&w=1&st=s&ca=15&l=0&md=th'.
"	p addSearch: 'http://www.blocket.se/goteborg?q=*blandare*&cg=2000&w=1&st=s&ca=15&l=0&md=th'."
	p refresh.
	^p
]

{ #category : #'as yet unclassified' }
BlocketProject >> addItem: anItem [
	result addIfNotPresent: anItem
]

{ #category : #'as yet unclassified' }
BlocketProject >> addSearch: aString [
" a search is a Blocket-URL that gives a list of items"
	searches add: aString
]

{ #category : #'as yet unclassified' }
BlocketProject >> initialize [
	name := 'Nytt projekt'.
	result := SortedCollection new.
	searches := OrderedCollection new.
]

{ #category : #'as yet unclassified' }
BlocketProject >> name [
	^name
]

{ #category : #'as yet unclassified' }
BlocketProject >> name: aString [
	^name := aString
]

{ #category : #'as yet unclassified' }
BlocketProject >> refresh [
	| t1 |
	searches
		do: [:t3 | 
			t1 := BlocketRobot new getList: t3.
			t1
				do: [:t4 | self addItem: t4]]
]

{ #category : #'as yet unclassified' }
BlocketProject >> result [
	^result
]
