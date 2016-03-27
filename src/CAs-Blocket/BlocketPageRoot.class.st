Class {
	#name : #BlocketPageRoot,
	#superclass : #WAComponent,
	#category : #'CAs-Blocket-Web'
}

{ #category : #'as yet unclassified' }
BlocketPageRoot >> back [
	self answer.
]

{ #category : #'as yet unclassified' }
BlocketPageRoot >> updateRoot: aHtmlRoot [
	super updateRoot: aHtmlRoot.
	BlocketFileLibrary default updateRoot: aHtmlRoot.
	aHtmlRoot meta
		name: 'viewport';
		content: 'width=device-width, minimum-scale=1, maximum-scale=1, initial-scale=1'.
	aHtmlRoot title: 'Mitt Blocket'
]
