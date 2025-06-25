 # Chibi Gopher for mIRC

A Gopher client script  
Version 0.9a

Written by Kaitlin Murken

## What is Gopher?

Gopher is an early internet protocol designed for distributing, searching, and retrieving documents. There's a good introduction at: gopher://gopher.floodgap.com/gopher/welcome 

Try pasting the url into the Gopher client and pressing "go" :)

## Installation

Unzip the files into your main mIRC directory. The files should end up in:  
`./script/gopher` and `./script/gopher/cache`

Then, load the script by typing the following command in mIRC:  
`//load -rs $mircdir $+ script\gopher\gopher.mrc`  

Make sure you include both slashes (`//`), or better yet, copy and paste the command directly.

## Usage

- `/gopher` — opens the client on a blank page.  
- `/gopher server <port> <file to get>` — opens the browser and launches a Gopher request.  
- Click on any `gopher://` URL anywhere in mIRC to open it directly.

The Gopher client works similarly to a web browser; all buttons and menus should be self-explanatory.

## Known Issues

- No support for CSO phonebooks yet (if you have the RFC, please send it!).  
- Large text files may take a while to load line by line (e.g., a 130k text file can take about 3 minutes).

## Contact

Please send complaints, suggestions, and bug reports to:  
iphinome@gmail.com

## Notes

This script was written over 20 years ago and reflects the technology and scripting styles of that time. It remains functional and can still be used as a simple Gopher client within mIRC
