WebClient
---------------

This fork is based on

* WebClient-Core.pck.st from WebClient-Core-ar.92.mcz
* WebClient-Tests.pck.st from WebClient-Tests-ar.46.mcz
* WebClient-HTTP.pck.st from WebClient-HTTP-ar.1.mcz (as of 2nd Jan
2012 not in Cuis)

from: www.squeaksource.com

See class comments for porting notes.


Tested code snippets
-------------------------------

These snippets are adapted from the documentation contained in
WebClient-Help-ar.10.mcz

    (WebClient httpGet: 'http://www.arduinosoftware.com') content.

    WebClient httpGet: 'http://www.arduinosoftware.com/'.

    | url client request data |
    data := 'Hello Squeak'. "POST data"
    url := 'http://www.squeak.org/'. "POST url"
    client := WebClient new initializeFromUrl: url. "sets host etc"
    request := client requestWithUrl: url. "sets path etc"
    request method: 'POST'. "sets method"
    request headerAt: 'Content-Length' put: data size.
    request headerAt: 'Content-Type' put: 'text/plain'.
    "... any other headers required ..."
    ^client sendRequest: request
    content: data readStream
    size: data size.


    | resp |
    resp := WebClient httpGet: 'http://www.squeak.org/'.
    resp isSuccess ifFalse:[^self error: resp status].
    "Process the content from the response"
    ^resp content


    | client resp file |
    client := WebClient new.
    [resp := client httpGet: 'http://www.squeak.org/'.
    resp isSuccess ifFalse:[^self error: resp status].
    "Stream the content from the response"
    file := FileStream newFileNamed: 'page.html'.
    resp streamTo: file
    size: resp contentLength
    progress:[:total :amount].
    file close] ensure:[client close].


Installation Notes:
--------------------------

Clone in your computer:

https://github.com/garduino/Cuis-Pharo14CompatibilityLayer

and the repo of WebClient (Mine: https://github.com/garduino/Cuis-WebClient or from David Graham when get integrated: https://github.com/davidgraham/Cuis-WebClient).

You need to have the repositories 'Cuis-CompatibilityWithOtherSmalltalks' and 'Cuis-Pharo14CompatibilityLayer' available as sibling directories of 'Cuis-WebClient'. Then to install execute:

    | slash  |

    slash := FileDirectory slash.
    {
    '..', slash, 'Cuis-CompatibilityWithOtherSmalltalks', slash, 'Cuis-CompatibilityWithOtherSmalltalks.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-Network-MIME.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-Network-UUID.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-NetworkTests-UUID.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-Network-Protocols.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-Network-Url.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-Network-RFC822.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-Settings-Network.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-NetworkTests-Protocols.pck.st' .
    '..', slash, 'Cuis-Pharo14CompatibilityLayer', slash, 'Cuis-NetworkTests-RFC822.pck.st' .
    '..', slash, 'Cuis-WebClient', slash, 'WebClient-Core.pck.st' .
    '..', slash, 'Cuis-WebClient', slash, 'WebClient-Tests.pck.st' .
    }
    do:
    [ :fileName | CodePackageFile installPackageStream:
                   (FileStream concreteStream readOnlyFileNamed: fileName)    ].

CAUTION: Most of these packages are work in progress by Germán Arduino
(https://github.com/garduino/Cuis-Pharo14CompatibilityLayer). He is adapting them as the need for
more features arises.

###Porting Notes

Installation protocol on the Transcript


    WebRequest>>send200Response: (UTF8TextConverter is Undeclared) 
    WebRequest>>send404Response: (UTF8TextConverter is Undeclared) 
    WebUtils class>>sha1Hash: (SecureHashAlgorithm is Undeclared) 
    WebUtils class>>webSocketHash07: (SecureHashAlgorithm is Undeclared) 
    Package WebClient-Core successfully installed
    Undeclared: a Dictionary(#ExternalSettings->nil #GIFReadWriter->nil #JPEGReadWriter->nil #Latin1TextConverter->nil #MailMessage->nil     #MailSender->nil #Project->nil #SecureHashAlgorithm->nil #ServerDirectory->nil #SqNumberParser->nil #StringHolder->nil #UTF8TextConverter->nil )


    Package WebClient-Tests successfully installed
    Undeclared: a Dictionary(#ExternalSettings->nil #GIFReadWriter->nil #JPEGReadWriter->nil #Latin1TextConverter->nil #MailMessage->nil #MailSender->nil #Project->nil #SecureHashAlgorithm->nil #ServerDirectory->nil #SqNumberParser->nil #StringHolder->nil #UTF8TextConverter->nil )


#### Unicode

Problems with Unicode
    http://jvuletich.org/pipermail/cuis_jvuletich.org/2013-February/000772.html 

    WebRequest >>send200Response:
    WebRequest >>send400Response
    WebRequest >>send404Response:
    WebRequest >>send500Response:
    WebSocket00>>send:type:
    WebSocket07>>firstFragment:
    Websocket07>>lastFragment:
    Websocket07>>nextFragment:
    WebSocket07>>send:
    WebClientServerTests>>testStrings
