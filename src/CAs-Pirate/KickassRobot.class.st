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
KickassRobot >> getShow: aKatString season: aSeasonId episode: anEpisodeId [
	| rows baseUrl searchRows table url rs a s eps seasons ep epId epRoot |
	url := aKatString.
	baseUrl := 'https://kat.cr/'.
	(aKatString includesSubstring: 'kat.cr')
		ifFalse: [ url := baseUrl , url ].
	url := url asZnUrl closePath.
	[ self newGet: url ]
		on: Exception
		do: [ :ex | 
			Transcript crShow: 'Exception on Kat/newGet:' , ex printString.
			^ OrderedCollection new ].
	self checkOk.
	self parseBody.
	table := dom tagWithClass: #mainpart.
	table isNil
		ifTrue: [ self halt ].
	searchRows := (table tagOfClass: HtmlTDNode) children.
	rs := searchRows readStream.
	seasons := Dictionary new.
	[ rs atEnd ]
		whileFalse: [ 
			a := rs next.
			a class = HtmlH3Node
				ifTrue: [ 
					s := a innerContents.
					eps := rs next.
					seasons at: s put: eps ] ].
	eps := seasons at: 'Season ' , aSeasonId.
	eps := eps children collect: [ :each | each tagWithClass: #infoListCut ].
	ep := eps select: [ :each | (each tagWithClass: #versionsEpNo) innerContents trimmed = ('Episode ' , anEpisodeId) ].
	epId := (ep first attributes at: #onclick) parseLiterals second third.
	[ self newGet: 'https://kat.cr/media/getepisode/' , epId ]
		on: Exception
		do: [ :ex | 
			Transcript crShow: 'Exception on Kat/newGet2:' , ex printString.
			^ OrderedCollection new ].
	self checkOk.
	self parseBody.
	epRoot := dom tagWithClass: #data.
	rows := self parseRowsShowpage: epRoot children allButFirst.
	rows := rows reject: [ :each | each isNil ].
	^ rows
]

{ #category : #'as yet unclassified' }
KickassRobot >> getTorrents: aString category: categoryString [
	| main rows baseUrl suffix searchRows |self halt.
	"sample search string
	https://kickass.to/usearch/Arrow%20category:tv%20verified:1%20season:13%20episode:20/"
	baseUrl := 'https://kat.cr/usearch/'.
	suffix := '%20category:' , categoryString , '%20verified:1/'.
	[ self newGet: baseUrl , aString , suffix ]
		on: Exception
		do: [ :ex | 
			Transcript crShow: 'Exception on Kickass:newGet:' , ex printString.
			self halt.
			^ OrderedCollection new ].
	self checkOk.
	self parseBody.
	(dom innerContents findString: ' did not match any documents') > 0
		ifTrue: [ ^ Array new ].
	main := dom tagWithClass: 'data'.
	searchRows := (main tagsOfClass: HtmlTRNode) allButFirst.
	rows := self parseRows: searchRows.
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

{ #category : #'as yet unclassified' }
KickassRobot >> parseRowsShowpage: fullHtml [
	| rows title leechers seeders torrent |
	rows := OrderedCollection new.
	fullHtml
		do: [ :html | 
			title := (html tagWithClass: 'cellMainLink') innerContents.
			title := title copyReplaceAll: '<strong class="red">' with: ''.
			title := title copyReplaceAll: '</strong>' with: ''.
			torrent := (html tagWithClass: 'imagnet') href.
			seeders := (html tagWithClass: 'green') innerContents asInteger.
			leechers := (html tagWithClass: 'lasttd') innerContents asInteger.
			rows
				add:
					(Array
						with: title
						with: torrent
						with: seeders
						with: leechers) ].
	^ rows
]
