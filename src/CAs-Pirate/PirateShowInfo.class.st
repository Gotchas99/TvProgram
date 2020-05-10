Class {
	#name : #PirateShowInfo,
	#superclass : #ComposableModel,
	#instVars : [
		'show',
		'buttonOK',
		'buttonIMDB',
		'labelName',
		'lblImdb',
		'lblDownload',
		'txtImdb',
		'txtName',
		'chkDownload'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #specs }
PirateShowInfo class >> defaultSpec [
	^ SpecLayout composed
		newColumn: [ :mainColumn | 
			mainColumn
				newRow: [ :rowName | 
					rowName
						add: #labelName;
						add: #txtName ].
			mainColumn
				newRow: [ :row | 
					row
						add: #lblImdb;
						add: #txtImdb ].
			mainColumn 
				newRow: [ :row |
					row 
						add: #buttonIMDB ].
			mainColumn
				newRow: [ :row | 
					row
						add: #lblDownload;
						add: #chkDownload ].
			"			mainColumn
				newRow: [ :row | 
					row
						add: #lblKat;
						add: #txtKat ]."

			"        mainColumn
              "	"Adding Title row"	"
                newRow: [ :rowTitle | 
                    rowTitle
                        add: #labelTitle;
                   "	"Adding Title Radio row"	"
                        newRow: [ :rowTitleRadio | 
                            rowTitleRadio
                                add: #radioMr;
                                add: #radioMrs;
                                add: #radioMs ] ]."
			mainColumn
				newRow: [ :rowButton | "Adding Button row" "   mainColumn 
               " "Adding Greeting row" "
                newRow: [ :rowGreeting |
                    rowGreeting 
                        add: #labelGreeting ]" rowButton add: #buttonOK ] ];
		"Adding Main column"
			yourself
]

{ #category : #accessing }
PirateShowInfo >> buttonIMDB [
	^ buttonIMDB
]

{ #category : #accessing }
PirateShowInfo >> buttonIMDB: anObject [
	buttonIMDB  := anObject
]

{ #category : #accessing }
PirateShowInfo >> buttonOK [
	^ buttonOK
]

{ #category : #accessing }
PirateShowInfo >> buttonOK: anObject [
	buttonOK := anObject
]

{ #category : #accessing }
PirateShowInfo >> chkDownload [
	^ chkDownload 
]

{ #category : #accessing }
PirateShowInfo >> chkDownload: anObject [
	chkDownload := anObject . 
]

{ #category : #'initailize-release' }
PirateShowInfo >> initialize [
	super initialize.
]

{ #category : #'initailize-release' }
PirateShowInfo >> initializePresenter [
	txtName whenTextChanged: [ buttonOK enable ].
	txtImdb
		whenTextChanged: [ (self isValidImdb: txtImdb text)
				ifTrue: [ buttonIMDB enable ] ifFalse: [buttonIMDB disable ]].
	buttonOK
		action: [ self saveData.
			self delete ].
	buttonIMDB action: [ self openImdb ]
]

{ #category : #'initailize-release' }
PirateShowInfo >> initializeWidgets [
	self
		instantiateModels:
			#(#labelName #LabelModel #txtName #TextInputFieldModel #lblImdb #LabelModel #txtImdb #TextInputFieldModel #lblDownload #LabelModel #chkDownload #CheckBoxModel #buttonIMDB #ButtonModel #buttonOK #ButtonModel).
	labelName label: 'Show title'.
	txtName autoAccept: true.
	lblImdb label: 'Imdb ID'.
	txtImdb autoAccept: true.
	buttonIMDB
		label: 'Open IMDB';
		disable.
	lblDownload label: 'Should download'.
	"chkDownload ."
	buttonOK
		label: 'OK';
		disable
]

{ #category : #accessing }
PirateShowInfo >> isValidImdb: aString [
aString isEmptyOrNil
		ifTrue: [ ^ false ].
	(aString beginsWith: 'http')
		ifTrue: [ ^ aString asUrl segments at: 2 notNil ].
	((aString beginsWith: 'tt') and: aString byteSize >= 9)
		ifTrue: [ ^ true ].
	(aString isAllDigits and: aString asString byteSize >= 7)
		ifTrue: [ ^ true ].
	^ false
]

{ #category : #accessing }
PirateShowInfo >> labelName [
	^ labelName
]

{ #category : #accessing }
PirateShowInfo >> labelName: anObject [
	labelName := anObject
]

{ #category : #accessing }
PirateShowInfo >> lblDownload [
	^ lblDownload 
]

{ #category : #accessing }
PirateShowInfo >> lblDownload: anObject [
	lblDownload := anObject
]

{ #category : #accessing }
PirateShowInfo >> lblImdb [
	^ lblImdb
]

{ #category : #accessing }
PirateShowInfo >> lblImdb: anObject [
	lblImdb := anObject
]

{ #category : #accessing }
PirateShowInfo >> openImdb [
	| url imdb aString |
	aString := txtImdb text.
	(self isValidImdb: aString)
		ifFalse: [ ^ nil ].
	(aString beginsWith: 'http')
		ifTrue: [ url := aString ].
	(aString beginsWith: 'tt')
		ifTrue: [ imdb := aString ].
	aString isAllDigits
		ifTrue: [ imdb := 'tt' , aString ].
	imdb ifNotNil: [ url := 'https://www.imdb.com/title/' , imdb ].
	url ifNil: [ ^ nil ].
	OSProcess isWindows
		ifTrue: [ OSProcess command: 'explorer ' , url ]
		ifFalse: [ OSProcess command: 'xdg-open ' , url ]
]

{ #category : #'as yet unclassified' }
PirateShowInfo >> saveData [
	show name: txtName text.
	show imdb: txtImdb text.
	show should_download: chkDownload state.

]

{ #category : #accessing }
PirateShowInfo >> show: aShow [
	show := aShow.
	txtName text: show name.
	txtImdb text: show imdb.
	chkDownload state: show should_download.
]

{ #category : #accessing }
PirateShowInfo >> txtImdb [
	^ txtImdb
]

{ #category : #accessing }
PirateShowInfo >> txtImdb: anObject [
	txtImdb := anObject
]

{ #category : #accessing }
PirateShowInfo >> txtName [
	^ txtName
]

{ #category : #accessing }
PirateShowInfo >> txtName: anObject [
	txtName := anObject
]
