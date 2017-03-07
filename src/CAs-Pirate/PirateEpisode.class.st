Class {
	#name : #PirateEpisode,
	#superclass : #PirateVideo,
	#instVars : [
		'season',
		'fullId'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
PirateEpisode class >> getVideoFiles [
	| ep  |
	ep := PirateShow allViewableEpisodes.
	ep := ep select: [ :e | e videoFile isNil ].
	ep := ep select: [ :e | e torrent isNotNil ].
"	ep := ep reject: [ :e | e torrent containsRarFile ]."
	ep
		do: [ :e | 
			e videoFile: e torrent videoFile.
]
]

{ #category : #temporaries }
PirateEpisode class >> setupAllVideoFiles [
	| eps |
	eps := PirateShow shows collect: [ :show | show allEpisodes reject: [ :ep | ep isViewed ] ].
	eps := eps flattened.
	eps := eps reject: [ :each | each torrent isNil ].
	eps := eps select: [ :each | each videoFile isNil ]
]

{ #category : #'as yet unclassified' }
PirateEpisode class >> validateAllTorrents [
	PirateShow shows do: [ :s | 
		s seasons do: [ :sea | 
			sea episodes do: [ :e | 
				e validateTorrent ] ] ]
]

{ #category : #'as yet unclassified' }
PirateEpisode class >> validateAllVideoFiles [
	PirateShow shows do: [ :s | 
		s seasons do: [ :sea | 
			sea episodes do: [ :e | 
				e validateVideofile] ] ]
]

{ #category : #'as yet unclassified' }
PirateEpisode >> <= aPirateEpisode [
	self species == aPirateEpisode species
		ifTrue: [ ^ self fullId caseInsensitiveLessOrEqual: aPirateEpisode fullId ]
		ifFalse: [ ^ false ]
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
	^ fullId 
]

{ #category : #torrents }
PirateEpisode >> getExtraTorrents [
	"^ ExtraTorrentRobot new getTorrents: self fullId"
	^nil
]

{ #category : #deprecated }
PirateEpisode >> getEztvTorrents [
	^ Eztv new getShow: self season show eztv episode: self episodeId
]

{ #category : #torrents }
PirateEpisode >> getKickassTorrents [
	"self season show kat
		ifNotNil: [ kat := KickassRobot new getShow: self season show kat season: self season id episode: self id ]
		ifNil: [ kat := nil ].
	^ kat"
	^ nil
]

{ #category : #torrents }
PirateEpisode >> getPirateTorrents [
	^ PirateRobot new getShow: self tpbString.
]

{ #category : #torrents }
PirateEpisode >> getRarbgTorrents [
	| rarbg |
	self season show imdb
		ifNotNil: [ 
			rarbg := TorrentApi new
				getShow: self season show imdb
				season: self season id
				episode: self id
				searchString: self season name ]
		ifNil: [ rarbg := TorrentApi new getShow: self tpbString ].
	^ rarbg
]

{ #category : #torrents }
PirateEpisode >> getTorrents [
	| t tpb sem kat err extra rarbg |
	t := OrderedCollection new.
	err := OrderedCollection new.
	sem := Semaphore new.
	[ 
	[ rarbg := self getRarbgTorrents ]
		on: Error
		do: [ :ex | err add: ex ].
	sem signal ] fork.
	[ 
	[ extra := self getExtraTorrents ]
		on: Error
		do: [ :ex | err add: ex ].
	sem signal ] fork.
	[ 
	tpb := nil.	"PirateRobot new getShow: self tpbString."
	sem signal ] fork.
	[ 
	[ kat := self getKickassTorrents ]
		on: Error
		do: [ :ex | err add: ex ].
	sem signal ] fork.
	sem wait wait wait wait.	"	Transcript crShow: tpb.
	Transcript crShow: extra.
	Transcript crShow: kat.
	Transcript crShow: rarbg."
	err
		ifNotEmpty: [ 
			Error signal: err first printString.
			Transcript crShow: 'Error on getTorrents: ' , err printString ].
	tpb ifNotNil: [ t addAll: tpb ].
	extra ifNotNil: [ t addAll: extra ].
	rarbg ifNotNil: [ t addAll: rarbg ].
	kat ifNotNil: [ t addAll: kat ].
	#('1080p' 'French' 'spanish' 'subtitulado' 'x265' 'vostfr')
		do: [ :word | t := t reject: [ :each | each first includesSubstring: word caseSensitive: false ] ].
	^ t
]

{ #category : #torrents }
PirateEpisode >> getTorrents_leftovers [
	| t tpb sem kickass err  |
	t := OrderedCollection new.
	err := OrderedCollection new.
	sem := Semaphore new.
	"------------------------------------------Kickass torrent. Dead in July 2016"
	self season show kat
		ifNotNil: [ 
			[ 
			[ kickass := self getKickassTorrents ]
				on: Error
				do: [ :ex | err add: ex ].
			sem signal ] fork ]
		ifNil: [ 
			[ 
			[ kickass := KickassRobot new getShow: self tpbString ]
				on: Error
				do: [ :ex | err add: ex ].
			sem signal ] fork ].
	"---------------------------------------------------------------------"
	[ 
	tpb := nil.	"PirateRobot new getShow: self tpbString."
	sem signal ] fork.

]

{ #category : #torrents }
PirateEpisode >> id: aString [
	id := aString.
	self setFullId
]

{ #category : #'as yet unclassified' }
PirateEpisode >> needsSubtitle [
	self season show archived
		ifTrue: [ ^ false ].
	^ super hasSubtitle not
]

{ #category : #torrents }
PirateEpisode >> needsTorrent [
	self season show archived
		ifTrue: [ ^ false ].
	^ super needsTorrent
]

{ #category : #'as yet unclassified' }
PirateEpisode >> resetFileAndStatus [
	Transcript show: 'hej'.
	torrent := nil.
	falseTorrents := nil.
	viewed := false.
	Transcript show: ' då! '
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
	season := aSeason.
	self setFullId
]

{ #category : #torrents }
PirateEpisode >> setFullId [
	(season isNotNil and: [ id isNotNil ])
		ifTrue: [ fullId := season fullId , 'E' , self id ]
]

{ #category : #subtitles }
PirateEpisode >> subtitlesByHash: lang [
	| os hash subs fileSize aSeason anEpisode |
	self videoFile ifNil: [ ^ #() ].
	hash := self videoFile videoHash.
	hash ifNil: [ ^ #() ].
	fileSize := self videoFile fileSize.
	aSeason := self season id asInteger.
	anEpisode := self id asInteger.
	os := OpenSubClient current.
	subs := os
		searchSubtitlesForHash: hash
		size: fileSize
		season: aSeason
		episode: anEpisode
		lang: lang.
	^ subs
]

{ #category : #subtitles }
PirateEpisode >> subtitlesByTitle: lang [
	| os subs aName aSeason anEpisode |
	aName := self season name.
	aSeason := self season id asInteger.
	anEpisode := self id asInteger.
	os := OpenSubClient current.
	subs := os
		searchSubtitlesByname: aName
		season: aSeason
		episode: anEpisode
		lang: lang.
	^ subs
]
