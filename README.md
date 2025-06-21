Chibi Gopher for mIRC
a gopher client script
Version 0.9a

Written by Kaitlin Murken

What is gopher?
---------------

	There's a good introduction at 
	gopher://gopher.floodgap.com/gopher/welcome try pasting it
	into the gopher client and pressing "go" :)



Install 
-------
	Unzip into your main mirc directory (files should end up
	in ./script/gopher and .script/gopher/cache)

	type //load -rs $mircdir $+ script\gopher\gopher.mrc
	Make sure you have both //'s or even better just copy and
        paste from here.


Usage
-----
	/gopher (to open the client up on a blank page)
	/gopher server <port> <file to get> to open the browser and
 launch	a gopher request.
	or click on a gopher:// url anywhere in mIRC


The gopher client is similar to a web browser, all the buttons and
menus should be self-explanatory.

Known Issues:
-------------
	No support for cso phonebooks (someone send me an rfc?)

	Sometimes it appears that the client has locked up, it
	HAS NOT, it takes a long time to display long text files
	line by line. a 130k text files takes about 3 minutes.


Contact:
--------
	Send complaints, suggestions and bug reports to
	iphinome@gmail.com
