Class {
	#name : #PirateShowInfo,
	#superclass : #ComposableModel,
	#instVars : [
		'show',
		'buttonOK',
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
			mainColumn newRow: [ :rowButton | rowButton add: #buttonOK ]
			"Adding Button row"

			"   mainColumn 
               "	"Adding Greeting row"	"
                newRow: [ :rowGreeting |
                    rowGreeting 
                        add: #labelGreeting ]" ];
		yourself
	"Adding Main column"
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
	buttonOK
		action: [ 
			self saveData.
			self delete ]
]

{ #category : #'initailize-release' }
PirateShowInfo >> initializeWidgets [
	self
		instantiateModels:
			#(#labelName #LabelModel #txtName #TextInputFieldModel #lblImdb #LabelModel #txtImdb #TextInputFieldModel #lblDownload #LabelModel #chkDownload #CheckBoxModel #buttonOK #ButtonModel).
	labelName label: 'Show title'.
	txtName autoAccept: true.
	lblImdb label: 'Imdb ID'.
	txtImdb autoAccept: true.
	lblDownload label: 'Should download'.
	"chkDownload ."
	buttonOK
		label: 'OK';
		disable
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
