Class {
	#name : #Eztv,
	#superclass : #WRHttpRobot,
	#category : #'CAs-Pirate'
}

{ #category : #api }
Eztv >> getEpisodes: anEztvString [ 
	| rows rows2 regexp rows3 dict seas ep maxEp rows4 |
	dict:= Dictionary new.
	rows := self getShow: anEztvString.
	rows2 := rows collect: [ :each| each first ].
regexp:= 'S\d\dE\d\d' asRegexIgnoringCase .
rows3 := rows2 collect: [ :each| regexp search: each. regexp subexpression: 1 ] .
rows4 := rows3 reject: [ :each|each isNil ].
rows4 asSet do: [ :each| 
	seas:= (each copyFrom:2to:3)asInteger .
	ep:= (each copyFrom:5to:6)asInteger . 
	maxEp := dict at: seas ifAbsent: [0].
dict at: seas put: (ep max: maxEp).
]
.
	^ dict
]

{ #category : #api }
Eztv >> getShow: anEztvString [
	| rows baseUrl searchRows table url |
	url := anEztvString.
	baseUrl := 'https://eztv.ch/shows/'.
	(anEztvString includesSubstring: 'eztv.ch')
		ifFalse: [ url := baseUrl , url ].
	url := url asZnUrl closePath.
	[ self newGet: url ]
		on: Exception
		do: [ 
			Transcript
				show: 'Exception on Eztv/newGet';
				cr.
			^ OrderedCollection new ].
	self checkOk.
	self parseBody.
	table := dom tagWithClass: #header_noborder.
	table isNil
		ifTrue: [ table := dom tagWithClass: #forum_header_noborder ].
	table isNil
		ifTrue: [ self halt ].
	searchRows := table tagsNamed: 'hover'.
	rows := searchRows collect: [ :ea | self parseRow: ea ].
	rows := rows reject: [ :each | each isNil ].
	rows := rows reject: [ :each | each includesSubstring: '1080p' caseSensitive: false ].
	^ rows
]

{ #category : #api }
Eztv >> getShow: anEztvString episode: anSxxExx [
	| rows matches |
	rows := self getShow: anEztvString.
	matches := rows select: [ :ea | ea first includesSubstring: anSxxExx ].
	^ matches
]

{ #category : #private }
Eztv >> parseRow: aTR [
	| title magnet magLink |
	title := (aTR tagWithClass: #epinfo) innerContents.	"Is there a Magnet link?"
	magLink := aTR tagWithClass: #magnet.
	magLink isNil
		ifTrue: [ ^ nil ].
	magnet := magLink href.
	^ {title.
	magnet.
	-1.
	-1}
]

{ #category : #samples }
Eztv >> sample [
	^self getShow: '878/marvels-agents-of-shield'
]

{ #category : #samples }
Eztv >> sample2 [
	^self getShow: '878/marvels-agents-of-shield' episode: 'S02E05'
]

{ #category : #samples }
Eztv >> sample3 [
	^self getShow: 'https://eztv.ch/shows/715/elementary/' episode: 'S03E21'
]

{ #category : #samples }
Eztv >> sample4 [
	^ self getEpisodes: 'https://eztv.ch/shows/715/elementary/'
]
