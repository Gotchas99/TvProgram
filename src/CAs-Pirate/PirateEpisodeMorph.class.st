Class {
	#name : #PirateEpisodeMorph,
	#superclass : #BlocketRootMorph,
	#instVars : [
		'model',
		'allTorrents',
		'torrents',
		'listIndex',
		'torrentsSwe',
		'listIndexSwe',
		'listIndexInvalids',
		'listEztv',
		'listEztvIndex'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #initialization }
PirateEpisodeMorph >> addControls [
	| r lst btnPanel |
	self addMorphBack: (StringMorph contents: 'Title: ').	"self
	addMorph: (PluggableTextMorph
	on: nil
	text: #getTitle
	accept: #setTitle)."
	lst := PluggableMultiColumnListMorph
		on: self
			list: #list
			selected: #listIndex
			changeSelected: #listIndex:.
	lst doubleClickSelector: #dblClick;
		wrapSelector: #getTorrentText:;
		color: Color white;
		extent: 500 @ 130.	"		menu: #listMenu:."
	self addMorphBack: lst.
	lst := PluggableMultiColumnListMorph
		on: self
		list: #listSwe
		selected: #listIndexSwe
		changeSelected: #listIndexSwe:.	"		menu: #listMenu:."
	lst doubleClickSelector: #dblClick.
	lst wrapSelector: #getTorrentText:.
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
	btnPanel addMorphBack: (self newButton: 'Refresh.' do: #refreshTorrents).
	btnPanel addMorphBack: (self newButton: 'Eztv' do: #eztvTorrents).
	btnPanel addMorphBack: (self newButton: 'Download' do: #download).
	btnPanel addMorphBack: (self newButton: 'Remove files' do: #removeFiles).
	btnPanel addMorphBack: (self newButton: 'Set Torrent' do: #setTorrent).
	btnPanel addMorphBack: (self newButton: 'Subtitles...' do: #subtitles).
	btnPanel addMorphBack: (self newButton: 'findTorrent.' do: #findCurrentTorrent).
	btnPanel addMorphBack: (self newButton: 'Invalid Torrent' do: #invalidTorrent).
	lst := PluggableMultiColumnListMorph
		on: self
		list: #listInvalids
		selected: #listIndexInvalids
		changeSelected: #listIndexInvalids:
		menu: #listMenu:.
	lst doubleClickSelector: #dblClickInvalids.
	lst wrapSelector: #getTorrentText:.
	lst color: Color gray.
	lst extent: 500 @ 130.
	self addMorphBack: lst.
	self addMorphBack: (self newButton: 'Remove invalid' do: #removeInvalid).	"------------------------------------"
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

{ #category : #events }
PirateEpisodeMorph >> dblClick [
	self setTorrent.
	self delete.
]

{ #category : #events }
PirateEpisodeMorph >> download [
	model isDownloaded
		ifFalse: [model download]
		ifTrue: [^ self]
]

{ #category : #'dropping/grabbing' }
PirateEpisodeMorph >> dropFiles: anEvent [ 
| |
	Transcript show: 'Dropped files';cr.
	
"	numFiles := anEvent contents.
	1 to: numFiles do: [ :i |
		(stream := FileStream requestDropStream: i) ifNotNil: [
			handler := ExternalDropHandler lookupExternalDropHandler: stream.
			[ handler ifNotNil: [handler handle: stream in: self dropEvent: anEvent ] ]
				ensure: [ stream close ] ] ]."

	^self.
]

{ #category : #events }
PirateEpisodeMorph >> eztvTorrents [
]

{ #category : #events }
PirateEpisodeMorph >> findCurrentTorrent [
	| torrent m |
	torrent := model magnet.
	torrent isEmptyOrNil
		ifTrue: [^ self].
	1
		to: torrents size
		do: [:i | 
			m := torrents at: i.
			torrent
					= (m at: 2)
				ifTrue: [self listIndex: i]].
1
		to: torrentsSwe size
		do: [:i | 
			m := torrentsSwe at: i.
			torrent
					= (m at: 2)
				ifTrue: [self listIndexSwe:i]].

]

{ #category : #'model access' }
PirateEpisodeMorph >> getTorrentText: aTorrent [
	aTorrent class =String ifTrue: [^aTorrent].
	^ {aTorrent at: 1. (aTorrent at: 3) asString. (aTorrent at: 4) asString}
]

{ #category : #events }
PirateEpisodeMorph >> getTorrents [
	| |
	model
		ifNil: [^ self].
	[allTorrents := model torrents.
	torrents :=allTorrents
				reject: [:i | (i at: 1)
						includesSubstring: 'swesub'
						caseSensitive: false].
	self changed: #list.
	listIndex := 0.
	torrentsSwe := allTorrents
				select: [:i | (i at: 1)
						includesSubstring: 'swesub'
						caseSensitive: false].
	self changed: #listSwe.
	listIndexSwe := 0.
	self changed: #listInvalids.
	listIndexInvalids := 0.
	WorldState
		addDeferredUIMessage: [self findCurrentTorrent]] fork
]

{ #category : #initialization }
PirateEpisodeMorph >> initialize [
	model := nil.
	super initialize.
"	self enableDrop: true."
"	self highlightForDrop"
]

{ #category : #events }
PirateEpisodeMorph >> invalidTorrent [
	 | t |
	self listIndex > 0
		ifTrue: [t := torrents at: listIndex].
	self listIndexSwe > 0
		ifTrue: [t := torrentsSwe at: listIndexSwe].
	t isNil
		ifFalse: [model addFalseTorrent: t.
			self getTorrents]
]

{ #category : #'model access' }
PirateEpisodeMorph >> list [
	| |
	torrents
		ifNil: [^ nil].
	torrents isEmpty
		ifTrue: [^ nil].
	
	"^ #(1 3 4 )
		collect: [:f | torrents
				collect: [:i | i at: f]]"
			^torrents
]

{ #category : #'model access' }
PirateEpisodeMorph >> listEztv [
	^listEztv
]

{ #category : #'model access' }
PirateEpisodeMorph >> listEztvIndex [
	^listEztvIndex ifNil: [listEztvIndex := 0]
]

{ #category : #'model access' }
PirateEpisodeMorph >> listEztvIndex: aSmallInteger [
	listEztvIndex := aSmallInteger.
	self changed: #listEztvIndex.
	listIndex := 0.
	self changed: #listIndex
]

{ #category : #'model access' }
PirateEpisodeMorph >> listIndex [
	^ listIndex
		ifNil: [listIndex := 0]
]

{ #category : #'model access' }
PirateEpisodeMorph >> listIndex: aSmallInteger [
	listIndex := aSmallInteger.
	self changed: #listIndex.
	listIndexSwe := 0.
	self changed: #listIndexSwe
]

{ #category : #'model access' }
PirateEpisodeMorph >> listIndexInvalids [
	^ listIndexInvalids
		ifNil: [listIndexInvalids := 0]
]

{ #category : #'model access' }
PirateEpisodeMorph >> listIndexInvalids: aSmallInteger [
	listIndexInvalids := aSmallInteger.
	self changed: #listIndex
]

{ #category : #'model access' }
PirateEpisodeMorph >> listIndexSwe [
	^ listIndexSwe
		ifNil: [listIndexSwe := 0]
]

{ #category : #'model access' }
PirateEpisodeMorph >> listIndexSwe: aSmallInteger [
	listIndexSwe := aSmallInteger.
	self changed: #listIndexSwe.
	listIndex := 0.
	self changed: #listIndex
]

{ #category : #'model access' }
PirateEpisodeMorph >> listInvalids [
	model 
		ifNil: [^ nil].
	model falseTorrents isEmpty
		ifTrue: [^ nil].
	^model falseTorrents
]

{ #category : #'model access' }
PirateEpisodeMorph >> listSwe [
	| |
	torrentsSwe
		ifNil: [^ nil].
	torrentsSwe isEmpty
		ifTrue: [^ nil].

"	^ #(1 3 4 )
		collect: [:f | torrentsSwe
				collect: [:i | i at: f]]."
			^torrentsSwe
]

{ #category : #'model access' }
PirateEpisodeMorph >> model: anEpisode [ 
	model := anEpisode.
	self getTorrents
]

{ #category : #events }
PirateEpisodeMorph >> refreshTorrents [
	model lookForIt. 
	self getTorrents.
]

{ #category : #events }
PirateEpisodeMorph >> removeFiles [

	model isDownloaded
		ifTrue: [model removeTorrentAndData]
		ifFalse: [^ self]
]

{ #category : #events }
PirateEpisodeMorph >> removeInvalid [
	 | t |
	self listIndexInvalids > 0
		ifTrue: [t := model falseTorrents at: listIndexInvalids].
	t isNil
		ifFalse: [model removeFalseTorrent: t.
			self getTorrents]
]

{ #category : #events }
PirateEpisodeMorph >> setTorrent [
	| t |
	self listIndex > 0
		ifTrue: [t := torrents at: listIndex].
	self listIndexSwe > 0
		ifTrue: [t := torrentsSwe at: listIndexSwe].
	t isNil
		ifFalse: [model torrent: t;
				 download.
				self listIndexSwe > 0
					ifTrue: [model setSub: 'dummy'].]
]

{ #category : #events }
PirateEpisodeMorph >> subtitles [
| m |
m:=PirateSubtitleMorph new.

			m model: ( model).
			m openInWorld
]

{ #category : #'dropping/grabbing' }
PirateEpisodeMorph >> wantsDropFiles: anEvent [ 
	^ true
]

{ #category : #'dropping/grabbing' }
PirateEpisodeMorph >> wantsDroppedMorph: aMorph event: anEvent [
	^false
]
