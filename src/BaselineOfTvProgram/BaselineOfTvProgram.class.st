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
				group: 'core' with: #('CAs-Pirate' 'CAs-Pirate-Gui');
				group: 'web' with: #('CAs-Pirate-Web');
				group: 'tests' with: #(#'CAs-PirateTest') ]
]

{ #category : #baselines }
BaselineOfTvProgram >> defineDependencies: spec [
	^ spec
		baseline: 'XMLParser'
			with: [ spec repository: 'github://pharo-contributions/XML-XMLParser/src' ];
		baseline: 'NeoJSON'
			with: [ spec repository: 'github://svenvc/NeoJSON/repository' ];
		baseline: 'INIFile'
			with: [ spec repository: 'github://astares/Pharo-INIFile/src' ];
		baseline: 'BabyMock2'
			with: [ spec repository: 'github://Gotchas99/BabyMock2/src' ];
			baseline: 'Seaside'
			with: [ spec repository: 'github://SeasideSt/Seaside/repository' ];
		"baseline: 'STON-Core'
					with: [ spec repository: 'github://svenvc/ston/repository' ] "
			"baseline: 'NeoJSON'
			with: [ spec
				loads: 'core';
				repository: 'github://svenvc/NeoJSON:v17' ];"
			"baseline: 'NeoConsole'
			with: [ spec repository: 'github://svenvc/NeoConsole:master' ];"
			yourself
]

{ #category : #baselines }
BaselineOfTvProgram >> definePackages: spec [
	"also depends on 'STON-Core' which is currently in the base image"

	
	^ spec
		package: 'Base32';
		package: 'HTML';
		package: 'WebRobot' with: [ spec requires: #('HTML') ];
		package: 'OSProcess';
		package: 'XMLRPC-Client-Core'
			with: [ spec requires: #('XMLParser') ];
		package: 'CAs-Pirate'
			with: [ spec
				requires:
					#('NeoJSON' 'WebRobot' 'INIFile' 'OSProcess' 'XMLRPC-Client-Core' 'Base32') ];
		package: #'CAs-Pirate-Gui' with: [ spec requires: #('CAs-Pirate') ];
		package: #'CAs-Pirate-Test'
			with: [ spec requires: #('CAs-Pirate' 'BabyMock2') ];
		package: #'CAs-Pirate-Web'
			with: [ spec requires: #('CAs-Pirate' 'Seaside') ];
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
