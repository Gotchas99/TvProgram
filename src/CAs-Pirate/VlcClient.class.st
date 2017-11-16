Class {
	#name : #VlcClient,
	#superclass : #Object,
	#instVars : [
		'state',
		'stream',
		'pos',
		'proc',
		'port'
	],
	#classVars : [
		'LastInc'
	],
	#category : #'CAs-Pirate-Services'
}

{ #category : #'as yet unclassified' }
VlcClient class >> info [
"
get_time : returns position in secondscategory 
seek X : positions to X sec"
]

{ #category : #'as yet unclassified' }
VlcClient class >> nextPort [
	| tmp basePort maxNoOfPlayers |
	basePort := 9092.
	maxNoOfPlayers:=8.
	tmp := LastInc ifNil: [ 0 ].
	LastInc := (tmp + 1) \\ maxNoOfPlayers.
	^ basePort + LastInc
]

{ #category : #'initialize - release' }
VlcClient >> closeStream [
	<FIXME>
"	(Delay forSeconds: 1) wait."
	stream
		ifNotNil: [ stream destroy.
			stream := nil ]
]

{ #category : #'initialize - release' }
VlcClient >> initialize [
	super initialize.
	state := 'Play'.
	pos := 0.
	port := self class nextPort .
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
		whileTrue: [ (Delay forMilliseconds: 100) wait.
			[ stream := SocketStream openConnectionToHost: #[127 0 0 1] port: port timeout: 3 ]
				on: Error
				do: [ :exception | 
					WorldState
						addDeferredUIMessage: [ Transcript
								crShow: 'Exception on Connect to VLC';
								crShow: exception description ] ] ].
	stream noTimeout
]

{ #category : #action }
VlcClient >> play: aFilename [
^self play: aFilename atPos:0
]

{ #category : #action }
VlcClient >> play: aFilename atPos: aPosition [
	| player args rc |
	
	player := Config current vlcFolder.
	args := ' --fullscreen  -I qt --no-playlist-autostart --play-and-exit --no-one-instance'.
	rc := ' --extraintf rc --rc-host 127.0.0.1:' , port printString , ' --quiet '.
	proc := OSProcess command: player , args , rc , ' "' , aFilename , '" '.
	proc ifNil: [ ^ self ].
	state := 'Play'.
	self openStream.
	self startListener.
	self startAskingPos.
	self sendCommand: 'play'.
	self sendCommand: 'seek ' , aPosition printString.
	^ proc
]

{ #category : #private }
VlcClient >> processLine: aLine [
	| tok line |
	(aLine beginsWith: '>')
		ifTrue: [ line := aLine allButFirst ]
		ifFalse: [ line := aLine ].
	line := line trimmed.
	(line includesSubstring: 'state:')
		ifTrue: [ tok := (line findTokens: ' ') last.
			tok = ')'
				ifFalse: [ state := tok.] ].
	line isAllDigits
		ifTrue: [ self isRunning
				ifTrue: [ pos := line asInteger ] ]
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
	[ [ [ stream isNotNil and: [ stream isConnected ] ]
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
