Class {
	#name : #PirateShowInfo,
	#superclass : #ComposableModel,
	#instVars : [
		'show',
		'buttonOK',
		'textName',
		'labelName',
		'lblImdb',
		'txtImdb',
		'lblKat',
		'txtKat'
	],
	#category : #'CAs-Pirate-Gui'
}

{ #category : #'as yet unclassified' }
PirateShowInfo class >> defaultSpec [
    ^ SpecLayout composed
        "Adding Main column"
        newColumn: [ :mainColumn |
             
            mainColumn
                newRow: [ :rowName | 
                    rowName
                        add: #labelName;
                        add: #textName ].
            mainColumn
                newRow: [ :row | 
                    row
                        add: #lblImdb;
                        add: #txtImdb ].
            mainColumn
                newRow: [ :row | 
                    row
                        add: #lblKat;
                        add: #txtKat ].
                            
    "        mainColumn
              "  "Adding Title row""
                newRow: [ :rowTitle | 
                    rowTitle
                        add: #labelTitle;
                   "     "Adding Title Radio row""
                        newRow: [ :rowTitleRadio | 
                            rowTitleRadio
                                add: #radioMr;
                                add: #radioMrs;
                                add: #radioMs ] ]."
                                        
            mainColumn
                "Adding Button row" 
                newRow: [ :rowButton | 
                    rowButton 
                        add: #buttonOK ].
                            
         "   mainColumn 
               " "Adding Greeting row""
                newRow: [ :rowGreeting |
                    rowGreeting 
                        add: #labelGreeting ]" ];
        yourself    
]

{ #category : #accessing }
PirateShowInfo >> buttonOK [
	^ buttonOK
]

{ #category : #accessing }
PirateShowInfo >> buttonOK: anObject [
	buttonOK := anObject
]

{ #category : #'as yet unclassified' }
PirateShowInfo >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
PirateShowInfo >> initializePresenter [
	textName whenTextChanged: [ buttonOK enable ].
	buttonOK
		action: [ 
			"      labelGreeting text: 'Hello, ', self userTitle, ' ', textName text, '!'."
			buttonOK disable. self delete ]
]

{ #category : #'as yet unclassified' }
PirateShowInfo >> initializeWidgets [
	self instantiateModels: #(
		labelName	LabelModel 
		textName TextInputFieldModel 
		lblImdb			LabelModel 
		txtImdb		 	TextInputFieldModel 
		lblKat	LabelModel 
		txtKat TextInputFieldModel 
		buttonOK ButtonModel
	).
	labelName text: 'Show title'.
	textName autoAccept: true.
	lblImdb text: 'Imdb ID'.
	lblKat text: 'Kickass ID'.
	txtKat autoAccept: true.
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

{ #category : #accessing }
PirateShowInfo >> lblKat [
	^ lblKat
]

{ #category : #accessing }
PirateShowInfo >> lblKat: anObject [
	lblKat := anObject
]

{ #category : #'as yet unclassified' }
PirateShowInfo >> show: aShow [
	show := aShow.
	textName text: show name.
	txtImdb text: show imdb .
	txtKat text: show kat
]

{ #category : #accessing }
PirateShowInfo >> textName [
	^ textName
]

{ #category : #accessing }
PirateShowInfo >> textName: anObject [
	textName := anObject
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
PirateShowInfo >> txtKat [
	^ txtKat
]

{ #category : #accessing }
PirateShowInfo >> txtKat: anObject [
	txtKat := anObject
]
