Class {
	#name : #TheMovieDb,
	#superclass : #Object,
	#instVars : [
		'token',
		'proxy'
	],
	#classVars : [
		'Current'
	],
	#category : #'CAs-Pirate-Services'
}

{ #category : #'as yet unclassified' }
TheMovieDb >> apiKey [
	^'6724b3152aa4085d02c0ee02cbd03da8'
]

{ #category : #'as yet unclassified' }
TheMovieDb >> baseUrl [
	^ 'https://api.themoviedb.org/3' asZnUrl
]

{ #category : #api }
TheMovieDb >> getEpisodes: aTmdbId [
	| resp dict season episode |
	resp := self getShowInfo: aTmdbId.
	dict := Dictionary new.
	(resp at: 'seasons')
		do: [ :each | 
			season := each at: #season_number.
			episode := each at: #episode_count.
			dict at: season put: episode ].
	dict removeKey: 0 ifAbsent: [ nil ].
	^ dict
]

{ #category : #api }
TheMovieDb >> getName: aTmdbId [
	| resp    |
	resp := self getShowInfo: aTmdbId.

	^ resp at: 'name'
]

{ #category : #'as yet unclassified' }
TheMovieDb >> getShowInfo: aTmdbId [
	| url request resp    |
	url := self baseUrl / #tv / aTmdbId.
	url queryAt: #api_key add: self apiKey.
	request := ZnClient new
		beOneShot ;
		timeout: 10;
		numberOfRetries: 3;
		retryDelay: 2;
		url: url;
		get;
		yourself.
	resp := NeoJSONReader fromString: request contents readStream.
	^ resp
]

{ #category : #api }
TheMovieDb >> getTags: aTmdbId [
	| resp genres |
	resp := self getShowInfo: aTmdbId.

	genres :=(resp at: 'genres')
		collect: [ :each | 
			 (each at: #name).
			 ].
	^ genres sorted
]

{ #category : #api }
TheMovieDb >> getTmdbFromImdb: anImdb [
	| url request resp id |
	url := self baseUrl / #find / anImdb.
	url queryAt: #external_source add: #imdb_id.
	url queryAt: #api_key add: self apiKey.
	request := ZnClient new
		beOneShot ;
		timeout: 10;
		numberOfRetries: 3;
		retryDelay: 2;
		url: url;
		get;
		yourself.
	resp := NeoJSONReader fromString: request contents readStream.
	id := ((resp at: 'tv_results') first at: #id) printString.
	^ id
]

{ #category : #api }
TheMovieDb >> isInProduction: aTmdbId [
	| resp |
	resp := self getShowInfo: aTmdbId.
	^ resp at: 'in_production'
]
