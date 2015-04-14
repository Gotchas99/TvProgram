Class {
	#name : #Config,
	#superclass : #Object,
	#instVars : [
		'host',
		'port',
		'torrentFolder',
		'vlcFolder'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
Config class >> current [
	Current isNil
		ifTrue: [Current := self new]. 
	^ Current
]

{ #category : #'as yet unclassified' }
Config class >> new [
	^super new initialize
]

{ #category : #'as yet unclassified' }
Config >> host [
	^host
]

{ #category : #'as yet unclassified' }
Config >> initialize [ 
	host := 'localhost'.
	port := 9091.
	vlcFolder := 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe'.
	torrentFolder := 'F:\Zetum\Downloads\Torrent\tv_program\'.
]

{ #category : #'as yet unclassified' }
Config >> initializeFromFile [
	| stream if |
	stream := FileStream readOnlyFileNamed: 'TVconfig.ini'.
	if := INIFile readFrom: stream.
	host := if section: #Global at: #Host ifAbsent: [ 'localhost' ].
	port := if section: #Global at: #Port ifAbsent: [ 'l9091' ].
	vlcFolder := if section: #Global at: #VlcFolder ifAbsent: [ 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe' ].
	torrentFolder := if section: #Global at: #TorrentFolder ifAbsent: [ 'F:\Zetum\Downloads\Torrent\tv_program\' ].
	Transcript crShow: self name , ' initializedFromFile' .

]

{ #category : #'as yet unclassified' }
Config >> port [
	^port
]

{ #category : #'as yet unclassified' }
Config >> printOn: aStream [
	aStream
		nextPutAll:
			'a TV-config (' , 'host:' , host , ' port:' , port , ' torrentFolder:' , torrentFolder , ' vlcFolder:' , vlcFolder
				, ') '
]

{ #category : #'as yet unclassified' }
Config >> torrentFolder [
	torrentFolder isNil 
		ifTrue: [self initialize].
	^ torrentFolder.
]

{ #category : #'as yet unclassified' }
Config >> vlcFolder [
	^vlcFolder
]
