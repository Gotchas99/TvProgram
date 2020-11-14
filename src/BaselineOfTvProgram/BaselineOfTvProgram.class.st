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
						spec
				group: 'default' with: #('core');
				group: 'core' with: #('CAs-Pirate');
				group: 'tests' with: #(#'CAs-PirateTest') ]
]

{ #category : #baselines }
BaselineOfTvProgram >> defineDependencies: spec [
	^ spec
		for: #common
			do: [ spec
				baseline: 'XMLParser'
					with: [ spec repository: 'github://pharo-contributions/XML-XMLParser/src' ];
				baseline: 'NeoJSON'
					with: [ spec repository: 'github://svenvc/NeoJSON/repository' ];
				baseline: 'INIFile'
					with: [ spec repository: 'github://astares/Pharo-INIFile/src' ];
				baseline: 'Ston'
					with: [ spec repository: 'github://svenvc/ston/repository' ] ];
		yourself
		
	"baseline: 'NeoJSON'
			with: [ spec
				loads: 'core';
				repository: 'github://svenvc/NeoJSON:v17' ];" "baseline: 'NeoConsole'
			with: [ spec repository: 'github://svenvc/NeoConsole:master' ];" 
]

{ #category : #baselines }
BaselineOfTvProgram >> definePackages: spec [
	^ 			spec
				package: 'HTML';
				package: 'WebRobot' with: [ spec requires: #('HTML') ];
				package: 'OSProcess';
				package: 'XMLRPC-Client-Core';
				package: 'CAs-Pirate'
					with: [ spec
						requires:
							#('XMLParser' 'NeoJSON' 'WebRobot' 'INIFile' 'OSProcess' 'Ston' 'XMLRPC-Client-Core' 'Base32') ];
				package: #'CAs-PirateTest'
					with: [ spec requires: #('CAs-Pirate') ];
				package: #'CAs-PirateWeb'
					with: [ spec requires: #('CAs-Pirate') ];
			yourself
]

{ #category : #manual }
BaselineOfTvProgram >> loadDeps [
	"TODO: fix for TvProgram"

	"utility method. not part of baseline itself"
	self flag: #todo.

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
self flag: #todo.
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
