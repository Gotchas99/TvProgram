Class {
	#name : #KickassRobot,
	#superclass : #WRHttpRobot,
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
KickassRobot >> getShow: aString [ 
	^self getTorrents: aString category: 'tv'.
]

{ #category : #'as yet unclassified' }
KickassRobot >> getTorrents: aString category: categoryString [
	| main rows baseUrl suffix searchRows |
	baseUrl := 'https://kickass.to/usearch/'.
	suffix := '%20category:' , categoryString.
	[ self newGet: baseUrl , aString , suffix ]
		on: Exception
		do: [ :ex| 
			Transcript crShow: 'Exception on newGet'.
			self halt.
			^ OrderedCollection new ].
	self checkOk.	
	self parseBody.
"	dud := (dom tagOfClass: HtmlH2Node) children second innerContents."
	(dom innerContents findString: ' did not match any documents') > 0
		ifTrue: [ ^ Array new ].
	main := dom tagWithClass: 'data'.
	searchRows := (main tagsOfClass: HtmlTRNode) allButFirst .
	rows := self parseRows: searchRows .
	^ rows
]

{ #category : #'as yet unclassified' }
KickassRobot >> parseRows: fullHtml [
	| rows title cell2 leechers seeders torrent |
	rows := OrderedCollection new.
	fullHtml
		do: [ :html | 
			cell2 := html children first.
			title := (cell2 tagWithClass: 'cellMainLink') innerContents.
			title := title copyReplaceAll: '<strong class="red">' with: ''.
			title := title copyReplaceAll: '</strong>' with: ''.
			torrent := (cell2 tagWithClass: 'imagnet') href.
			seeders := (html tagWithClass: 'green') innerContents asInteger.
			leechers := (html tagWithClass: 'lasttd') innerContents asInteger.
			rows
				add:
					(Array
						with: title
						with: torrent
						with: seeders
						with: leechers) ].	"rows first inspect."	"self halt."
	^ rows
]
