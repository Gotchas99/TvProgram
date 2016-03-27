Class {
	#name : #BlocketItemPage,
	#superclass : #BlocketPageRoot,
	#instVars : [
		'item'
	],
	#category : #'CAs-Blocket-Web'
}

{ #category : #'as yet unclassified' }
BlocketItemPage >> dontShow [
	item dontShow.
	self answer
]

{ #category : #'as yet unclassified' }
BlocketItemPage >> initialize [
	super initialize.
]

{ #category : #'as yet unclassified' }
BlocketItemPage >> item:aBlocketItem [
	item := aBlocketItem.
	item viewed.
]

{ #category : #'as yet unclassified' }
BlocketItemPage >> refresh [
	item refresh.
"	self updateFields"
]

{ #category : #'as yet unclassified' }
BlocketItemPage >> renderContentOn: html [
	html heading: item title.
	html anchor
		callback: [ self answer];
		with: 'Stäng'.
	html text: '   --   '.
	html anchor
		callback: [ self dontShow];
		with: 'Visa inte igen'.
	html text: '   --   '.
	html anchor
		callback: [ self starred];
		with: 'Stjärnmärkt'.
	html text: '   --   '.
	html anchor
		callback: [ self refresh];
		with: 'Uppdatera'.
	html break.
	item thumb ifNotNil: [ html image url: item thumb ].
	html div
		with: item title.	html break.
"		html div:(self renderDesc: item desc)."
				html withLineBreaks: item desc.
	html break
]

{ #category : #'as yet unclassified' }
BlocketItemPage >> renderDesc: aDesc [
	| tmp |
	tmp := aDesc.self halt.
	tmp:=tmp copyReplaceAll: Character cr asString with: '<br>'.
	^ tmp
]

{ #category : #'as yet unclassified' }
BlocketItemPage >> starred [
	item starred
]
