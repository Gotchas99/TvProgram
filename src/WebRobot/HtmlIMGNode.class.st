Class {
	#name : #HtmlIMGNode,
	#superclass : #HtmlDOMNode,
	#category : #'HTML-DOM'
}

{ #category : #accessing }
HtmlIMGNode >> src [
	^self attributes at: 'src' ifAbsent: ''
]

{ #category : #accessing }
HtmlIMGNode >> tag [
	^ 'img'
]
