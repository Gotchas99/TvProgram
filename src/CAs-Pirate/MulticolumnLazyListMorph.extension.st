Extension { #name : #MulticolumnLazyListMorph }

{ #category : #'*CAs-Pirate' }
MulticolumnLazyListMorph >> widthToDisplayItem: item [
	"This class will be removed soon, so this method will disappear"
	|  |
	
	"widths := item collect: [ :each | each widthToDisplayInList: self ].
	^widths sum + ((listSource gapSize + 4) * (widths size - 1))"   "add in space between the columns"
^0
]
