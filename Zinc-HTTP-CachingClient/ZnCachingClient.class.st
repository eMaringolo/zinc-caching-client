Class {
	#name : #ZnCachingClient,
	#superclass : #ZnClient,
	#instVars : [
		'forceUpdateDate'
	],
	#category : #'Zinc-HTTP-CachingClient'
}

{ #category : #operations }
ZnCachingClient >> execute [
	"Execute the currently set up request to generate a response.
	If the request was performed before, retrieve the cached version.
	Return the #contents of the response, if any."

	^self request method = #GET
		ifTrue: [ self executeCached ]
		ifFalse: [ super execute ]


]

{ #category : #operations }
ZnCachingClient >> executeCached [
	| requestHash cachedFileReference |
	requestHash := (MD5 hashMessage: self request url asString) hex.
	cachedFileReference := FileLocator localDirectory / 'zinc-cache'
		/ requestHash.
	^ (cachedFileReference exists
		and: [ cachedFileReference asFileReference creationTime
				< self forceUpdateDate ])
		ifTrue: [ cachedFileReference contents ]
		ifFalse: [ | result |
			result := super execute.
			response isSuccess
				ifTrue: [ cachedFileReference
						ensureCreateFile;
						writeStreamDo: [ :ws | ws nextPutAll: result ] ].
			result ]
]

{ #category : #accessing }
ZnCachingClient >> forceUpdateDate [
	^ forceUpdateDate ifNil: [ forceUpdateDate := DateAndTime now ]
]

{ #category : #accessing }
ZnCachingClient >> forceUpdateDate: anObject [
	forceUpdateDate := anObject
]

{ #category : #testing }
ZnCachingClient >> isCaching [

	^true
]
