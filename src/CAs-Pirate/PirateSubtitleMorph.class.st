Class {
	#name : #PirateSubtitleMorph,
	#superclass : #BlocketRootMorph,
	#instVars : [
		'model',
		'listEn',
		'listIndexEn',
		'listSwe',
		'listIndexSwe'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'as yet unclassified' }
PirateSubtitleMorph >> addControls [
	| r lst btnPanel |
	self addMorphBack: (StringMorph contents: 'Title: ').	"self
	addMorph: (PluggableTextMorph
	on: nil
	text: #getTitle
	accept: #setTitle)."
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
	| os |
	Cursor wait showWhile: [os := OpenSubClient current.
		os login.
		os downloadSubtitle: subDict fileName: (model videoFile fullVideoFilename ).
		os logout.]
]

{ #category : #'model access' }
PirateSubtitleMorph >> findCurrentSub [

]

{ #category : #'as yet unclassified' }
PirateSubtitleMorph >> getSubColumn: sub [
	^ {sub at: #MovieName.
		(sub at: #SeriesSeason) , '->',
		(sub at: #SeriesEpisode).
		sub at: #SubRating.
		sub at: #SubDownloadsCnt.
		(sub at: #SubHearingImpaired) = '1'
			ifTrue:['HI']
			ifFalse:['-'].
		sub at: #MatchedBy	
		}
]

{ #category : #'model access' }
PirateSubtitleMorph >> getSubtitles [
	| |
	model
		ifNil: [^ self].
	Cursor wait showWhile: [
		listEn := model subtitles: 'eng'.	
		listEn := listEn .
		self changed: #listEn.
		listIndexEn := 0.

		listSwe := model subtitles: 'swe'.
		listSwe := listSwe .
		self changed: #listSwe.
		listIndexSwe := 0.
	].
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
	listEn ifNil: [^ nil].
	listEn isArray 
		ifTrue: [^ listEn]
		ifFalse: [^ nil].
		"collect: [:f | listEn
				collect: [:i | i at: f]]"
]

{ #category : #'model access' }
PirateSubtitleMorph >> listIndexEn [
	^ listIndexEn
		ifNil: [listIndexEn := 0]
]

{ #category : #'model access' }
PirateSubtitleMorph >> listIndexEn: aSmallInteger [ 
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

{ #category : #'model access' }
PirateSubtitleMorph >> model: anEpisode [ 
	model := anEpisode.
	self getSubtitles
]

{ #category : #'model access' }
PirateSubtitleMorph >> setSub [
	| t |
	self listIndexEn > 0
		ifTrue: [t := listEn at: listIndexEn].
	self listIndexSwe > 0
		ifTrue: [t := listSwe at: listIndexSwe].
	t isNil
		ifFalse: [
			self downloadSub: t.
			model setSub: t]
]

{ #category : #'as yet unclassified' }
PirateSubtitleMorph >> temp [
	| out err desc args proc |
	self halt.
	out := FileStream forceNewFileNamed: '/tmp/deleteMe.out'.
	err := FileStream forceNewFileNamed: '/tmp/deleteMe.err'.
	desc := Array
				with: nil
				with: out
				with: err.
	args := Array
				with: '--fullscreen'
				with: '/media/cm1store/Torrent/Girls.S01E01.HDTV.x264-ASAP.mp4'.
	proc := UnixProcess
				forkJob: '/usr/bin/vlc'
				arguments: args
				environment: nil
				descriptors: desc.
	proc ifNil: [UnixProcess noAccessorAvailable].
	[proc isComplete] whileFalse:
		[(Delay forMilliseconds: 200) wait.].
	out close.
	err close.
	self inform: 'klart!!'.
	^ proc
"	^ self"
]
