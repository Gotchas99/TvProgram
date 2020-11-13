Class {
	#name : #BaselineOfTvProgram,
	#superclass : #BaselineOf,
	#category : #BaselineOfTvProgram
}

{ #category : #baselines }
BaselineOfTvProgram >> baseline: spec [
	<baseline>
	spec
		for: #common
		do: [ spec preLoadDoIt: #preload:package:.
			spec postLoadDoIt: #postload:package:.
			self
				defineDependencies: spec;
				definePackages: spec.
			spec group: 'default' with: #('CAs-TvProgram') ]
]

{ #category : #baselines }
BaselineOfTvProgram >> defineDependencies: spec [
	^ spec
		baseline: 'MongoTalk'
			with: [ spec repository: 'github://pharo-nosql/mongotalk' ];
		baseline: 'NeoJSON'
			with: [ spec
				loads: 'core';
				repository: 'github://svenvc/NeoJSON:v17' ];
		baseline: 'NeoCSV'
			with: [ spec repository: 'github://svenvc/NeoCSV/repository' ];
		baseline: 'NeoConsole'
			with: [ spec repository: 'github://svenvc/NeoConsole:master' ];
		baseline: 'Teapot'
			with: [ spec
				loads: 'Teapot-Core';
				repository: 'github://zeroflag/Teapot:master' ];
		project: 'XMLParser'
			with: [ spec
				className: #ConfigurationOfXMLParser;
				versionString: #stable;
				loads: #('Core');
				repository: 'http://smalltalkhub.com/mc/PharoExtras/XMLParser/main/' ];
		project: 'RediStick'
			with: [ spec
				className: #ConfigurationOfRediStick;
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/MasashiUmezawa/RediStick/main/' ];
		baseline: 'PolyMath'
			with: [ spec
				loads: 'Math-DHB-Numerical';
				repository: 'github://PolyMathOrg/PolyMath:master' ];
		project: 'ServiceBase'
			with: [ spec
				className: #ConfigurationOfServiceBase;
				versionString: #stable;
				repository: 'http://smalltalkhub.com/mc/Gotchas/Jobb/main/' ];
		yourself
]

{ #category : #baselines }
BaselineOfTvProgram >> definePackages: spec [
	^ spec
		package: 'CAs-PDM'
			with: [ spec
				requires:
					#('XMLParser' 'NeoConsole' 'NeoJSON' 'MongoTalk' 'RediStick' 'Teapot' 'CAs-ServiceBase') ];
		package: 'CAs-PDM-Tests' with: [ spec requires: 'CAs-PDM' ];
		"package: 'CAs-ServiceBase';"
			yourself
]

{ #category : #manual }
BaselineOfTvProgram >> loadDeps [
"TODO: fix for TvProgram"
	"utility method. not part of baseline itself"

	Metacello new
		githubUser: 'PolyMathOrg'
			project: 'PolyMath'
			commitish: 'master'
			path: 'src';
		baseline: 'PolyMath';
		load: 'Math-DHB-Numerical'.
	Metacello new
		repository: 'github://pharo-nosql/mongotalk/src';
		baseline: 'MongoTalk';
		load.
	Metacello new
		repository: 'github://svenvc/NeoJSON/repository';
		baseline: 'NeoJSON';
		load: 'core'.
	Metacello new
		githubUser: 'svenvc'
			project: 'NeoCSV'
			commitish: 'master'
			path: 'repository';
		baseline: 'NeoCSV';
		load.
	Metacello new
		githubUser: 'svenvc'
			project: 'NeoConsole'
			commitish: 'master'
			path: 'src';
		baseline: 'NeoConsole';
		load.
	Metacello new
		githubUser: 'zeroflag'
			project: 'Teapot'
			commitish: 'master'
			path: 'src';
		baseline: 'Teapot';
		load: 'Teapot-Core'.
	Metacello new
		smalltalkhubUser: 'PharoExtras' project: 'XMLParser';
		configuration: 'XMLParser';
		version: #stable;
		load: 'Core'.
	Metacello new
		smalltalkhubUser: 'Gotchas' project: 'ServiceBase';
		configuration: 'ServiceBase';
		version: #development
]

{ #category : #manual }
BaselineOfTvProgram >> loadSelf [
	"TODO: fix for TvProgram"
	"example. change to my values"

	Metacello new
		baseline: 'PDM';
		repository: 'github://RMODINRIA-Blockchain/SmaCC-Solidity';
		load
]

{ #category : #'pre-post' }
BaselineOfTvProgram >> postload: loader package: packageSpec [
	
]

{ #category : #'pre-post' }
BaselineOfTvProgram >> preload: loader package: packageSpec [
	
]
