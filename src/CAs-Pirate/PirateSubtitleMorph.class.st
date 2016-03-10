Class {
	#name : #PirateSubtitleMorph,
	#superclass : #PirateRootMorph,
	#instVars : [
		'model',
		'listEn',
		'listIndexEn',
		'listSwe',
		'listIndexSwe',
		'releaseName'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'initialize-release' }
PirateSubtitleMorph >> addControls [
	| r lst btnPanel |
	self addMorphBack: (StringMorph contents: 'Title: ').
	lst := PluggableMultiColumnListMorph
		on: self
		list: #listEn
		selected: #listIndexEn
		changeSelected: #listIndexEn:
		menu: #listMenu:.
	lst doubleClickSelector: #dblClick.
	lst wrapSelector: #getSubColumn:.
	lst color: Color white.
	lst extent: 500 @ 130.
	self addMorphBack: lst.
	lst := PluggableMultiColumnListMorph
		on: self
		list: #listSwe
		selected: #listIndexSwe
		changeSelected: #listIndexSwe:
		menu: #listMenu:.
	lst doubleClickSelector: #dblClick.
	lst wrapSelector: #getSubColumn:.
	lst color: Color white.
	lst extent: 500 @ 130.
	self addMorphBack: lst.
	btnPanel := self newRow.
	btnPanel
		color: Color transparent;
		borderWidth: 0;
		layoutInset: 2;
		wrapCentering: #center;
		cellPositioning: #topCenter;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		extent: 5 @ 5.
	self addMorphBack: btnPanel.
	btnPanel addMorphBack: (self newButton: 'Refresh.' do: #getSubtitles).
	btnPanel addMorphBack: (self newButton: 'Download' do: #setSub).
	self addMorphBack: (self newButton: 'temp' do: #temp).	"------------------------------------"
	r := AlignmentMorph newRow
		color: Color transparent;
		borderWidth: 0;
		layoutInset: 0.
	r
		wrapCentering: #center;
		cellPositioning: #topCenter;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		extent: 5 @ 5.
	r addMorphBack: (self newButton: 'Close' do: #delete).
	r addTransparentSpacerOfSize: 8 @ 0.
	self addMorphFront: r
]

{ #category : #'model access' }
PirateSubtitleMorph >> dblClick [
	self setSub.
	self delete.
]

{ #category : #'model access' }
PirateSubtitleMorph >> downloadSub: subDict [
	| os text |
	Cursor wait
		showWhile: [ 
			os := OpenSubClient current.
			text := os downloadSubtitle: subDict.
			model videoFile setSub: text ]
]

{ #category : #'model access' }
PirateSubtitleMorph >> findCurrentSub [

]

{ #category : #'as yet unclassified' }
PirateSubtitleMorph >> getSubColumn: sub [

	^ {(sub at: #MovieName).
	((sub at: #SeriesSeason) , '->' , (sub at: #SeriesEpisode)).
	(sub at: #SubRating).
	(sub at: #SubDownloadsCnt).
	((sub at: #SubHearingImpaired) = '1'
		ifTrue: [ 'HI' ]
		ifFalse: [ '-' ]).
	(sub at: #MatchedBy).
	(self matchesRelease: sub)}
]

{ #category : #'model access' }
PirateSubtitleMorph >> getSubtitles [
	model ifNil: [ ^ self ].
	Cursor wait
		showWhile: [ 
			listEn := model subtitles: 'eng'.
			listEn := listEn.
			self changed: #listEn.
			listIndexEn := 0.
			listSwe := model subtitles: 'swe'.
			listSwe := listSwe.
			self changed: #listSwe.
			listIndexSwe := 0 ]
]

{ #category : #'model access' }
PirateSubtitleMorph >> getSubtitlesOld [
	| allSubs |
	model
		ifNil: [^ self].
	"["
	allSubs := model getSubtitles.self halt.
	listEn := allSubs
				reject: [:i | (i at: 1)
						includesSubstring: 'swesub'
						caseSensitive: false].
	self changed: #listEn.
	listIndexEn := 0.
	listSwe := allSubs
				select: [:i | (i at: 1)
						includesSubstring: 'swesub'
						caseSensitive: false].
	self changed: #listSwe.
	listIndexSwe := 0.
	WorldState
		addDeferredUIMessage: [self findCurrentSub
			"] fork"]
]

{ #category : #'model access' }
PirateSubtitleMorph >> listEn [
	listEn ifNil: [ ^ nil ].
	listEn isArray
		ifTrue: [ ^ listEn ]
		ifFalse: [ ^ nil ]
]

{ #category : #'model access' }
PirateSubtitleMorph >> listIndexEn [
	^ listIndexEn
		ifNil: [listIndexEn := 0]
]

{ #category : #'model access' }
PirateSubtitleMorph >> listIndexEn: aSmallInteger [ 
self logCr: 'listIndexEn:',aSmallInteger printString.
	listIndexEn := aSmallInteger.
	self changed: #listIndexEn.
	listIndexSwe:=0.
	self changed: #listIndexSwe.
]

{ #category : #'model access' }
PirateSubtitleMorph >> listIndexSwe [
	^ listIndexSwe
		ifNil: [listIndexSwe := 0]
]

{ #category : #'model access' }
PirateSubtitleMorph >> listIndexSwe: aSmallInteger [ 
	listIndexSwe:=aSmallInteger.
	self changed: #listIndexSwe.
	listIndexEn := 0.
	self changed: #listIndexEn.

]

{ #category : #'model access' }
PirateSubtitleMorph >> listSwe [
	listSwe
		ifNil: [^ nil].
	listSwe isArray
		ifTrue: [^listSwe]
		ifFalse: [^ nil].
]

{ #category : #'as yet unclassified' }
PirateSubtitleMorph >> matchesRelease: sub [
	| rel |
	rel := (sub at: #MovieReleaseName) copyReplaceAll: '.' with: ' '.
	^ (releaseName includesSubstring: rel)
		ifTrue: [ 'rel' ]
		ifFalse: [ '-' ]
]

{ #category : #'model access' }
PirateSubtitleMorph >> model: anEpisode [
	model := anEpisode.
	releaseName := model torrent name.
	self getSubtitles
]

{ #category : #'model access' }
PirateSubtitleMorph >> setSub [
	| t |
	self listIndexEn > 0
		ifTrue: [ t := listEn at: listIndexEn ].
	self listIndexSwe > 0
		ifTrue: [ t := listSwe at: listIndexSwe ].
	t ifNotNil: [ self downloadSub: t ]
]

{ #category : #'as yet unclassified' }
PirateSubtitleMorph >> temp [
	| t |
	t := listEn at: listIndexEn.
	t inspect
]
