Class {
	#name : #PirateManagerMorph,
	#superclass : #PirateRootMorph,
	#instVars : [
		'list',
		'listIndex',
		'model',
		'listIndex2',
		'model2',
		'model3',
		'listIndex3'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'initialize-release' }
PirateManagerMorph >> addControls [
	| bb r lst lst2 lst3 r1 r2 r3 r1c2 r2c2 r3c2 listboxWidth |
	listboxWidth := 350.
	r1 := self newRow.
	r1c2 := r1 class newColumn.
	r2 := self newRow.
	r2c2 := r1 class newColumn.
	r3 := self newRow.
	r3c2 := r1 class newColumn.
	lst := PluggableMultiColumnListMorph
		on: self
		list: #list
		selected: #listIndex
		changeSelected: #listIndex:.	"	menu: #listMenu:."
	lst doubleClickSelector: #dblClick.
	lst wrapSelector: #getShowText:.
	lst color: Color white.
	lst extent: listboxWidth @ 230.
	r1 addMorphBack: lst.
	r1c2 addMorphBack: (self newButton: 'Add show...' do: #addShow).
	r1c2 addMorphBack: (self newButton: 'Edit info...' do: #editInfo).
	r1c2 addMorphBack: (self newButton: 'Look for new' do: #lookForNew).
	r1c2 addMorphBack: (self newButton: 'Remove seen' do: #removeSeen).
	r1c2 addMorphBack: (self newButton: 'Write to file' do: #writeToFile).
	r1c2 addMorphBack: (self newButton: 'Archive...' do: #archiveShow).
	r1c2 addMorphBack: (self newButton: 'Delete show...' do: #deleteShow).
	r1c2 addMorphBack: (self newButton: 'Refresh' do: #refresh).
	"r1c2 addMorphBack: (self newButton: 'New episodes' do: #newEpisodes)."
	r1c2 addMorphBack: (self newButton: 'Viewables' do: #viewables).
	"r1c2 addMorphBack: (self newButton: 'Needs torrent' do: #needsTorrent)."
	r1c2 addMorphBack: (self newButton: 'Set episodes' do: #setMaxEpisodes).
"	r1c2 addMorphBack: (self newButton: 'Pairing' do: #pairing)."
	r1 addMorphBack: r1c2.
	lst2 := PluggableListMorph
		on: self
		list: #list2
		selected: #listIndex2
		changeSelected: #listIndex2:.
	lst2 doubleClickSelector: #dblClick2.
	lst2 wrapSelector: #getSeasonText:.
	lst2 color: Color white.
	lst2 extent: listboxWidth @ 150.
	r2 addMorphBack: lst2.
	r2c2 addMorphBack: (self newButton: 'Add Season...' do: #addSeason).
	r2 addMorphBack: r2c2.
	lst3 := PluggableMultiColumnListMorph
		on: self
		list: #list3
		selected: #listIndex3
		changeSelected: #listIndex3:
		menu: #listMenu3:.
	lst3 doubleClickSelector: #dblClick3.
	lst3 wrapSelector: #getEpisodeText:.
	lst3 color: Color white.
	lst3 extent: listboxWidth @ 200.
	r3 addMorphBack: lst3.
	r3c2 addMorphBack: (self newButton: 'Inspect' do: #inspectEpisode).
	r3c2 addMorphBack: (self newButton: 'Open' do: #dblClick3).
	r3c2 addMorphBack: (self newButton: 'Add episode' do: #addEpisode).
	r3c2 addMorphBack: (self newButton: 'Add episodes...' do: #addEpisodes).
	r3c2 addMorphBack: (self newButton: 'Remove episode...' do: #removeEpisode).
	r3c2 addMorphBack: (self newButton: 'Play !!' do: #play).
	r := AlignmentMorph newRow
		color: Color transparent;
		borderWidth: 0;
		layoutInset: 0.
	r3c2 addMorphBack: (self newButton: 'Seen' do: #seenEpisode).
	r := AlignmentMorph newRow
		color: Color transparent;
		borderWidth: 0;
		layoutInset: 0.
	r3c2 addMorphBack: (self newButton: 'Add videofile' do: #addVideofile).
	r3c2 addMorphBack: (self newButton: 'Add Torrent' do: #addTorrent).
	r3 addMorphBack: r3c2.
	r
		wrapCentering: #center;
		cellPositioning: #topCenter;
		hResizing: #shrinkWrap;
		vResizing: #shrinkWrap;
		extent: 5 @ 5.
	bb := SimpleButtonMorph new
		target: self;
		borderColor: Color black.
	r
		addMorphBack:
			(self
				wrapperFor:
					(bb
						label: 'Close' translated;
						actionSelector: #delete)).
	r addTransparentSpacerOfSize: 8 @ 0.
	self addMorphBack: r1.
	self addMorphBack: r2.
	self addMorphBack: r3.
	self addMorphFront: r
]

{ #category : #'event handling' }
PirateManagerMorph >> addEpisode [
	listIndex2 = 0
		ifTrue: [ ^ self ].
	model3 addEpisode.
	self changed: #list3.
	self listIndex3: self list3 size.

]

{ #category : #'event handling' }
PirateManagerMorph >> addEpisodes [
	| maxNo |
	listIndex2 > 0
		ifFalse: [ ^ self ].
	maxNo := UIManager default request: 'Max episode number' initialAnswer: '1'.
	maxNo isNil
		ifTrue: [ ^ self ].
	maxNo := maxNo asInteger.
	model3 addEpisodes: maxNo.
	self changed: #list3
]

{ #category : #'event handling' }
PirateManagerMorph >> addEztv [
	| show id |
	listIndex = 0
		ifTrue: [ ^ self ].
	show := self list at: listIndex.
	id := UIManager default request: 'Add EZTV id:' initialAnswer: show eztv printString.
"	id isNil
		ifTrue: [ ^ self ]."
	show eztv: id.
	self changed: #list
]

{ #category : #'event handling' }
PirateManagerMorph >> addImdb [
	| show id |
	listIndex = 0
		ifTrue: [ ^ self ].
	show := self list at: listIndex.
	id := UIManager default request: 'Add IMDB id:' initialAnswer: show imdb printString.
"	id isNil
		ifTrue: [ ^ self ]."
	show imdb: id.
	self changed: #list
]

{ #category : #'event handling' }
PirateManagerMorph >> addSeason [
	model2 addSeason.
	self changed: #list2.
	self listIndex2: self list2 size.
	self dblClick2.
	self changed: #list3
]

{ #category : #'event handling' }
PirateManagerMorph >> addShow [
	| name sh |
	name := UIManager default request: 'Name of new show'.
	name isEmpty
		ifFalse: [ 
			sh := PirateShow new.
			sh name: name.
			self changed: #list.
			self selectShow: name.
			self listIndex2: 0.
			model3 := nil.
			self changed: #list3 ]
]

{ #category : #'event handling' }
PirateManagerMorph >> addTorrent [
	| t mag ep |
	listIndex3 = 0
		ifTrue: [ ^ self ].
	mag := UIManager default request: 'Add torrent (Magnet link):' initialAnswer: '<Magnet link>'.
	mag ifNil: [ ^ self ].
	t := PirateTorrent magnet: mag.
	t ifNil: [ ^ self ].
	ep := model3 episodes at: listIndex3.
	ep
		torrent: t;
		download.
	self changed: #list3.
	self refresh
]

{ #category : #'event handling' }
PirateManagerMorph >> addVideofile [
	| ep file vf |
	listIndex3 = 0
		ifTrue: [ ^ self ].
	file := UITheme current
		chooseFileIn: self
		title: 'Select a video file'
		extensions: nil
		path: PirateTorrent folder
		preview: nil.
	file isNil
		ifTrue: [ ^ self ].
	vf := PirateVideoFile new.
	vf videoFilename: file basename.
	vf folder: file reference parent fullName.
	ep := model3 episodes at: listIndex3.
	ep
		torrent: nil;
		videoFile: vf.
	self changed: #list3
]

{ #category : #'event handling' }
PirateManagerMorph >> archiveShow [
	listIndex > 0
		ifTrue: [ 
			(self confirm: 'Vill du verkligen arkivera programmet?' , String crlfcrlf , (self list at: listIndex) name)
				ifTrue: [ 
					(self list at: listIndex) archived: true.
					self changed: #list.
					listIndex := 0.
					self changed: #listIndex.
					model2 := nil.
					self changed: #list2.
					listIndex2 := 0.
					self changed: #listIndex2.
					model3 := nil.
					self changed: #list3 ] ]
]

{ #category : #'event handling' }
PirateManagerMorph >> dblClick [
	"self inform: 'dubbelclickade'."

	listIndex > 0
		ifTrue: [ 
			model2 := self list at: listIndex.
			self changed: #list2.
			self listIndex2: self list2 size ]
]

{ #category : #'event handling' }
PirateManagerMorph >> dblClick2 [
	"self inform: 'dubbelclickade'."
	listIndex2 > 0
		ifTrue: [model3 := model2 seasons at: listIndex2.
			self changed: #list3.		
			listIndex3 := 1.
			self changed: #listIndex3.]
]

{ #category : #'event handling' }
PirateManagerMorph >> dblClick3 [
	| m ep |
	listIndex3 > 0
		ifTrue: [m := PirateEpisodeMorph new.
			ep := model3 episodes at: listIndex3.
			m model: ep.
			m openInWorld.
			]
]

{ #category : #'event handling' }
PirateManagerMorph >> deleteShow [
	listIndex > 0
		ifTrue: [ 
			(self confirm: 'Vill du verkligen ta bort programmet?' , String crlfcrlf , (self list at: listIndex) name)
				ifTrue: [ 
					PirateShow removeShow: (self list at: listIndex).
					self changed: #list.
					listIndex := 0.
					self changed: #listIndex.
					model2 := nil.
					self changed: #list2.
					listIndex2 := 0.
					self changed: #listIndex2.
					model3 := nil.
					self changed: #list3 ] ]
]

{ #category : #'event handling' }
PirateManagerMorph >> editInfo [
	| show  |
	listIndex = 0
		ifTrue: [ ^ self ].
	show := self list at: listIndex.
	PirateShowInfo new
		show: show; 
		openWithSpec.
	self changed: #list
]

{ #category : #'model access' }
PirateManagerMorph >> getEpisodeText: anEpisode [
"self halt."

	^ {(anEpisode id).
	(anEpisode found
		ifTrue: [ 'found' ]
		ifFalse: [ ' - ' ]).
	(anEpisode newFound
		ifTrue: [ 'new' ]
		ifFalse: [ ' - ' ]).	"(anEpisode isDownloaded)ifTrue:['downloaded']ifFalse:[
		anEpisode torrent isNil ifTrue: [' - '] ifFalse: ['started']]."
	(anEpisode status).
	(anEpisode statusCode printString).
	(anEpisode isViewable 
		ifTrue: [ 'viewable' ]
		ifFalse: [ ' - ' ]).
	(anEpisode hasSubtitle
		ifTrue: [ 'subs' ]
		ifFalse: [ ' - ' ]).
	(anEpisode isViewed
		ifTrue: [ 'seen' ]
		ifFalse: [ ' - ' ])}
]

{ #category : #'model access' }
PirateManagerMorph >> getSeasonText: aSeason [
	^aSeason id.
]

{ #category : #'model access' }
PirateManagerMorph >> getShowText: aShow [
	^{
		aShow name.
		(aShow newEpisodeCount) > 0 ifTrue:['new'] ifFalse:['-'].
		(aShow imdb) isNil not ifTrue:['imdb'] ifFalse:['-'].
		(aShow tmdb) isNil not ifTrue:['tmdb'] ifFalse:['-'].
		(aShow kat) isNil not ifTrue:['kat'] ifFalse:['-'].
		(aShow notSeenCount) > 0 ifTrue:['viewable'] ifFalse:['-'].
	}
]

{ #category : #'initialize-release' }
PirateManagerMorph >> initialize [
	model := PirateShow shows.
	super initialize.

]

{ #category : #'event handling' }
PirateManagerMorph >> inspectEpisode [
	| ep |
	listIndex3 = 0
		ifTrue: [ ^ self ].
	ep := model3 episodes at: listIndex3.
	ep inspect
]

{ #category : #'model access' }
PirateManagerMorph >> list [
	model ifNil: [ ^ nil ].	
	^ model reject: [ :item | item archived ]
]

{ #category : #'model access' }
PirateManagerMorph >> list2 [
	model2
		ifNil: [^ nil].
	^model2 seasons
]

{ #category : #'model access' }
PirateManagerMorph >> list3 [
	model3 ifNil: [ ^ nil ].
	^ model3 episodes
]

{ #category : #'model access' }
PirateManagerMorph >> listIndex [
	^listIndex ifNil: [listIndex:=0].
]

{ #category : #'model access' }
PirateManagerMorph >> listIndex2 [
	^ listIndex2
		ifNil: [listIndex2 := 0]
]

{ #category : #'model access' }
PirateManagerMorph >> listIndex2: anInteger [
	listIndex2 := anInteger min: self list2 size.
	self changed: #listIndex2.
	self dblClick2
]

{ #category : #'model access' }
PirateManagerMorph >> listIndex3 [
	^ listIndex3
		ifNil: [listIndex3 := 0]
]

{ #category : #'model access' }
PirateManagerMorph >> listIndex3: anInteger [
	listIndex3 := anInteger min: self list3 size.
	self changed: #listIndex3
]

{ #category : #'model access' }
PirateManagerMorph >> listIndex: anInteger [
	listIndex := anInteger.
	self changed: #listIndex.
	self dblClick
]

{ #category : #'event handling' }
PirateManagerMorph >> lookForNew [
	[ 
	PirateShow shows do: [ :sh | sh lookForAll ].
	PirateShow writeToFile.
	Transcript
		show: '-------------';
		cr.
	self changed: #list ] fork
]

{ #category : #'event handling' }
PirateManagerMorph >> newEpisodes [
	| m ep |
	m := PirateNewMorph new.
	m model: model.
	m openInWorld.
]

{ #category : #'event handling' }
PirateManagerMorph >> pairing [
	PiratePairingEditor new open.
]

{ #category : #'event handling' }
PirateManagerMorph >> play [
	| ep |
	listIndex3 > 0
		ifTrue: [
			ep := model3 episodes at: listIndex3.
			ep isDownloaded ifTrue: [
				ep play.
				(self confirm: 'Did you see the entire show?') ifTrue: [
					[ep viewed.				
					self changed: #list1.
					self changed: #list3 ] forkAt: Processor userBackgroundPriority .		
				].
"				(self confirm: 'Subtitles OK?') ifTrue: ["
"					ep viewed."	"]."
			].
		]
]

{ #category : #'event handling' }
PirateManagerMorph >> refresh [
	Cursor wait
		showWhile: [ 
			PirateTorrent updateStatuses.
			PirateVideo getVideoFiles.	"			
			PirateApp validateState."
			self changed: #list.
			self changed: #list3 ]
]

{ #category : #'event handling' }
PirateManagerMorph >> removeEpisode [
	| ep |
	listIndex3 = 0
		ifTrue: [ ^ self ].
	ep := model3 episodes at: listIndex3.
	(self confirm: 'Vill du verkligen ta bort episoden?' , String crlfcrlf , ep name)
		ifTrue: [ 
			ep delete.
			self changed: #list3.
			self listIndex3: 0 ]
]

{ #category : #'event handling' }
PirateManagerMorph >> removeSeen [
	[
		self refresh.
		PirateTorrent cleanUpSeedingDoneOnce.
		Transcript show: '-------------'; cr.
	] forkAt: Processor userBackgroundPriority .		
	
]

{ #category : #'event handling' }
PirateManagerMorph >> seenEpisode [
	| ep |
	listIndex3 > 0
		ifTrue: [
			ep := model3 episodes at: listIndex3.
			ep isViewed 
				ifTrue: [ep unViewed ]
				ifFalse: [ep viewed].
			self changed: #list1.
			self changed: #list3			
		]
]

{ #category : #'event handling' }
PirateManagerMorph >> selectShow: aName [
	| sh lst |
	lst := self list.
	1 to: lst size do: [ :i | 
		sh := lst at: i.
		aName = sh name
			ifTrue: [ 
				self listIndex: i.
				^ self ] ]
]

{ #category : #'event handling' }
PirateManagerMorph >> setMaxEpisodes [
	| show |
	listIndex = 0
		ifTrue: [ ^ self ].
	show := self list at: listIndex.
	show imdb isNil
		ifTrue: [ UIManager default alert: 'Must have imdb id to do this' ]
		ifFalse: [ 
			show setEpisodesFromTmdb.
			self changed: #list.
			self changed: #list2.
			self changed: #list3 ]
]

{ #category : #'stepping and presenter' }
PirateManagerMorph >> step [
	| |
"	t := [ self refresh ] timeToRun."
"	Transcript crShow: 'step... time: ' , t printString"
]

{ #category : #'stepping and presenter' }
PirateManagerMorph >> stepTime [
	^5000
]

{ #category : #'event handling' }
PirateManagerMorph >> test [
	| ep magnet t |
	listIndex3 = 0
		ifTrue: [ ^ self ].
	ep := model3 episodes at: listIndex3.
	magnet := UIManager default request: 'Magnet'.
	magnet = ''
		ifTrue: [ ^ self ].
	t := PirateTorrent magnet: magnet.
	ep
		torrent: t;
		download
]

{ #category : #'event handling' }
PirateManagerMorph >> testDeleteSubtitles [
	| m ep |
	listIndex3 > 0
		ifTrue: [
			ep := model3 episodes at: listIndex3.
			ep deleteSubtitles.
		]
]

{ #category : #'event handling' }
PirateManagerMorph >> viewables [
	| m ep |
	m := PirateViewableMorph new.
	m model: model.
	m openInWorld.
]

{ #category : #'event handling' }
PirateManagerMorph >> writeToFile [
	Cursor wait showWhile: [PirateApp writeToNewFile].
	^self 
]
