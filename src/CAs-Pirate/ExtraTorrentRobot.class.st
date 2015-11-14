Class {
	#name : #ExtraTorrentRobot,
	#superclass : #WRHttpRobot,
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
ExtraTorrentRobot >> getTorrents: aString [
	| main rows baseUrl suffix searchRows |
	"sample search string
	http://extratorrent.cc/search/?new=1&search=blacklist+s03e02&s_cat=8"
	baseUrl := 'http://extratorrent.cc/search/?new=1&search='.
	suffix := '&s_cat=8'.
	[ self newGet: baseUrl , aString , suffix ]
		on: Exception
		do: [ :ex | 
			Transcript crShow: 'Exception on ExtraTorrent:newGet:' , ex printString.
			self halt.
			^ OrderedCollection new ].
	self checkOk.
	self parseBody.
	(dom innerContents findString: '<i>No torrents</i>') > 0
		ifTrue: [ ^ Array new ].
	main := (dom tagWithClass: 'tl') .
	searchRows := (main tagsWithClass: 'tlr') .
	rows := self parseRows: searchRows.
	^ rows
]

{ #category : #'as yet unclassified' }
ExtraTorrentRobot >> parseRows: fullHtml [
	| rows title cell2 leechers seeders torrent hrefs isEnglish |
	rows := OrderedCollection new.
	fullHtml
		do: [ :html | self halt.
			isEnglish:= (html tagsOfClass: HtmlIMGNode) anySatisfy: [:i| i src includesSubstring:  'us-uk.gif'caseSensitive: false].
			cell2 := html children first.
			title := (cell2 tagWithClass: 'cellMainLink') innerContents.
			hrefs := (html tagsOfClass: HtmlANode) collect: [ :a | a href ].
			torrent := hrefs select: [ :href | href includesSubstring: 'magnet:' ].
			seeders := (html tagWithClass: 'sy') innerContents asInteger.
			leechers := (html tagWithClass: 'ly') innerContents asInteger.
			torrent
				ifNotEmpty: [ 
					rows
						add:
							(Array
								with: title
								with: torrent first
								with: seeders
								with: leechers) ] ].	"rows first inspect."	"self halt."
	^ rows
]
