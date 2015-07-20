Class {
	#name : #PirateEpisode,
	#superclass : #PirateVideo,
	#instVars : [
		'season'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateEpisode >> <= aPirateEpisode [
	^(self fullId) caseInsensitiveLessOrEqual: (aPirateEpisode fullId).
]

{ #category : #'as yet unclassified' }
PirateEpisode >> delete [
	season removeEpisode: self.
	season:= nil.
	super delete.
	
]

{ #category : #'as yet unclassified' }
PirateEpisode >> episodeId [
	^ season seasonId , 'E',self id
]

{ #category : #'as yet unclassified' }
PirateEpisode >> fullId [
	^ season fullId , 'E',self id
]

{ #category : #'as yet unclassified' }
PirateEpisode >> getEztvTorrents [
	^ Eztv new getShow: self season show eztv episode: self episodeId
]

{ #category : #'as yet unclassified' }
PirateEpisode >> getPirateTorrents [
	^ PirateRobot new getShow: self tpbString.
]

{ #category : #'as yet unclassified' }
PirateEpisode >> getTorrents [
	| t tpb sem kickass err |
	t := OrderedCollection new.
	err := OrderedCollection new.
	sem := Semaphore new.
"	[ 
	self season show eztv isNil
		ifFalse: [ 
			[ eztv := self getEztvTorrents ]
				on: Error
				do: [ :ex | err add: ex ] ].
	sem signal ] fork."
	[ 
	tpb := nil.	"PirateRobot new getShow: self tpbString."
	sem signal ] fork.
	[ 
	[ kickass := KickassRobot new getShow: self tpbString ]
		on: Error
		do: [ :ex | err add: ex ].
	sem signal ] fork.
	sem
		wait;
		wait.
	err isEmpty
		ifFalse: [ "Error signal: err first printString.self halt"
			Transcript crShow: 'Error on getTorrents: ' , err printString].
"	eztv isNil
		ifFalse: [ t addAll: eztv ]."
	tpb isNil
		ifFalse: [ t addAll: tpb ].
	kickass isNil
		ifFalse: [ t addAll: kickass ].
	t := t reject: [ :each | each first includesSubstring: '1080p' caseSensitive: false ].
	^ t
]

{ #category : #'as yet unclassified' }
PirateEpisode >> needsTorrent [
	self season show archived
		ifTrue: [ ^ false ].
	^ super needsTorrent
]

{ #category : #'as yet unclassified' }
PirateEpisode >> resetFileAndStatus [
	Transcript show:'hej'.
	torrent := nil.
	falseTorrents := nil.
	subTitle := nil.
	viewed := false.
	Transcript show:' då! '
]

{ #category : #'as yet unclassified' }
PirateEpisode >> resetUplinks: up [
	season := up.
]

{ #category : #'as yet unclassified' }
PirateEpisode >> season [
	^season
]

{ #category : #'as yet unclassified' }
PirateEpisode >> season: aSeason [
	season := aSeason
]

{ #category : #'as yet unclassified' }
PirateEpisode >> subtitlesByHash: lang [
	| os hash subs fileSize aSeason anEpisode |
	self videoFile ifNil:[^#()].

	hash := self videoFile videoHash.
	hash ifNil: [^#()]. 
	fileSize := self videoFile fileSize.
	aSeason := self season id asInteger  .
	anEpisode := self id asInteger  .
	os:= OpenSubClient current.
"	os login."
	subs := os searchSubtitlesForHash: hash size: fileSize season: aSeason episode: anEpisode lang: lang.
"	os logout."
	^ subs
]

{ #category : #'as yet unclassified' }
PirateEpisode >> subtitlesByTitle: lang [
	| os subs aName aSeason anEpisode |
	aName := self season name.
	aSeason := self season id asInteger  .
	anEpisode := self id asInteger  .

	os:= OpenSubClient current.
	os login.
	subs := os searchSubtitlesByname: aName season: aSeason episode: anEpisode lang: lang.
	os logout.
	^ subs
]
