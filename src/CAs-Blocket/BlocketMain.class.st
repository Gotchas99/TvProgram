Class {
	#name : #BlocketMain,
	#superclass : #BlocketPageRoot,
	#category : #'CAs-Blocket-Web'
}

{ #category : #'as yet unclassified' }
BlocketMain class >> canBeRoot [
	^true.
]

{ #category : #'as yet unclassified' }
BlocketMain class >> handlerName [
	^ 'blocket'
]

{ #category : #'as yet unclassified' }
BlocketMain class >> initFileLibrary [
	<script>
	BlocketFileLibrary addAllFilesIn: 'C:\Pharo4.0\webRes'
]

{ #category : #'as yet unclassified' }
BlocketMain class >> initialize [
	WAAdmin register: self asApplicationAt: self handlerName
]

{ #category : #'as yet unclassified' }
BlocketMain >> addProject [
	| s p |
	s := self request: 'Projektnamn'.
	s isEmptyOrNil
		ifFalse: [ 
			(p := BlocketProject new) name: s.
			BlocketManager current addProject: p ]
]

{ #category : #'as yet unclassified' }
BlocketMain >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
BlocketMain >> removeProject: aProject [
	(self confirm: 'Är du säker på att du vill ta bort?')
		ifTrue: [ BlocketManager current removeProject: aProject ]
]

{ #category : #'as yet unclassified' }
BlocketMain >> renderContentOn: html [
	html heading: 'Blocket projekt'.
	html anchor
		callback: [ self addProject ];
		with: 'Nytt projekt'.
	html
		break;
		break;
		text: 'Projektlista';
		break.
	BlocketManager current projects
		do: [ :p | 
			html anchor
				callback: [ self showProject: p ];
				with: p printString.
			html text: '   -   '.
			html anchor
				callback: [ self removeProject: p ];
				with: 'Ta bort'.
			html break ].
	html break
]

{ #category : #'as yet unclassified' }
BlocketMain >> showProject: aBlocketProject [ 
	self call:(BlocketProjPage new project:aBlocketProject )
]
