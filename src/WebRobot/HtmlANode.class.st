Class {
	#name : #HtmlANode,
	#superclass : #HtmlDOMNode,
	#category : #'HTML-DOM'
}

{ #category : #'as yet unclassified' }
HtmlANode >> href [
	^self attributes at: 'href' ifAbsent: ''
]

{ #category : #accessing }
HtmlANode >> tag [
	^ 'a'
]
