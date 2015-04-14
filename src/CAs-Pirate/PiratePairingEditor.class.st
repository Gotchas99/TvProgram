Class {
	#name : #PiratePairingEditor,
	#superclass : #Object,
	#instVars : [
		'videos',
		'files',
		'torrent',
		'show',
		'selectionIndexFiles',
		'selectionIndexVideos'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'as yet unclassified' }
PiratePairingEditor >> canConnect [
	^(selectionIndexVideos > 0) and: [ selectionIndexFiles > 0 ]
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> connectButtonClick [
	self selectedVideo videoFile: (self selectedFile ).
	self selectedFile video: (self selectedVideo ).
	
	self changed: #listVideos.
	self changed: #listFiles.
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> getFileName: aVideoFile [ 	
	^aVideoFile videoFilename.
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> getVideoName: anEpisode [
	^anEpisode fullId.
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> initialize [
	super initialize.
	self selectionIndexFiles: 0.
	self selectionIndexVideos: 0
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> inspectVideo [
	self selectedVideo explore.
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> listFiles [
	files := self torrent videoFiles.
	^ files select: [ :vf | vf video isNil ].

]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> listVideos [
	| seasons available |
	seasons := self show seasons.
	videos := OrderedCollection new.
	seasons do: [ :s | videos addAll: s episodes ].
	available := videos select: [ :e | e videoFile isNil ].
	^ available
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> open [
	| builder content |
	builder := UITheme builder.
	content := builder
		newColumn:
			{((builder
				newRow:
					{((builder
						newListFor: self
						list: #listVideos
						selected: #selectionIndexVideos
						changeSelected: #selectionIndexVideos:
						help: 'This is a list')
						minWidth: 190;
						wrapSelector: #getVideoName:).
					((builder
						newListFor: self
						list: #listFiles
						selected: #selectionIndexFiles
						changeSelected: #selectionIndexFiles:
						help: 'This is a list')
						minWidth: 190;
						wrapSelector: #getFileName:)}) vResizing: #spaceFill).	"			(builder
				newListFor: self
				list: #contacts
				selected: #contactSelectedIndex
				changeSelected: #contactSelectedIndex:
				help: 'contacts')."
			(builder
				newRow:
					{(builder
						newButtonFor: self
						action: #connectButtonClick
						getEnabled: #canConnect
						label: 'Connect'
						help: 'Create a new contact').
					(builder
						newButtonFor: self
						action: #removeButtonClick
						getEnabled: nil
						label: 'Remove'
						help: 'Remove selected contact').
					(builder
						newButtonFor: self
						action: #inspectVideo
						getEnabled: nil
						label: 'Inspect Video'
						help: 'Remove selected contact').
					(builder
						newButtonFor: self
						action: #inspectFile
						getEnabled: nil
						label: 'Inspect File'
						help: 'Remove selected contact')	"					(builder
						newButtonFor: self
						action: #editButtonClick
						getEnabled: #hasSelectedContact
						label: 'Edit'
						help: 'Edit selected contact')"})}.
	(content openInWindowLabeled: 'Contacts') extent: 600 @ 500
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> selectedFile [
	"Answer the currently selected item or nil if none."

	^self selectionIndexFiles = 0
		ifTrue: [nil]
		ifFalse: [self listFiles at: self selectionIndexFiles]
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> selectedVideo [
	"Answer the currently selected item or nil if none."

	^self selectionIndexVideos  = 0
		ifTrue: [nil]
		ifFalse: [self listVideos at: self selectionIndexVideos]
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> selectionIndexFiles [
	"Answer the value of selectionIndex"

	^ selectionIndexFiles
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> selectionIndexFiles: anObject [
	"Set the value of selectionIndex"

	selectionIndexFiles := anObject.
	self changed: #selectionIndexFiles.
	self changed: #canConnect.
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> selectionIndexVideos [
	"Answer the value of selectionIndex"

	^ selectionIndexVideos
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> selectionIndexVideos: anObject [
	"Set the value of selectionIndex"

	selectionIndexVideos := anObject.
	self changed: #selectionIndexVideos.
	self changed: #canConnect.
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> show [
	^PirateShow at: 'Coupling'
]

{ #category : #'as yet unclassified' }
PiratePairingEditor >> torrent [
	| t |
	t:= PirateTorrent at: '959b3ac4196f2eaa3102abb52bc3d81742e74734'.
	^t
]
