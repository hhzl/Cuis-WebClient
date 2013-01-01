'From Cuis 4.1 of 12 December 2012 [latest update: #1528] on 1 January 2013 at 6:34:24 pm'!
'Description Please enter a description for this package '!

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/25/2010 15:49'!
httpGet: url args: args user: user passwd: passwd
	"Upload the contents of the stream to a file on the server.

	WARNING: This method will send a basic auth header proactively.
	This is necessary to avoid breaking MC and SqueakSource since SS does not 
	return a 401 when accessing a private (global no access) repository."

	| urlString xhdrs client resp progress |

	"Normalize the url"
	urlString := (Url absoluteFromText: url) asString.

	"Some raw extra headers which historically have been added"
	xhdrs := HTTPProxyCredentials,
		HTTPBlabEmail.	"may be empty"

	client := WebClient new.
	client username: user; password: passwd.
	^[resp := client httpGet: urlString do:[:req|
	
		"HACK: Proactively send a basic auth header.
		See comment above."
		req headerAt: 'Authorization' put: 'Basic ', (user, ':', passwd) base64Encoded.

		"Accept anything"
		req addHeader: 'Accept' value: '*/*'.
		"Add the additional headers"
		(WebUtils readHeadersFrom: xhdrs readStream) 
			do:[:assoc| req addHeader: assoc key value: assoc value]].

	progress := [:total :amount| 
		(HTTPProgress new) total: total; amount: amount; signal: 'Downloading...'
	].

	"Simulate old HTTPSocket return behavior"
	(resp code between: 200 and: 299) 
		ifTrue:[^(RWBinaryOrTextStream with: (resp contentWithProgress: progress)) reset]
		ifFalse:[resp asString, resp content].
	] ensure:[client destroy].
! !

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/25/2010 15:49'!
httpGetDocument: url args: args accept: mimeType request: requestString
	"Return the exact contents of a web object. Asks for the given MIME type. If mimeType is nil, use 'text/html'. An extra requestString may be submitted and must end with crlf.  The parsed header is saved. Use a proxy server if one has been registered.  tk 7/23/97 17:12"

	"Note: To fetch raw data, you can use the MIME type 'application/octet-stream'."

	| client xhdrs resp urlString progress |
	"Normalize the url"
	urlString := (Url absoluteFromText: url) asString.

	args ifNotNil: [
		urlString := urlString, (self argString: args) 
	].

	"Some raw extra headers which historically have been added"
	xhdrs := HTTPProxyCredentials,
		HTTPBlabEmail,	"may be empty"
		requestString.	"extra user request. Authorization"

	client := WebClient new.
	^[resp := client httpGet: urlString do:[:req|
		"Add ACCEPT header"
		mimeType ifNotNil:[req headerAt: 'Accept' put: mimeType].

		"Always accept plain text"
		req addHeader: 'Accept' value: 'text/html'.

		"Add the additional headers"
		(WebUtils readHeadersFrom: xhdrs readStream) 
			do:[:assoc| req addHeader: assoc key value: assoc value]].

	progress := [:total :amount| 
		(HTTPProgress new) total: total; amount: amount; signal: 'Downloading...'
	].

	"Simulate old HTTPSocket return behavior"
	(resp code between: 200 and: 299) 
		ifTrue:[MIMEDocument contentType: resp contentType 
				content: (resp contentWithProgress: progress) url: url]
		ifFalse:[resp asString, resp content].
	] ensure:[client destroy].
! !

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/26/2010 01:45'!
httpPost: url args: args user: user passwd: passwd

	"WARNING: This method will send a basic auth header proactively.
	This is necessary to avoid breaking MC and SqueakSource since SS does not 
	return a 401 when accessing a private (global no access) repository."

	| argString xhdrs client resp urlString |
	"Normalize the url"
	urlString := (Url absoluteFromText: url) asString.

	args ifNotNil: [
		argString := self argString: args.
		argString first = $? ifTrue: [argString := argString allButFirst].
	].

	"Some raw extra headers which historically have been added"
	xhdrs := HTTPProxyCredentials,
		HTTPBlabEmail.	"may be empty"

	client := WebClient new.
	client username: (user ifEmpty:[nil]); password: (passwd ifEmpty:[nil]).
	^[resp := client httpPost: urlString content: (argString ifNil:[''])
				type: 'application/x-www-form-urlencoded'  do:[:req|
		"HACK: Proactively send a basic auth header.
		See comment above."
		req headerAt: 'Authorization' put: 'Basic ', (user, ':', passwd) base64Encoded.
		"Accept anything"
		req addHeader: 'Accept' value: '*/*'.
		"Add the additional headers"
		(WebUtils readHeadersFrom: xhdrs readStream) 
			do:[:assoc| req addHeader: assoc key value: assoc value]].

	"Simulate old HTTPSocket return behavior"
	(resp code between: 200 and: 299) 
		ifTrue:[MIMEDocument 
					contentType: resp contentType content: resp content url: url]
		ifFalse:[resp asString, resp content].
	] ensure:[client destroy].
! !

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/23/2010 07:43'!
httpPost: url content: postData type: contentType accept: mimeType request: requestString
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"

	| urlString xhdrs client resp |
	"Normalize the url"
	urlString := (Url absoluteFromText: url) asString.

	"Some raw extra headers which historically have been added"
	xhdrs := HTTPProxyCredentials,
		HTTPBlabEmail,	"may be empty"
		requestString.	"extra user request. Authorization"
	client := WebClient new.
	^[resp := client httpPost: urlString content: (postData ifNil:[''])
				type: contentType do:[:req|
		"Add ACCEPT header"
		mimeType ifNotNil:[req headerAt: 'Accept' put: mimeType].

		"Always accept plain text"
		req addHeader: 'Accept' value: 'text/html'.

		"Add the additional headers"
		(WebUtils readHeadersFrom: xhdrs readStream) 
			do:[:assoc| req addHeader: assoc key value: assoc value]].

	"Simulate old HTTPSocket return behavior"
	(resp code between: 200 and: 299) 
		ifTrue:[MIMEDocument 
					contentType: resp contentType content: resp content url: url]
		ifFalse:[resp asString, resp content].
	] ensure:[client destroy].
! !

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/25/2010 15:49'!
httpPostDocument: url  args: args accept: mimeType request: requestString
	"like httpGET, except it does a POST instead of a GET.  POST allows data to be uploaded"

	| argString  |
	args ifNotNil: [
		argString := self argString: args.
		argString first = $? ifTrue: [argString := argString allButFirst].
	].

	^self httpPost: url 
			content: argString 
			type: 'application/x-www-form-urlencoded' 
			accept: mimeType 
			request: requestString! !

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/25/2010 15:49'!
httpPostMultipart: url args: argsDict accept: mimeType request: requestString
	" do multipart/form-data encoding rather than x-www-urlencoded "

	| mimeBorder argsStream |
	mimeBorder := '----squeak-georgia-tech-', Time millisecondClockValue printString, '-csl-cool-stuff-----'.
	"encode the arguments dictionary"
	argsStream := WriteStream on: String new.
	argsDict associationsDo: [:assoc |
		assoc value do: [ :value | | fieldValue |
		"print the boundary"
		argsStream nextPutAll: '--', mimeBorder, CrLf.
		" check if it's a non-text field "
		argsStream nextPutAll: 'Content-disposition: multipart/form-data; name="', assoc key, '"'.
		(value isKindOf: MIMEDocument)
			ifFalse: [fieldValue := value]
			ifTrue: [argsStream nextPutAll: ' filename="', value url pathForFile, '"', CrLf, 'Content-Type: ', value contentType.
				fieldValue := (value content
					ifNil: [(FileStream fileNamed: value url pathForFile) contentsOfEntireFile]
					ifNotNil: [value content]) asString].
" Transcript show: 'field=', key, '; value=', fieldValue; cr. "
		argsStream nextPutAll: CrLf, CrLf, fieldValue, CrLf.
	]].
	argsStream nextPutAll: '--', mimeBorder, '--'.

	^self httpPost: url 
			content: argsStream contents
			type:  'multipart/form-data; boundary=', mimeBorder
			accept: mimeType 
			request: requestString
! !

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/25/2010 15:49'!
httpPostToSuperSwiki: url args: argsDict accept: mimeType request: requestString

	| mimeBorder argString |
	mimeBorder := '---------SuperSwiki',Time millisecondClockValue printString,'-----'.
	argString := String streamContents: [ :strm |
		strm nextPutAll: mimeBorder, CrLf.
		argsDict associationsDo: [:assoc |
			assoc value do: [ :value |
				strm
					nextPutAll: 'Content-disposition: form-data; name="', assoc key, '"';
					nextPutAll: CrLf;
					nextPutAll: CrLf;
					nextPutAll: value;
					nextPutAll: CrLf;
					nextPutAll: CrLf;
					nextPutAll: mimeBorder;
					nextPutAll: CrLf.
			]
		].
	].

	^self httpPost: url 
			content: argString 
			type:  'multipart/form-data; boundary=', mimeBorder
			accept: mimeType 
			request: requestString
! !

!HTTPSocket class methodsFor: '*WebClient-HTTP-override' stamp: 'ar 2/26/2010 01:45'!
httpPut: contents to: url user: user passwd: passwd
	"Upload the contents of the stream to a file on the server
	
	WARNING: This method will send a basic auth header proactively.
	This is necessary to avoid breaking MC and SqueakSource since SS does not 
	return a 401 when accessing a private (global no access) repository."

	| urlString xhdrs client resp |

	"Normalize the url"
	urlString := (Url absoluteFromText: url) asString.

	"Some raw extra headers which historically have been added"
	xhdrs := HTTPProxyCredentials,
		HTTPBlabEmail.	"may be empty"

	client := WebClient new.
	client username: (user ifEmpty:[nil]); password: (passwd ifEmpty:[nil]).
	^[resp := client httpPut: urlString content: contents type: nil  do:[:req|
		"HACK: Proactively send a basic auth header.
		See comment above."
		req headerAt: 'Authorization' put: 'Basic ', (user, ':', passwd) base64Encoded.
		"Accept anything"
		req addHeader: 'Accept' value: '*/*'.
		"Add the additional headers"
		(WebUtils readHeadersFrom: xhdrs readStream) 
			do:[:assoc| req addHeader: assoc key value: assoc value]].

	"Simulate old HTTPSocket return behavior"
	resp asString, resp content
	] ensure:[client destroy].
! !
