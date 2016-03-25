Class {
	#name : #ExtraTorrentRobot,
	#superclass : #WRHttpRobot,
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
ExtraTorrentRobot >> getMagnet: aUrl [
	| baseUrl links  magLink |
	baseUrl := 'http://extratorrent.cc'.
	[ self newGet: baseUrl , aUrl ]
		on: Exception
		do: [ :ex | 
			Transcript crShow: 'Exception on ExtraTorrent:getMagnet:' , ex printString.
			self halt.
			^ OrderedCollection new ].
	self checkOk.
	self parseBody.
	(dom innerContents findString: '<i>No torrents</i>') > 0
		ifTrue: [ ^ Array new ].
	links := dom tagsOfClass: HtmlANode.
	magLink := links detect: [ :l | l href beginsWith: 'magnet:' ].
	^ magLink href 
]

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
	(dom innerContents findString: 'total <b style="color: #ff0000;">0</b> torrents found on your search query') > 0
		ifTrue: [ ^ Array new ].
	main := (dom tagWithClass: 'tl') .
	searchRows := (main tagsWithClass: 'tlr') .
	rows := self parseRows: searchRows.
	^ rows
]

{ #category : #'as yet unclassified' }
ExtraTorrentRobot >> parseRows: fullHtml [
	| rows title leechers seeders hrefs isEnglish as link url tmp links |
	tmp := OrderedCollection new.
	rows := OrderedCollection new.
	fullHtml
		do: [ :html | 
			isEnglish := (html tagsOfClass: HtmlIMGNode)
				anySatisfy: [ :i | i src includesSubstring: 'uk-us.gif' caseSensitive: false ].
			as := html tagsOfClass: HtmlANode.
			links := as select: [ :a | a href includesSubstring: '/torrent/' ].
			links := links reject: [ :a | a href includesSubstring: '#comment' ].
			link := links first.
			title := link attributes at: #title ifAbsent: '<Unknown>'.
			(title beginsWith: 'view ')
				ifTrue: [ title := title allButFirst: 5 ].
			url := link href.
			hrefs := as collect: [ :a | a href ].
			seeders := (html tagWithClass: 'sy') ifNotNil:  [:x|x innerContents asInteger]ifNil: [0].
			leechers := (html tagWithClass: 'ly') ifNotNil:  [:x|x innerContents asInteger]ifNil: [0].
		
			isEnglish
				ifTrue: [ 
					tmp
						add:
							(Array
								with: title
								with: url
								with: seeders
								with: leechers) ] ].	"rows first inspect."	"self halt."
	tmp
		do: [ :r | 
			rows
				add:
					(Array
						with: r first
						with: (self getMagnet: r second)
						with: r third
						with: r fourth) ].
	^ rows
]
