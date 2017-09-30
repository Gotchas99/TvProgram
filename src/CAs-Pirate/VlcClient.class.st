Class {
	#name : #VlcClient,
	#superclass : #Object,
	#instVars : [
		'state',
		'stream',
		'pos',
		'proc'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Pirate-Services'
}

{ #category : #'as yet unclassified' }
VlcClient class >> info [
"
get_time : returns position in secondscategory 
seek X : positions to X sec"
]

{ #category : #'initialize - release' }
VlcClient >> closeStream [
	<FIXME>

	(Delay forSeconds: 1) wait.
	stream
		ifNotNil: [ stream destroy.
			stream := nil ]
]

{ #category : #'initialize - release' }
VlcClient >> initialize [
	super initialize.
	state := 'Play'.
	pos := 0
]

{ #category : #testing }
VlcClient >> isRunning [
	^ (state = 'End') not
]

{ #category : #'initialize - release' }
VlcClient >> old [
	self 
		deprecated: 'Use play: instead'
		on: 	'25 September 2017' 
		in: 'Pharo-6.0-60510-'.
	^ self closeStream
]

{ #category : #'initialize - release' }
VlcClient >> openStream [
	<FIXME>
	self closeStream.
	[ stream isNil and: [ proc isNotNil ] ]
		whileTrue: [ (Delay forSeconds: 1) wait.
			[ stream := SocketStream openConnectionToHost: #[127 0 0 1] port: 9092 timeout: 3 ]
				on: Error
				do: [ :exception | 
					WorldState
						addDeferredUIMessage: [ Transcript
								crShow: 'Exception on Connect to VLC';
								crShow: exception description ] ] ].
	stream noTimeout
]

{ #category : #old }
VlcClient >> play: aFilename [
	| player args proc |
	player := Config current vlcFolder.
	args := ' --fullscreen --extraintf rc -I qt --rc-host 127.0.0.1:9092 "' , aFilename , '" '.
	proc := OSProcess command: player , args.
	proc ifNil: [ ^ self ].
	state := 'Play'.
	self openStream.
	self startListener.
	self startAskingPos.
	^ proc
]

{ #category : #action }
VlcClient >> play: aFilename atPos: aPosition [
	| player args  |
	player := Config current vlcFolder.
	args := ' --fullscreen --extraintf rc -I qt --rc-host 127.0.0.1:9092 --no-playlist-autostart --play-and-exit "'
		, aFilename , '" '.
	proc := OSProcess command: player , args.
	proc ifNil: [ ^ self ].
	state := 'Play'.
	self openStream.
	self sendCommand: 'seek ' , aPosition printString.
	self startListener.
	self startAskingPos.
	self sendCommand: 'play'.
	^ proc
]

{ #category : #old }
VlcClient >> playOld: aFilename [ 
	self 
		deprecated: 'Use play: instead'
		on: 	'25 September 2017' 
		in: 'Pharo-6.0-60510-'.
	^ self play: aFilename 
]

{ #category : #private }
VlcClient >> processLine: aLine [
	| tok line |
	"WorldState
		addDeferredUIMessage: [ 
			Transcript
				show: 'Got line:' , aLine;
				cr ]."
	(aLine beginsWith: '>')
		ifTrue: [ line := aLine allButFirst ]
		ifFalse: [ line := aLine ].
	line := line trimmed.
	(line includesSubstring: 'X_state:')
		ifTrue: [ 
			tok := (line findTokens: ' ') last.
			tok = ')'
				ifFalse: [ state := tok ] ].
	line isAllDigits
		ifTrue: [ pos := line asInteger ]
]

{ #category : #private }
VlcClient >> sendCommand: cmd [
	stream ifNotNil: [ :s|s sendCommand: cmd ]
]

{ #category : #'process creation' }
VlcClient >> startAskingPos [
	<FIXME>
	| d |
	d := Delay forSeconds: 1.
	[ [ [ stream isNotNil and: [stream isConnected] ]
		whileTrue: [ self sendCommand: 'get_time'.
			d wait ] ]
		on: ConnectionTimedOut
		do: [ self crLog: 'ask pos. stream not connected' ] ]
		forkAt: Processor userBackgroundPriority
]

{ #category : #'process creation' }
VlcClient >> startListener [
	<FIXME>
	| line |
	[ [ [ line := stream nextLine.
	self processLine: line ] repeat ]
		on: ConnectionClosed
		do: [ self crLog: 'socket closed'.
			self closeStream.
			self triggerEvent: #stoppedAt: with: pos ] ] forkAt: Processor userBackgroundPriority
]
