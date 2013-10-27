Class {
	#name : #WRRobotError,
	#superclass : #Error,
	#category : #WebRobot
}

{ #category : #'as yet unclassified' }
WRRobotError >> log: aString [

	Transcript show: aString, ' ', self asString; cr
]
