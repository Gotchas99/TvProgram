Class {
	#name : #ConfigurationOfTvProgram,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfTvProgram
}

{ #category : #'development support' }
ConfigurationOfTvProgram class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #private }
ConfigurationOfTvProgram class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #private }
ConfigurationOfTvProgram class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfTvProgram class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfTvProgram class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfTvProgram class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfTvProgram class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfTvProgram class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #accessing }
ConfigurationOfTvProgram class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfTvProgram class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfTvProgram >> baseline01: spec [
	<version: '0.1-baseline'>

	spec for: #'common' do: [
		spec blessing: #'baseline'.
		spec repository: 'http://smalltalkhub.com/mc/Gotchas/TvProgram/main/'.
		spec 
			project: 'XMLParser' with: [
				spec
					className: #ConfigurationOfXMLParser;
					versionString: '2.4.9';
					repository: 'http://smalltalkhub.com/mc/PharoExtras/XMLParser/main/' ];
			project: 'NeoJSON' with: [
				spec
					className: #ConfigurationOfNeoJSON;
					versionString: '9';
					repository: 'http://mc.stfx.eu/Neo' ];
			project: 'JSON' with: [
				spec
					className: #ConfigurationOfJSON;
					versionString: '1.0';
					repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main/' ];
			project: 'INIFile' with: [
				spec
					className: #ConfigurationOfINIFile;
					versionString: '3.0';
					repository: 'http://smalltalkhub.com/mc/Pharo/MetaRepoForPharo30/main/' ];
			project: 'Ston' with: [
				spec
					className: #ConfigurationOfSton;
					versionString: #'stable';
					loads: #('Core' );
					repository: 'http://smalltalkhub.com/mc/SvenVanCaekenberghe/STON/main/' ];
			project: 'Base32' with: [
				spec
					className: #ConfigurationOfBase32;
					versionString: #'stable';
					repository: 'http://smalltalkhub.com/mc/UdoSchneider/Base32/main/' ].
		spec 
			package: 'CAs-Blocket';
			package: 'HTML';
			package: 'WebRobot' with: [
				spec requires: #('HTML' ). ];
			package: 'OSProcess';
			package: 'XMLRPC-Client-Core';
			package: 'CAs-Pirate' with: [
				spec requires: #('XMLParser' 'NeoJSON' 'WebRobot' 'JSON' 'CAs-Blocket' 'INIFile' 'OSProcess' 'Ston' 'XMLRPC-Client-Core' 'Base32' ). ];
			package: #'CAs-PirateTest' with: [
				spec requires: #('CAs-Pirate' ). ].
		spec 
			group: 'default' with: #('core' );
			group: 'core' with: #('CAs-Pirate' );
			group: 'tests' with: #(#'CAs-PirateTest' ). ].

]

{ #category : #accessing }
ConfigurationOfTvProgram >> customProjectAttributes [
	 "Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes"

	^ #().
]

{ #category : #'symbolic versions' }
ConfigurationOfTvProgram >> development: spec [
	<symbolicVersion: #'development'>

	spec for: #'common' version: '0.1-baseline'.

]

{ #category : #accessing }
ConfigurationOfTvProgram >> project [

	^ project ifNil: [ 
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		project := MetacelloMCProject new projectAttributes: self customProjectAttributes. 
		(Smalltalk at: #MetacelloVersionConstructor) on: self project: project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]
