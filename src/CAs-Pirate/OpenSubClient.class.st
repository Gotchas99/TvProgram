Class {
	#name : #OpenSubClient,
	#superclass : #Object,
	#instVars : [
		'token',
		'proxy'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
OpenSubClient class >> current [
	^ Current ifNil: [Current := self new]
]

{ #category : #'as yet unclassified' }
OpenSubClient class >> reset [
	^ Current := nil
]

{ #category : #'as yet unclassified' }
OpenSubClient >> compare: a and: b [
	((a at: 'SubHearingImpaired') < (b at: 'SubHearingImpaired')) ifTrue: [^ true].
	((a at: 'SubHearingImpaired') > (b at: 'SubHearingImpaired')) ifTrue: [^ false].
	((a at: 'SubRating')asNumber > (b at: 'SubRating')asNumber) ifTrue: [^ true].
	((a at: 'SubRating')asNumber < (b at: 'SubRating')asNumber) ifTrue: [^ false].
	((a at: 'SubDownloadsCnt')asInteger > (b at: 'SubDownloadsCnt')asInteger) ifTrue: [^ true].
	((a at: 'SubDownloadsCnt')asInteger < (b at: 'SubDownloadsCnt')asInteger) ifTrue: [^ false].
	^ true
]

{ #category : #'as yet unclassified' }
OpenSubClient >> downloadSubtitle: subDict fileName: aVideoFileName [
	"struct LogIn(string $username, string $password, string $language, string $useragent)"

	| r a data base64 zip text zipStream fs srtName |
	a := {token.
	{(subDict at: #IDSubtitleFile)}}.
	r := self proxy invokeMethod: 'DownloadSubtitles' withArgs: a.
	(r at: 'status') = '200 OK'
		ifFalse: [ ^ nil ].
	(data := r at: #data) isEmpty
		ifTrue: [ ^ nil ].
	base64 := data first at: #data.
	zip := Base64MimeConverter mimeDecodeToBytes: base64 readStream.
	zipStream := GZipReadStream on: zip.
	text := zipStream contents.
	srtName := self srtFromVideo: aVideoFileName.	"	fs:=FileDirectory default forceNewFileNamed: srtName."
	fs := FileSystem disk openFileStream: srtName writable: true.
	fs nextPutAll: text.
	fs close.
	^ self
]

{ #category : #'as yet unclassified' }
OpenSubClient >> login [
"struct LogIn(string $username, string $password, string $language, string $useragent)"
	| d r a |
	a := { 'iwantmytv'. 'gotchas'. 'en'. 'IwantMyTV v0.1' }.
 
	r := self proxy invokeMethod: 'LogIn' withArgs: a.
"struct(
    (string) [token],
    (string) [status],
    (double) [seconds]
  )"
	token := r at: 'token'.
	^ self
]

{ #category : #'as yet unclassified' }
OpenSubClient >> logout [
"struct LogIn(string $username, string $password, string $language, string $useragent)"
	| d r a |
	a := #().
 
	r := self proxy invokeMethod: 'Logout' withArgs: a.
	^ self
]

{ #category : #'as yet unclassified' }
OpenSubClient >> proxy [
	| url |
	proxy isNil ifTrue: [
		url := Url absoluteFromText: 'http://api.opensubtitles.org/xml-rpc'.
		proxy := XMLRPCProxy new url: url. 
	].
	^ proxy
]

{ #category : #'as yet unclassified' }
OpenSubClient >> searchSubtitles: aDictionary [
"struct SearchSubtitles(string $token, array(struct('sublanguageid' => string $sublanguageid, 'moviehash' => string $moviehash, 'moviebytesize' => int $moviesize, 'imdbid' => string $imdbid ), struct(...)))"
	| r a data |
	
	a := { token.  {aDictionary} }.
 
	r := self proxy invokeMethod: 'SearchSubtitles' withArgs: a.
	data := r at: 'data'.
	^ data
]

{ #category : #'as yet unclassified' }
OpenSubClient >> searchSubtitlesByname: array lang: lang [
"struct SearchSubtitles(string $token, array(struct('sublanguageid' => string $sublanguageid, 'moviehash' => string $moviehash, 'moviebytesize' => int $moviesize, 'imdbid' => string $imdbid ), struct(...)))"
	| d data |
	self obsolete .
	self halt.
	d := Dictionary new.
	d at: 'query' put: (array at: 1).
	d at: 'season' put: (array at: 2).
	d at: 'episode' put: (array at: 3).
	d at: 'sublanguageid' put: lang.
	
	data := self searchSubtitles: d.
	(data isKindOf: Boolean) ifTrue: [^#()].
	data := self sortSubtitles: data.
	^ self
]

{ #category : #'as yet unclassified' }
OpenSubClient >> searchSubtitlesByname: name season: aSeason episode: anEpisode lang: lang [
	| d data |
	d := Dictionary new.
	d at: 'query' put: name.
	d at: 'season' put: aSeason .
	d at: 'episode' put: anEpisode .
	d at: 'sublanguageid' put: lang.

	data := self searchSubtitles: d.
	(data isKindOf: Boolean) ifTrue: [^#()].
	data := self sortSubtitles: data.
	^ data
]

{ #category : #'as yet unclassified' }
OpenSubClient >> searchSubtitlesForHash: aHash size: fileSize [
	^ self searchSubtitlesForHash: aHash size: fileSize lang: 'eng'
]

{ #category : #'as yet unclassified' }
OpenSubClient >> searchSubtitlesForHash: aHash size: fileSize lang: lang [
	| d data |
	aHash ifNil: [^nil].
	d := Dictionary new.
	d at: 'sublanguageid' put: lang.
	d at: 'moviehash' put: aHash.
	d at: 'moviebytesize' put: fileSize printString.
	
	data := self searchSubtitles: d.
	(data isKindOf: Boolean) ifTrue: [^#()].
	data := self sortSubtitles: data.
	^ data
]

{ #category : #'as yet unclassified' }
OpenSubClient >> searchSubtitlesForHash: aHash size: fileSize season: aSeason episode: anEpisode lang: lang [
	| data |
	data := self searchSubtitlesForHash: aHash size: fileSize lang: lang.
	data := data select: [:i| ((i at: #SeriesEpisode) asInteger = anEpisode) and: [(i at: #SeriesSeason) asInteger = aSeason ]].
	^ data
]

{ #category : #'as yet unclassified' }
OpenSubClient >> sortSubtitles: aSubDict [
	| tmp |
	tmp := aSubDict sort: [ :a :b | self compare: a and: b ].
	^ tmp .
	
]

{ #category : #'as yet unclassified' }
OpenSubClient >> srtFromVideo: aVideoFileName [
	| lastDot base |
	lastDot := aVideoFileName findLastOccurrenceOfString: '.' startingAt: 1. 
	base := aVideoFileName copyFrom: 1 to: lastDot-1. 
	^base , '.srt'
]
