Class {
	#name : #VlcClient,
	#superclass : #Object,
	#instVars : [
		'state',
		'stream',
		'pos'
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
	stream ifNotNil: [ stream destroy ].

]

{ #category : #'initialize - release' }
VlcClient >> initialize [
	super initialize.
	state := 'Play'.
	pos := 0
]

{ #category : #testing }
VlcClient >> isRunning [
	^ (state = 'End' )not
]

{ #category : #old }
VlcClient >> old [
	| player fname args proc d |
	player := Config current vlcFolder.
	fname := self videoFilename fullName.
	args := ' --fullscreen --extraintf rc -I qt --rc-host 127.0.0.1:9092 "' , fname , '" '.
	proc := OSProcess command: player , args.
	d := Delay forMilliseconds: 200.
	proc ifNil: [ ^ self ].
	[ proc isComplete ]
		whileFalse: [ 
			d wait.
			proc update: #runState ].
	^ proc
]

{ #category : #'initialize - release' }
VlcClient >> openStream [
	self closeStream.
	(Delay forSeconds: 1) wait.
	stream := SocketStream openConnectionToHostNamed: 'localhost' port: 9092.
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

{ #category : #'as yet unclassified' }
VlcClient >> play: aFilename atPos: aPosition [
	| player args proc |
	player := Config current vlcFolder.
	args := ' --fullscreen --extraintf rc -I qt --rc-host 127.0.0.1:9092 --play-and-exit "' , aFilename , '" '.
	proc := OSProcess command: player , args.
	proc ifNil: [ ^ self ].
	state := 'Play'.
	self openStream.
	self sendCommand: 'seek ' , aPosition printString.
	self startListener.
	self startAskingPos.
	^ proc
]

{ #category : #old }
VlcClient >> playOld: aFilename [
	| player args proc d s line |
	player := Config current vlcFolder.
	args := ' --fullscreen --extraintf rc -I qt --rc-host 127.0.0.1:9092 "' , aFilename , '" '.
	proc := OSProcess command: player , args.
	d := Delay forMilliseconds: 200.
	proc ifNil: [ ^ self ].
	[ 
	s := SocketStream openConnectionToHostNamed: 'localhost' port: 9092.
	[ 
	[ 
	line := s nextLine.
	self crLog: line ] repeat ]
		on: ConnectionClosed
		do: [ self crLog: 'socket closed' ] ] forkAt: Processor userBackgroundPriority.	"	[ proc isComplete ]
		whileFalse: [ 
			d wait.
			proc update: #runState ]."
	d := Delay forMilliseconds: 200.
	[ self isRunning ]
		whileFalse: [ 
			d wait.
			self sendCommand: 'get_time' ].
	^ proc
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
	stream sendCommand: cmd
]

{ #category : #'process creation' }
VlcClient >> startAskingPos [
	| d |
	d := Delay forSeconds: 1.
	[ 
	[ 
	[ stream isConnected ]
		whileTrue: [ 
			self sendCommand: 'get_time'.
			d wait ] ]
		on: ConnectionTimedOut
		do: [ self crLog: 'ask pos. stream not connected' ] ] forkAt: Processor userBackgroundPriority
]

{ #category : #'process creation' }
VlcClient >> startListener [
	| line |
	[ [ [ line := stream nextLine.
	self processLine: line ] repeat ]
		on: ConnectionClosed
		do: [ "self crLog: 'socket closed'."
			self closeStream.
			self triggerEvent: #stoppedAt: with: pos ] ] forkAt: Processor userBackgroundPriority
]
