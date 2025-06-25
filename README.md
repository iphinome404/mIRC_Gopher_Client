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

Make sure you include both forward slashes (`//`), or better yet, copy and paste the command directly.

## Usage

- `/gopher` — opens the client on a blank page.  
- `/gopher server <port> <file to get>` --opens the browser and launches a Gopher request.  
- Click on any `gopher://` URL anywhere in mIRC to open it directly.

The Gopher client works similarly to a web browser; all buttons and menus should be self-explanatory.

## Known Issues

- No support for CSO phonebooks yet (if you have the RFC, please send it!).  
- Large text files may take a while to load line by line (e.g., a 130k text file can take about 3 minutes).

## Contact

Please send complaints, suggestions, and bug reports to:  
iphinome@gmail.com

## About This Project

During a point in the early 2000s, my grandmother was recovering from a heart attack. I spent nights within earshot so I could help if she needed anything. While she slept, I needed to stay quiet --and awake.

With a spare desktop and mIRC as my chat client --and no one online to talk to in the middle of the night, I set out to find a way to alleviate the boredom. I’d seen some impressive mIRC scripts and wanted to learn how sockets worked. Gopher, being simple but not trivial, seemed like the perfect challenge.

This project taught me the use of raw sockets and the benefits of working directly from RFCs.

## Notes

This script was written over 20 years ago and reflects the technology and scripting styles of that time. It remains functional and can still be used as a simple Gopher client within mIRC
