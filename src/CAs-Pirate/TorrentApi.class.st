Class {
	#name : #TorrentApi,
	#superclass : #Object,
	#classInstVars : [
		'Token'
	],
	#category : #'CAs-Pirate'
}

{ #category : #'as yet unclassified' }
TorrentApi class >> ApiDoc [
"Found at:   https://torrentapi.org/apidocs_v2.txt
---------------------------------------------------------
When querying the api please use the app_id parameter with your app name so we can generate statistics for it.
All responses are in json by default.
Api endpoint is - https://torrentapi.org/pubapi_v2.php

To use this api you will need to first to get yourself a token
get_token=get_token
Tokens automaticly expire in 15 minutes.
The api has a 1req/2s limit.

Listing torrents :
mode=list&token=xxxx
Searching torrents : 
mode=search&search_string=Test%20Search&token=xxxx
Searching by imdb :
mode=search&search_imdb=tt123456&token=xxxx
Searching by tvdb :
mode=search&search_tvdb=123456&token=xxxx
Searching by themoviedb :
mode=search&search_themoviedb=123456&token=xxxx
DEPRECATED as of 12.09.2015 Searching by tvrage :
mode=search&search_tvrage=123456&token=xxxx

Category filtering :
You can use both categories from the site and strings to filter by category.
There are 2 categories available in the api by string - tv and movies. 
mode=search&search_imdb=tt123456&category=tv&token=xxxx
If you want to filter by categories from the site just append the category parameter which you can see from the search form on https://rarbg.com/torrents.php
mode=search&search_imdb=tt123456&category=18;41&token=xxxx

Limiting : 
limit parameter to anything will limit the results to 25,50 or 100. Default is 25
mode=search&search_imdb=tt123456&limit=100&token=xxxx

Sorting :
sort parameter will sort the results by seeders,leechers,last. Default is last uploaded
mode=search&search_imdb=tt123456&sort=last&token=xxxx

Minimum seeders/leechers :
You can specify the minimum amount of seeders and leechers using the min_seeders and min_leechers parameter.
mode=search&search_imdb=tt123456&min_seeders=50&token=xxxx
mode=search&search_imdb=tt123456&min_leechers=50&token=xxxx
mode=search&search_imdb=tt123456&min_seeders=50&min_leechers=50&token=xxxx

Result format :
format parameter will return the results in the requested format - available formats are json and json_extended. Default is json.
format json_extended returns a lot more info about the torrent.
mode=search&search_imdb=tt123456&format=json&token=xxxx

By default the api will return only ranked torrents ( internal ) , scene releases + -rarbg releases + -rartv releases.
If you want other groups included in the results use the ranked parameter with a value of 0 to get them included.
mode=search&search_imdb=tt123456&ranked=0&token=xxxx

All api times are returned in UTC.
All parameters can be mixed together.
"
]

{ #category : #'as yet unclassified' }
TorrentApi class >> Token [
	^ Token ifNil: [ Token := 'qwerty' ]
]

{ #category : #'as yet unclassified' }
TorrentApi class >> Token: aString [
	^ Token := aString
]

{ #category : #'as yet unclassified' }
TorrentApi >> baseUrl [
	^ 'http://torrentapi.org/pubapi_v2.php' asZnUrl
	"Original from doc:'https://torrentapi.org/pubapi_v2.php' "
]

{ #category : #'as yet unclassified' }
TorrentApi >> getShow: aString [
	Transcript crShow: 'TorrentApi not good for free search: ' , aString.
	^ #()	"request := self newRequest.
	request queryAt: #search_string put: aString.
	^ self sendRequest: request"
]

{ #category : #'as yet unclassified' }
TorrentApi >> getShow: anImdbId season: aSeasonId episode: anEpisodeId [
	| request resp ret info season epnum |
	season := aSeasonId asInteger printString.
	epnum := anEpisodeId asInteger printString.
	request := self newRequest.
	request queryAt: #search_imdb put: anImdbId.
	resp := self sendRequest: request.
	ret := resp
		select: [ :ep | 
			info := ep at: #episode_info.
			(info at: 'seasonnum' ifAbsent: '0') = season and: [ (info at: 'epnum') = epnum ] ].
	ret := ret
		collect: [ :ep | 
			Array
				with: (ep at: #title)
				with: (ep at: #download)
				with: (ep at: #seeders)
				with: (ep at: #leechers) ].
	^ ret
]

{ #category : #'as yet unclassified' }
TorrentApi >> getToken [
	| url request resp |
	url := self baseUrl.
	url queryAt: #get_token put: #get_token.
	request := ZnClient new
		beOneShot;
		timeout: 10;
		numberOfRetries: 3;
		retryDelay: 2;
		url: url;
		get;
		yourself.
	resp := NeoJSONReader fromString: request contents readStream.
	^self class Token: (resp at: #token ifAbsent: 'dummyToken')
]

{ #category : #'as yet unclassified' }
TorrentApi >> initialize [
	super initialize.

]

{ #category : #'as yet unclassified' }
TorrentApi >> newRequest [
	| url request |
	url := self baseUrl.
	url
		queryAt: #mode put: #search;
		queryAt: #token put: self token;
		queryAt: #category put: #tv;
		queryAt: #limit put: '100';
		queryAt: #sort put: #seeders;
		queryAt: #format put: #json_extended.
	request := ZnClient new
		beOneShot;
		timeout: 10;
		numberOfRetries: 3;
		retryDelay: 2;
		url: url;
		yourself.
	^ request
]

{ #category : #'as yet unclassified' }
TorrentApi >> sendRequest: aZnClient [
	| resp error_code |
	aZnClient get.
	resp := NeoJSONReader fromString: aZnClient contents readStream.
	error_code := resp at: #error_code ifAbsent: 0.
	error_code > 0
		ifTrue: [ Transcript logCr: 'TorrentApi: ' , (resp at: #error_code)printString ].
	(#(2 3 4) includes: error_code)
		ifTrue: [ 
			self getToken.
			aZnClient queryAt: #token put: self token.
			^ self sendRequest: aZnClient ].	"invalid token"
	error_code = 10
		ifTrue: [ ^ #() ].	"Cant find imdb in database. Are you sure this imdb exists?"
	error_code = 20
		ifTrue: [ ^ #() ].	"Nothing found"
	^ resp at: #torrent_results ifAbsent: #()
]

{ #category : #'as yet unclassified' }
TorrentApi >> token [
	^ self class Token
]
