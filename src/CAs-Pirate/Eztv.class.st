Class {
	#name : #Eztv,
	#superclass : #WRHttpRobot,
	#category : #'CAs-Pirate'
}

{ #category : #api }
Eztv >> getShow: anEztvString [
	| rows baseUrl searchRows table |
	baseUrl := 'https://eztv.ch/shows/'.
	[ self newGet: baseUrl , anEztvString ]
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
		ifTrue: [ self halt ].
	searchRows := table tagsNamed: 'hover'.
	rows := searchRows collect: [ :ea | self parseRow: ea ].
	^ rows
]

{ #category : #api }
Eztv >> getShow: aString episode: anSxxExx [
	| rows matches |
	rows := self getShow: aString.
	matches := rows select: [ :ea | ea first includesSubstring: anSxxExx ].
	^ matches
]

{ #category : #private }
Eztv >> parseRow: aTR [
	| title magnet |
	title := (aTR tagWithClass: #epinfo) innerContents.
	magnet := (aTR tagWithClass: #magnet) href.
	^ {title. magnet. -1. -1.}
]

{ #category : #samples }
Eztv >> sample [
	^self getShow: '878/marvels-agents-of-shield'
]

{ #category : #samples }
Eztv >> sample2 [
	^self getShow: '878/marvels-agents-of-shield' episode: 'S02E05'
]
