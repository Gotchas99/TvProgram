Class {
	#name : #PirateMovie,
	#superclass : #PirateVideo,
	#instVars : [
		'tags'
	],
	#category : #'CAs-Pirate'
}

{ #category : #printing }
PirateMovie >> fullId [
	^self id
]

{ #category : #printing }
PirateMovie >> getTorrents [
	^ PirateRobot new getMovie: self tpbString.
]

{ #category : #printing }
PirateMovie >> initialize [ 
	super initialize .
	tags := Set new.
]
