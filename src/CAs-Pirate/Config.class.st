Class {
	#name : #Config,
	#superclass : #Object,
	#instVars : [
		'host',
		'port',
		'torrentFolder',
		'vlcFolder',
		'episodesAhead'
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

{ #category : #accessing }
Config >> episodesAhead [
	^ episodesAhead ifNil: [ episodesAhead := 10 ]
]

{ #category : #accessing }
Config >> host [
	^host
]

{ #category : #initialization }
Config >> initialize [
	episodesAhead := 5.
	host := 'localhost'.
	port := 9091.
	vlcFolder := 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe'.
	torrentFolder := 'F:\Zetum\Downloads\Torrent\tv_program\'
]

{ #category : #initialization }
Config >> initializeFromFile [
	| stream if |
	stream := FileStream readOnlyFileNamed: 'TVconfig.ini'.
	if := INIFile readFrom: stream.
	episodesAhead := (if section: #Global at: #EpisodesAhead ifAbsent: [ '10' ])asInteger .
	host := if section: #Global at: #Host ifAbsent: [ 'localhost' ].
	port := if section: #Global at: #Port ifAbsent: [ '9091' ].
	vlcFolder := if
		section: #Global
		at: #VlcFolder
		ifAbsent: [ 'C:\Program Files (x86)\VideoLAN\VLC\vlc.exe' ].
	torrentFolder := if
		section: #Global
		at: #TorrentFolder
		ifAbsent: [ 'F:\Zetum\Downloads\Torrent\tv_program\' ].
	Transcript crShow: self asString , ' initializedFromFile'
]

{ #category : #accessing }
Config >> port [
	^port
]

{ #category : #printing }
Config >> printOn: aStream [
	aStream
		nextPutAll:
			'a TV-config (', 'episodesAhead:',episodesAhead printString,  ' host:' , host , ' port:' , port , ' torrentFolder:' , torrentFolder
				, ' vlcFolder:' , vlcFolder , ') '
]

{ #category : #accessing }
Config >> torrentFolder [
	torrentFolder isNil 
		ifTrue: [self initialize].
	^ torrentFolder.
]

{ #category : #accessing }
Config >> vlcFolder [
	^vlcFolder
]
