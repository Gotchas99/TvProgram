Class {
	#name : #MagnetTest,
	#superclass : #TestCase,
	#category : #'CAs-PirateTest'
}

{ #category : #'as yet unclassified' }
MagnetTest >> testInfoHash1 [
	| m |
	m := Magnet
		from:
			'magnet:?xt=urn:btih:4AKN2ARKSRYKTX4GMEFR5MFTJQAH5MHR&dn=Fortitude.S01E08.CONVERT.HDTV.x264-W4F&tr=udp://open.demonii.com:80&tr=udp://tracker.coppersurfer.tk:80&tr=udp://tracker.leechers-paradise.org:6969&tr=udp://exodus.desync.com:6969'.
	m infoHash.
	'e014dd022a9470a9df86610b1eb0b34c007eb0f1'
]

{ #category : #'as yet unclassified' }
MagnetTest >> testInfoHash2 [
	| m |
	m := Magnet
		from:
			'magnet:?xt=urn:btih:6798DD47F270082444D4F1CED93EA55410F86582&dn=marvels+agents+of+s+h+i+e+l+d+s02e14+hdtv+x264+asap+ettv&tr=udp%3A%2F%2Ftracker4.piratux.com%3A6969%2Fannounce&tr=udp%3A%2F%2Fopen.demonii.com%3A1337'.
	self assert: m infoHash = '6798dd47f270082444d4f1ced93ea55410f86582'
]
