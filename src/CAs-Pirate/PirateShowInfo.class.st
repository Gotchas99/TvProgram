Class {
	#name : #PirateShowInfo,
	#superclass : #ComposableModel,
	#instVars : [
		'show',
		'buttonOK',
		'labelName',
		'lblImdb',
		'txtImdb',
		'txtName'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'as yet unclassified' }
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
			#(#labelName #LabelModel #txtName #TextInputFieldModel #lblImdb #LabelModel #txtImdb #TextInputFieldModel #buttonOK #ButtonModel).
	labelName label: 'Show title'.
	txtName autoAccept: true.
	lblImdb label: 'Imdb ID'.
	txtImdb autoAccept: true.
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

]

{ #category : #'as yet unclassified' }
PirateShowInfo >> show: aShow [
	show := aShow.
	txtName text: show name.
	txtImdb text: show imdb.
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
