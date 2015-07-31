Class {
	#name : #PirateTorrentTest,
	#superclass : #TestCase,
	#instVars : [
		'fs'
	],
	#category : #'CAs-Pirate-Test'
}

{ #category : #'as yet unclassified' }
PirateTorrentTest >> folder [
	| folder  |
	"OSPlatform isUnix ifTrue: [ folder := '/media/cm1store/Torrent/' ].
	OSPlatform isWin32 ifTrue: [ folder := 'O:\Torrent\' ]."
	folder := Config current torrentFolder.
	^folder
]

{ #category : #'as yet unclassified' }
PirateTorrentTest >> setUp [
	| fd |
	fd := FileDirectory on: self folder.
	fs := fd oldFileNamed: 'breakdance.avi'.
	fs binary.
]

{ #category : #'as yet unclassified' }
PirateTorrentTest >> testHashBreakdance [
	| t |
	t := PirateTorrent new.
	self assert: ((t hash: fs) = '8E245D9679D31E12').
]

{ #category : #'as yet unclassified' }
PirateTorrentTest >> testHashBreakdance2 [
	| t h |
	t := PirateTorrent new.
	h := t hash2: fs.
	self assert: (h = '8E245D9679D31E12').
]
