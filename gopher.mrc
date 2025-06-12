; Graphical Gopher Client
;
; launched with /gopher or by clicking on a gopher:// hotlink
; 

menu menubar {
  &Gopher:/gopher
}

;; -------------------------------------
;; Alias Section
;;
;; the command line part of the gopher client


alias gopher {
  ; the command line part of the gopher client, it can open the browser
  ; with or without making a gopher request
  ; Usage /gopher host <port> <document>

  if ($1 == $null) {
    ; if no arguments are given open the gopher client
    ; without launching a gopher request

    if ($dialog(gopher) == $null) {
      .unset %gopher_client.*

      ; make sure there are no leftover variables
      ; from the last time the gopher client was
      ; open

      dialog -md gopher gopher_client

      ; open the client
    }
    else dialog -v gopher

    ; if the client is already open, make it the active window

    return
  }

  ; otherwise, if arguments ARE given...

  if ( $2 isnum ) {
    ; if a port number is given use it instead of 70

    var %gopher_client.port = : $+ $2

    if (($left($3,1) != / ) var %gopher_client.document_to_get = $chr(47) $+ $3-
    else var %gopher_client.document_to_get = $3-

    ; then make sure the document to get starts with a / (gopher requires it)
  }
  else {
    ; use the default port (70)

    if ( $left($2,1) != / ) var %gopher_client.document_to_get = $chr(47) $+ $2-
    else var %gopher_client.document_to_get = $2-

    ; then make sure the document to get starts with a / (gopher requires it)
  }

  %gopher_client.current = $1 $+ %gopher_client.port $+ %gopher_client.document_to_get

  if ($dialog(gopher) == $null) {
    dialog -md gopher gopher_client
    inc %gopher_client.history.current
    .write -l $+ %gopher_client.history.current $scriptdir $+ \history %gopher_client.current
    %gopher_client.history.max = %gopher_client.history.current

    ; if the gopher client is not open, open it then update the current and max. (for 
    ; the forward and back buttons)

  }
  else {
    dialog -v gopher

    ; make the gopher client the active window

    did -r gopher 7
    did -a gopher 7 gopher:// $+ %gopher_client.current

    ; update address bar

    inc %gopher_client.history.current
    .write -l $+ %gopher_client.history.current $scriptdir\history %gopher_client.current
    %gopher_client.history.max = %gopher_client.history.current

    ;update current and max

    if ( %gopher_client.history.current > 1 ) did -e gopher 2

    ;if there's somewhere to go back to, enable the back button

    did -b gopher 3

    ;disable the forward button
  }

  launch.gopher %gopher_client.current

  ; launch the gopher request
}


alias launch.gopher {

  var %gopher_client.launch.input = $1-

  if ($left($1-,9) == gopher://) var %gopher_client.launch.input = $remove($1,gopher://)

  ; strip off the gopher:// if it was accidently sent

  unset %gopher_client.launch.to_get

  ; make sure we don't accidently request a document when we're not supposed to

  var %gopher_client.launch.host = $leftof(%gopher_client.launch.input,$chr(47))

  if ( : isin %gopher_client.launch.host ) {
    var %gopher_client.launch.port = $rightof(%gopher_client.launch.host,:)
    var %gopher_client.launch.host = $remove(%gopher_client.launch.host,: $+ %gopher_client.launch.port)
  }
  else var %gopher_client.launch.port = 70

  ; get the address and port

  if ($rightof(%gopher_client.launch.input,/) != %gopher_client.launch.input ) %gopher_client.launch.to_get = $rightof(%gopher_client.launch.input,/)

  %gopher_client.current = %gopher_client.launch.host $+ : $+  %gopher_client.launch.port $+ / $+ %gopher_client.launch.to_get

  if (: !isin %gopher_client.launch.to_get) %gopher_client.launch.to_get = / $+ %gopher_client.launch.to_get
  if (%gopher_client.launch.to_get == /) .unset %gopher_client.launch.to_get

  ; get the name of the document to request, check for gopher+ extensions, set  current

  .did -r gopher 7
  if (%gopher_client.launch.port == 70) var %gopher_client.current = $remove(%gopher_client.current,:70)
  .did -a gopher 7 gopher:// $+ %gopher_client.current
  .write -l $+ %gopher_client.history.current $scriptdir\history %gopher_client.current

  ; update the listbox, strip out :70

  .did -r gopher 12
  .did -a gopher 12 Contacting %gopher_client.launch.host $+ : $+ %gopher_client.launch.port

  ; update the status bar

  var %gopher_client.file_to_get = $gettok(%gopher_client.launch.to_get,$numtok(%gopher_client.launch.to_get,47),47)
  if (. isin %gopher_client.file_to_get  ) {
    if  ($file_type($gettok(%gopher_client.file_to_get,$numtok(%gopher_client.file_to_get,46),46)) != txt) {
      if ($exists($getdir $+ $gettok(%gopher_client.file_to_get,$numtok(%gopher_client.file_to_get,47),47)) == $true) {
        ; if the document to get is a binary file and it already exists in $getdir
        ; prompt the user to see if they wish to overwrite it

        .splay -w $scriptdir\chord.wav
        if ( $dialog(gopher_overwrite,gopher_overwrite,-4) == $null) {
          .write $scriptdir\cache\ $+ %gopher_client.history.current 
          .write $scriptdir\gopher.tmp
          .did -r gopher 12
          .did -a gopher 12 Done
          return
        }
        ; close overwrite prompt
      }
      ; close if $exists
    }
    ; close if !txt
  }
  ; close if . isin

  .sockopen gopher_client %gopher_client.launch.host %gopher_client.launch.port 

  ; open the socket
}


;;----------------------------------------------------
;; The functions section
;;
;; functions needed by the gopher client script

alias  format_output {
  ; make the raw information from the gopher server
  ; look nice for display in the browser listbox
  ; Usage $format_output(raw information)

  if ($gettok($1-,2,9) == $null) {
    ; text line, return it as is

    return $1-
  }

  var %gopher_client.format.output = $gettok($1-,1,9)

  ; we only need to display everything before the first tab, the
  ; stuff after that is only useful to the client, not the user

  if ( $left( %gopher_client.format.output ,1 ) == 1 ) {
    var %gopher_client.format.output = <Dir> $+ $chr(160) $+ $rightof(%gopher_client.format.output,1)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 0 ) {
    var %gopher_client.format.output = <Txt> $+ $chr(160) $+ $rightof(%gopher_client.format.output,0)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 2 ) {
    var %gopher_client.format.output = <Cso> $+ $chr(160) $+ $rightof(%gopher_client.format.output,2)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 3 ) {
    var %gopher_client.format.output = $rightof(%gopher_client.format.output,3)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 4 ) {
    var %gopher_client.format.output = <BinHex> $+ $chr(160) $+ $rightof(%gopher_client.format.output,4)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 5 ) {
    var %gopher_client.format.output = <DOS> $+ $chr(160) $+ $rightof(%gopher_client.format.output,5)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 7 ) {
    var %gopher_client.format.output = <Search> $+ $chr(160) $+ $rightof(%gopher_client.format.output,7)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 8 ) {
    var %gopher_client.format.output = <Telnet> $+ $chr(160) $+ $rightof(%gopher_client.format.output,8)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == 9 ) {
    var %gopher_client.format.output = <Binary> $+ $chr(160) $+ $rightof(%gopher_client.format.output,9)
  }
  else if ( $left( %gopher_client.format.output ,1 ) === g ) {
    var %gopher_client.format.output = <Gif> $+ $chr(160) $+ $rightof(%gopher_client.format.output,g)
  }
  else if ( $left( %gopher_client.format.output ,1 ) === h ) {
    var %gopher_client.format.output = <www> $+ $chr(160) $+ $rightof(%gopher_client.format.output,h)
  }
  else if ( $left( %gopher_client.format.output ,1 ) === i ) {
    var %gopher_client.format.output = $rightof(%gopher_client.format.output,i)
  }
  else if ( $left( %gopher_client.format.output ,1 ) === I ) {
    var %gopher_client.format.output = <Img> $+ $chr(160) $+ $rightof(%gopher_client.format.output,I)
  }
  else if ( $left( %gopher_client.format.output ,1 ) === T ) {
    var %gopher_client.format.output = <Tn3270> $+ $chr(160) $+ $rightof(%gopher_client.format.output,T)
  }
  else if ( $left( %gopher_client.format.output ,1 ) == ; ) {
    var %gopher_client.format.output = <Mov> $+ $chr(160) $+ $rightof(%gopher_client.format.output,T)
  }

  ; replace the numbers that gopher servers and clients use to tell the differance
  ; between type of links and replace them with something easier
  ; for humans to understand

  return %gopher_client.format.output
}

alias file_type {
  ; return if a file type is text or binary
  ; note: .doc files should be binary
  ; because of the weird formatting

  if ($len($1-) >= 4) return txt
  if ($1- == txt) return txt
  if ($1- == me) return txt
  if ($1- == 1st) return txt
  if ($1- == nfo) return txt
  if ($1- == dir) return txt
  if ($1- == com) return txt
  if ($1- == org) return txt
  if ($1- == net) return txt
  if ($1- == edu) return txt
  if ($1- == gov) return txt
  if ($1- == asc) return txt
  if ($1- == us) return txt
  if ($1- == fr) return txt
  if ($1- == be) return txt
  if ($1- == uk) return txt
  if ($1- == fi) return txt
  if ($1- == se) return txt
  if ($1- == jp) return txt
  if ($1- == za) return txt
  if ($1- == no) return txt
  if ($1- == hum) return txt
  if ($1- == jok) return txt





  return bin
}

alias leftof {
  ; $leftof(text,x)
  ; function returns everything to the left of the first
  ; occurrence of a given character
  ; if the character is not present return the string untouched

  if ( $$2 isin $$1) {

    var %leftof.input = $$1
    var %leftof.char = $$2
    var %leftof.output = $left( %leftof.input , $pos(%leftof.input,%leftof.char,1))
    var %leftof.output = $replace(%leftof.output,%leftof.char, )

    ; can't forget to remove the character we're reading to the left of

    return %leftof.output
  }
  else return $$1
}


alias rightof {
  ; $rightof(text,x)
  ; funtion to return everything to the right of the first
  ; occurrence of a given character, if the character is not present
  ; return the string untouched

  if ( $$2 isin $$1) {

    var %rightof.input = $$1
    var %rightof.char = $$2
    var %rightof.len = $len(%rightof.input)
    var %rightof.pos = $pos(%rightof.input,%rightof.char,1)
    var %rightof.rightlen = %rightof.len - %rightof.pos
    var %rightof.output = $right(%rightof.input,%rightof.rightlen)
    return %rightof.output
  }
  else return $$1
}

;; ---------------------------------------------------
;; The gopher dialog
;;
;; the graphical part of the gopher client
;; has forward and back buttons, a favorties dialog
;; stop and refresh, the main listbox displays links and
;; text documents.
;;
;; gopher requests can be launched from the address bar, favorites, hotlinks,
;; links in the edit box and the command line
;;
;;
;; if a hypertext (rather than gopher) link is clicked it is launched in the default
;; web browser
;; if a telnet link is clicked launch telnet

dialog gopher_client {
  ; the table for the gopher dialog
  ; creats the window, buttons, and boxes

  title "Chibi Gopher"
  size  -1 -1 205 149
  icon $scriptdir\gopher.ico
  option dbu

  button "<- Back",2, 0 1 32 10,flat,disable

  ; button to go back to the last gopher request (disabled
  ; till there's somewhere to go back to

  button "Forward ->",3, 33 1 32 10,flat,disable

  ; button to go forward after using the back button (diabled
  ; till the back button is used)

  button "(X) Stop",4, 66 1 32 10,flat

  ; button to stop the current request or read

  button "% Refresh",5, 99 1 32 10,flat

  ; button to try the last gopher request again

  button "Favorites", 10, 132 1 32 10,flat

  ; button to pop up a list of your bookmarked gopher sites

  button "Exit",1, 172 1 32 10,flat,ok

  ; close the graphical client

  text "Address", 6, 2 15 20 7
  edit "",7, 22 13 160 10,autohs
  button "Go",8, 185 14 15 9,flat
  box "",11, 0 9 205  16

  ; create the address bar

  list 9, -1 26 208 120, vsbar, extsel

  ;create the listbox where gopher results are displayed

  box "",13, 0 137 100 13
  text "",12, 1 141 98 8

  ; create a status bar

  menu "&File",14
  item "Save &as...",15
  item break,16
  item "E&xit",17
  menu "&Go",20
  item "&Back",21
  item "&Forward",22
  menu "&Help",30
  item "&About",31

  ; create the menu items
}

on *:DIALOG:gopher:init:0:{
  ; when the gopher dialog is first opened

  .did -a gopher 7 gopher:// $+ %gopher_client.current

  ; full the address bar with the current gopher request
  ; (or make it just gopher:// if there isn't one)

  .did -b gopher 21
  .did -b gopher 22

  ; diable forawrd and back under the go menu

  var %gopher_client.init.count = 1

  while ( %gopher_client.init.count <= $lines($scriptdir\history) ) {
    .remove $scriptdir\cache\ $+ %gopher_client.init.count
    inc %gopher_client.init.count
  }

  ; make sure the cache is clear

  .remove $scriptdir\history
  .remove $scriptdir\gopher.tmp

  ; make sure tempfile and history are clear
}

on *:dialog:gopher:sclick:1:{
  ; when the exit button is clicked

  var %gopher_client.close.count = 1

  while ( %gopher_client.close.count <= $lines($scriptdir\history) ) {
    .remove $scriptdir\cache\ $+ %gopher_client.close.count
    inc %gopher_client.close.count
  }

  ; clear the cache

  .remove $scriptdir\gopher.tmp
  .remove $scriptdir\history

  ;clear the temp and history files

  unset %gopher_client*

  ; remove the global variables
}

on *:dialog:gopher:sclick:2:{
  ; when the back button is pressed

  .sockclose gopher_client

  ; kill any open gopher transfers

  dec %gopher_client.history.current 1
  %gopher_client.current = $read( $scriptdir\history,%gopher_client.history.current )

  ; update current

  did -r gopher 7
  did -a gopher 7 gopher:// $+ $read( $scriptdir\history,%gopher_client.history.current)

  ; update the address bar

  did -r gopher 12

  ; clear the status bar

  if ( %gopher_client.history.current <= 1 ) {
    did -b gopher 2
    did -b gopher 21
  }
  ; if you're back to the beginning of the history disable the back button

  did -e gopher 3
  did -e gopher 22

  ; enable the forward button

  ;launch.gopher $read( $scriptdir\history,%gopher_client.history.current )

  ; launch the gopher request

  .remove $scriptdir\gopher.tmp
  did -r gopher 9

  ; clear the temp storage and the listbox

  .copy $scriptdir\cache\ $+ %gopher_client.history.current $scriptdir\gopher.tmp

  var %gopher_client.back.count = 1

  while (%gopher_client.back.count <= $lines($scriptdir\gopher.tmp)) {
    did -a gopher 9 $format_output($read($scriptdir\cache\ $+ %gopher_client.history.current,nt, %gopher_client.back.count))
    inc %gopher_client.back.count
  }
  ; fill the temp file and listbox with the cached data for the current place in the
  ; history
}

on *:dialog:gopher:sclick:3:{
  ; when the forward button is clicked

  .sockclose gopher_client

  ; kill any open gopher transfers

  inc %gopher_client.history.current
  %gopher_client.current = $read( $scriptdir\history,%gopher_client.history.current )

  ;update current

  did -r gopher 7
  did -a gopher 7 gopher:// $+ $read( $scriptdir\history,%gopher_client.history.current)

  ; update the address bar

  did -r gopher 12

  ; clear the status bar

  did -e gopher 2
  did -e gopher 21

  ; enable the back button

  if ( %gopher_client.history.current == %gopher_client.history.max ) {
    did -b gopher 3
    did -b gopher 22
  }
  ;if there's nowhere forward left to go, disable the forward button 

  .remove $scriptdir\gopher.tmp
  did -r gopher 9

  ; clear the temp storage and the listbox

  .copy $scriptdir\cache\ $+ %gopher_client.history.current $scriptdir\gopher.tmp

  var %gopher_client.forawrd.count = 1

  while (%gopher_client.forawrd.count <= $lines($scriptdir\gopher.tmp)) {
    did -a gopher 9 $format_output($read($scriptdir\cache\ $+ %gopher_client.history.current,nt, %gopher_client.forawrd.count))
    inc %gopher_client.forawrd.count
  }
  ; fill the temp file and listbox with the cached data for the current place in the
  ; history
}

on *:dialog:gopher:sclick:4:{
  ;when stop is clicked, close the gopher socket

  .sockclose gopher_client
}

on *:dialog:gopher:sclick:5:{
  ; when refresh is clicked

  .sockclose gopher_client

  ; kill any open gopher transfers

  if ( %gopher_client.current != $null ) {

    ;if there's something to refresh

    did -r gopher 7
    did -a gopher 7 gopher:// $+ %gopher_client.current

    ;update the address bar

    launch.gopher %gopher_client.current

    ;and launch the gopher request
  }
}

on *:DIALOG:gopher:edit:7:{
  ; when someone types or clicks in the edit box
  ; make sure go is clicked when they hit enter

  did -f gopher 7
}

on *:dialog:gopher:sclick:8:{
  ; when go is clicked

  if ($remove($did(gopher,7),gopher://) != %gopher_client.current ) {

    ;make sure there's somehwere new to go

    %gopher_client.current = $remove($did(gopher,7),gopher://)
    inc %gopher_client.history.current
    .write -l $+ %gopher_client.history.current $scriptdir\history $remove($did(gopher,7),gopher://)
    %gopher_client.history.max = %gopher_client.history.current

    ;update current and max

    if ( %gopher_client.history.current > 1 ) {
      did -e gopher 2
      did -e gopher 21
    }
    ;if there's somewhere to go back to, enable the back button/menu

    did -b gopher 3
    did -b gopher 22

    ;disable the forward button/menu

    did -r gopher 12

    ; clear the status bar

    launch.gopher $remove($did(gopher,7),gopher://)   

    ; finally, launch the gopher request
  }
}

on *:DIALOG:gopher:dclick:9:{
  ; when a line in the main listbox is double clicked (someone's trying to follow
  ; a link)

  var %gopher_client.seltext = $remtok($read($scriptdir\gopher.tmp,$did(gopher,9,1).sel),+,9) 

  ; let's read in the data for the selected line (the data is in gopher.tmp)

  if ($gettok(%gopher_client.seltext,2,9) == $null ) {
    ; looks like it's a text line, not a link, do nothing 
    return
  }
  else if ($left(%gopher_client.seltext,1) === i ) {
    ; info text is not a link therefore do nothing when it's clicked
    return
  }
  else if ($left(%gopher_client.seltext,1) === h ) {
    ; if user clicks on a www link open it in the default web browser

    .run http:// $+ $gettok(%gopher_client.seltext,3,9) $+ : $+ $gettok(%gopher_client.seltext,4,9) $+ $right($gettok(%gopher_client.seltext,2,9),-4)  
    return
  }
  else if ($left(%gopher_client.seltext,1) == 8 ) {
    ; someone clicked a telnet link, lanch the defualt telnet client

    .run telnet:// $+ $gettok(%gopher_client.seltext,3,9)
    return
  }
  else if ($left(%gopher_client.seltext,1) === T ) {
    ; someone clicked a tn3270 link, lanch the defualt tn3270 client

    .run tn3270:// $+ $gettok(%gopher_client.seltext,3,9)
    return
  }

  if ( $numtok(%gopher_client.seltext,9) >= 5) {
    echo 4 error too many fields %gopher_client.seltext
    return
    ;some of this gopher+ stuff get's confusing, can't script
    ;it till I see more working examples
  }
  if ( $numtok(%gopher_client.seltext,9) == 4) {
    ; normal gopher link put the server port and host in order for 
    ; /launch.gopher

    var %toget = $gettok(%gopher_client.seltext,2,9)
    if ($left(%toget,1) isnum) var %toget = $right(%toget,-1)
    if ($left(%toget,1) != /) var %toget = $chr(47) $+ %toget
    %gopher_client.current = $gettok(%gopher_client.seltext,3,9) $+ : $+ $gettok(%gopher_client.seltext,4,9) $+ %toget
  }
  else if ( $numtok(%gopher_client.seltext,9) == 3 ) {
    ; there are only 3 elements, ignore the document to request
    ; space then put it in server:port format for /launch.gopher

    %gopher_client.current = $gettok(%gopher_client.seltext,2,9) $+ : $+ $gettok(%gopher_client.seltext,3,9)
  }

  if ($left(%gopher_client.seltext,1) == 7 ) {
    ; if user clicks on a search link that doesn't have a search term in it
    ; open a dialog to input search terms.

    if ( ? !isin %gopher_client.current ) %gopher_client.current = %gopher_client.current $+ ? $+ $dialog(search,gopher_search,-4)
  }
  did -r gopher 7
  did -a gopher 7 gopher:// $+ %gopher_client.current

  ; update address bar

  inc %gopher_client.history.current
  write -l $+ %gopher_client.history.current $scriptdir\history %gopher_client.current
  %gopher_client.history.max = %gopher_client.history.current

  ;update current and max

  if ( %gopher_client.history.current > 1 ) {
    did -e gopher 2
    did -e gopher 21
  }
  ;if there's somewhere to go back to, enable the back button/menu

  did -b gopher 3
  did -b gopher 22

  ;disable the forward button/menu

  launch.gopher %gopher_client.current
}

on *:DIALOG:gopher:sclick:10:{
  ; when the "Favorites" button is pushed
  ; open the favorites dialog
  ; do not allow the user to do anyhting else until 
  ; favorites is closed

  $dialog(favorites,favorites,-4)
}

on *:DIALOG:gopher:menu:15:{
  ; when save as (under the file menu) is clicked
  ; copy gopher.tmp to the location and filename given
  ; Note: this will give the raw gopher data, this looks ugly
  ; if you're not saving a text file (but this is useful if a
  ; binary file is accidently read as text)

  var %gopher_client.save.file = $sfile($getdir,Gopher Save as...,Save)
  if (%gopher_client.save.file != $null ) .copy $scriptdir\gopher.tmp %gopher_client.save.file
}

on *:dialog:gopher:menu:17:{
  ; when exit (under the file menu) is clicked
  ; close the gopher client

  .dialog -k gopher
}

on *:dialog:gopher:menu:21:{
  ; when the back menu is pressed

  sockclose gopher_client

  ; kill any open gopher transfers

  dec %gopher_client.history.current 1
  %gopher_client.current = $read( $scriptdir\history,%gopher_client.history.current )

  ; update current

  did -r gopher 7
  did -a gopher 7 gopher:// $+ $read( $scriptdir\history,%gopher_client.history.current)

  ; update the address bar

  did -r gopher 12

  ; clear the status bar

  if ( %gopher_client.history.current <= 1 ) {
    did -b gopher 2
    did -b gopher 21
  }
  ; if you're back to the beginning of the history disable the back button/menu

  did -e gopher 3
  did -e gopher 22

  ; enable the forward button/menu

  ;launch.gopher $read( $scriptdir\history,%gopher_client.history.current )

  ; launch the gopher request

  .remove $scriptdir\gopher.tmp
  did -r gopher 9

  ; clear the temp storage and the listbox

  .copy $scriptdir\cache\ $+ %gopher_client.history.current $scriptdir\gopher.tmp

  var %gopher_client.back.count = 1

  while (%gopher_client.back.count <= $lines($scriptdir\gopher.tmp)) {
    did -a gopher 9 $format_output($read($scriptdir\cache\ $+ %gopher_client.history.current,nt, %gopher_client.back.count))
    inc %gopher_client.back.count
  }
  ; fill the temp file and listbox with the cached data for the current place in the
  ; history
}

on *:dialog:gopher:menu:22:{
  ; when the forward button is clicked

  .sockclose gopher_client

  ; kill any open gopher transfers

  inc %gopher_client.history.current
  %gopher_client.current = $read( $scriptdir\history,%gopher_client.history.current )

  ;update current

  did -r gopher 7
  did -a gopher 7 gopher:// $+ $read( $scriptdir\history,%gopher_client.history.current)

  ; update the address bar

  did -r gopher 12

  ; clear the status bar

  did -e gopher 2
  did -e gopher 21

  ; enable the back button

  if ( %gopher_client.history.current == %gopher_client.history.max ) {
    did -b gopher 3
    did -b gopher 22
  }
  ;if there's nowhere forward left to go, disable the forward button 

  .remove $scriptdir\gopher.tmp
  did -r gopher 9

  ; clear the temp storage and the listbox

  .copy $scriptdir\cache\ $+ %gopher_client.history.current $scriptdir\gopher.tmp

  var %gopher_client.forawrd.count = 1

  while (%gopher_client.forawrd.count <= $lines($scriptdir\gopher.tmp)) {
    did -a gopher 9 $format_output($read($scriptdir\cache\ $+ %gopher_client.history.current,nt, %gopher_client.forawrd.count))
    inc %gopher_client.forawrd.count
  }
  ; fill the temp file and listbox with the cached data for the current place in the
  ; history
}

on *:DIALOG:gopher:menu:31:{
  ; when about (under the help menu) is clicked, bring up 
  ; the about gopher dialog, don't allow the user to
  ; do anything else in the gopher client  till "OK" is clicked

  var %gopher_client.about = $dialog(about_gopher,about_gopher,-4)
}

;; --------------------------------------------------------------------------
;; The search dialog
;; pops up when someone clicks on a search link that doesn't already contain
;; search terms

dialog gopher_search {
  ; used when someone clicks on a search link
  ; that doesn't contain search terms, this dialog
  ; is used for the user to enter search terms

  title "Search"
  icon $scriptdir\gopher.ico
  size -1 -1 70 45
  option dbu

  text "Enter search term(s)",1,5 5 60 10, center
  edit "",2, 5 15 60 10,result
  button "OK",3, 25 30 20 10,ok
}

;;---------------------------------------------------------------
;; The About Dialog
;; pops up when someone clicked the about menu item (under help)


dialog about_gopher {
  ; diaplay client name, version
  ; info and take credit for writing
  ; it

  title About Chibi Gopher
  icon $scriptdir\gopher.ico
  size -1 -1 121 75
  option dbu

  button "OK",1, 50 61 20 10,ok

  text "Chibi mIRC Gopher v0.9a",3, 5 10 70 8
  text "A gopher client script",2, 5 16 50 10

  icon 10, 80 10 32 32, $scriptdir\gopher.ico
  text "Written by Kaitlin Murken",18, 5 50 50 8
  link "<iphinome@gmail.com>",19, 56 50 60 8
  box "",20, 1 -1 119 74

  ; </useless ego stroking>
}

on *:DIALOG:about_gopher:sclick:19: {
  ; when the e-mail address link is clicked in
  ; the about dialog, open the defualt mail
  ; client and send the e-mail address

  .run mailto:iphinome@gmail.com
  return

}

;; -----------------------------------------------------
;; The overwrite dialog
;;
;; used when a file being downlaoded already exists

dialog gopher_overwrite {
  ; propmt user on whether or not to overwrite a file
  ; if it already exists

  title "Overwrite?"

  size -1 -1 80 50
  option dbu
  icon $scriptdir\gopher.ico
  text "File already exists!",1, 4 2 70 10,center
  text "Overwrite?", 2, 4 12 70 10, center

  button "Yes",10, 13 38 20 10,ok
  button "No",11, 47 38 20 10,cancel
}


;; ----------------------------------------------------------------
;; Favorites Section
;;
;; lets user launch a gopher request by double clicking on a url in
;; the listbox
;;
;; lets user add and remove urls to/from the favorites file

dialog favorites {
  ; table for the favorites dialog
  ; creates the buttons and boxes

  title "Gopher Favorites"
  icon $scriptdir\gopher.ico
  size -1 -1 149 205
  option dbu

  edit "",1, -1 -1 150 12

  ; editbox where you can change a url before adding it
  ; or type in a new one to add

  button "Add to Favorites", 2,1 13 48 12,default

  ; add whatever's in the editbox to your favorites file

  button "Delete Favorite",3,50 13 48 12,disable

  ; delete selected element (disabled till an element is selected)

  button "Done", 4, 100 13 48 12,cancel

  ; button lets you exit without adding a favorite or going to one

  list 5,-1 26 150 180,sort,vsbar

  ; box to list all the elements in your favorites file

}

on *:dialog:favorites:init:0:{
  ; when the favorites dialog is first opened

  did -a favorites 1 %gopher_client.current

  var %favorite.init.counter 1
  var %favorite.init.element $read -l $+ %favorite.init.counter $scriptdir\favorites

  ; fill the listbox with the elements from the favorites file

  while ( $null != %favorite.init.element ) {
    did -a favorites 5 gopher:// $+ $read -l $+ %favorite.init.counter $scriptdir\favorites
    inc %favorite.init.counter
    var %favorite.init.element $read -l $+ %favorite.init.counter $scriptdir\favorites
  }
}

on *:dialog:favorites:sclick:2:{
  ; when add to favorites is clicked

  var %favorite.add.element_to_add $remove($did(favorites,1),gopher://)

  ; strip off the gopher://

  if ( %favorite.add.element_to_add != $null ) {

    ; only add something if the line isn't blank after getitng rid of the gopher://

    .write $scriptdir\favorites %favorite.add.element_to_add
    did -r favorites 1

    ; clear the line that held the favorite to add

    did -r favorites 5

    ; clear the favorites list

    var %favorite.counter 1
    var %favorite.element $read -l $+ %favorite.counter $scriptdir\favorites

    while ( $null != %favorite.element ) {
      did -a favorites 5 gopher:// $+ $read -l $+ %favorite.counter $scriptdir\favorites
      inc %favorite.counter
      var %favorite.element $read -l $+ %favorite.counter $scriptdir\favorites
    }

    ; show the new updated favorites list

  }
  did -m favorites 3

  ; note : next rewrite add a way to check for duplicate entries
}


on *:dialog:favorites:sclick:3:{
  ; when the delete button is pushed

  did -b favorites 3

  ; disable the delete button

  .write -ds $+ " $+ $remove($did(favorites,5).seltext,gopher://) $+ " $scriptdir\favorites 

  ; delete the element selected

  did -r favorites 5

  ; clear the favorites list

  var %favorite.delete.counter 1
  var %favorite.delete.element $read -l $+ %favorite.delete.counter $scriptdir\favorites

  while ( $null != %favorite.delete.element ) {
    did -a favorites 5 gopher:// $+ $read -l $+ %favorite.delete.counter $scriptdir\favorites
    inc %favorite.delete.counter
    var %favorite.delete.element $read -l $+ %favorite.delete.counter $scriptdir\favorites
  }

  ; show the updated favorites list

}

on *:DIALOG:favorites:sclick:5:{
  ; when an item is clicked, activate the delete option

  did -e favorites 3
}

on *:dialog:favorites:dclick:5:{
  ; when one of the elements in the favorites listbox is double clicked

  %gopher_client.current = $remove($did(favorites,5).seltext,gopher://)
  inc %gopher_client.history.current
  .write -l $+ %gopher_client.history.current $scriptdir\history $remove($did(favorites,5).seltext,gopher://)
  %gopher_client.history.max = %gopher_client.history.current

  ; update current and max

  if ( %gopher_client.history.current > 1 ) {
    did -e gopher 2
    did -e gopher 21
  }
  ;if there's somewhere to go back to, enable the back button

  did -b gopher 3
  did -b gopher 22

  ;disable the forward button

  did -r gopher 7
  did -a gopher 7 $did(favorites,5).seltext

  ;update the address bar in the gopher dialog

  dialog -x favorites

  ; close the favorites dialog

  if $remove($did(favorites,5).seltext,gopher://) != %gopher_client.current ) {

    launch.gopher $remove($did(favorites,5).seltext,gopher://)
  }

  ; launch a gopher request with the url in the element
}

;; ---------------------------------------------------------------
;; Hotlink section
;;
;; allows users to launch the gopher client from a gopher:// hotlink

on ^*:HOTLINK:*gopher*:*:{
  ; make any word on screen containing gopher://
  ; clickable

  var %hotlink.gopher = gopher://
  if ( %hotlink.gopher isin $1 ) return
  halt
}

on *:HOTLINK:*gopher*:*:{
  ; launch a gopher request with the given url

  var %hotlink.gopher.input = $remove($1,gopher://)

  %gopher_client.current = %hotlink.gopher.input

  if ($dialog(gopher) == $null) dialog -md gopher gopher_client
  else {
    dialog -v gopher
    did -r gopher 7
    did -a gopher 7 gopher:// $+ %gopher_client.current
  }

  inc %gopher_client.history.current
  write -l $+ %gopher_client.history.current $scriptdir\history $remove($did(gopher,7),gopher://)
  %gopher_client.history.max = %gopher_client.history.current

  ;update current and max

  if ( %gopher_client.history.current > 1 ) {
    did -e gopher 2
    did -e gopher 21
  }
  ;if there's somewhere to go back to, enable the back button

  did -b gopher 3
  did -b gopher 22

  ;disable the forward button

  did -r gopher 12

  ; clear the status bar

  launch.gopher %gopher_client.current

  ; launch the gopher request
}

;; ----------------------------------------------------------------
;; Sockets section
;;
;; used to open send read save and display data to/from the gopher server

on *:SOCKOPEN:gopher_client:{
  ; when the client attempt to open a gopher connection

  .unset %gopher_client.filename

  ; clear filename so we don't accidently save a text file

  did -r gopher 9

  ; clear the listox

  .remove $scriptdir\gopher.tmp
  .remove $scriptdir\cache\ $+ %gopher_client.history.current

  ; delete the temp file and the place in the cache
  ; holding data from the last gopher request


  if ($sockerr > 0) {
    ; dammit, there was an error connecting, the gopher
    ; server probably isn't there anymore

    sockclose gopher 
    .splay -w $scriptdir\click.wav
    did -a gopher 9 Cannot connect to server
    did -r gopher 12
    did -a gopher 12 Error: Server not found
    .write $scriptdir\gopher.tmp Cannot connect to server
    .write $scriptdir $+ \cache\ $+ %gopher_client.history.current Cannot connect to server
    return

    ; display an error message, update the cache and return without doing more
  }
  else {
    sockwrite -n gopher_client %gopher_client.launch.to_get

    ; tell the gopher server what we want

    did -r gopher 12
    did -a gopher 12 Host contacted, waiting for reply

    ; update the status bar

    .remove $scriptdir $+ cache/ $+ %gopher_client.history.current

    ; make sure the place in the cache we're keepimg the data is clear

    var %gopher_client.file_to_get = $gettok(%gopher_client.launch.to_get,$numtok(%gopher_client.launch.to_get,47),47)
    if (. isin %gopher_client.file_to_get  ) {
      if  ($file_type($gettok(%gopher_client.file_to_get,$numtok(%gopher_client.file_to_get,46),46)) != txt) {
        %gopher_client.filename = $gettok(%gopher_client.file_to_get,$numtok(%gopher_client.file_to_get,47),47)
        .remove $getdir $+ %gopher_client.filename
      }
    }
  }
  ; if it turns out we're requesting a bianry file instead of text, get the
  ; filename
}


on *:SOCKREAD:gopher_client:{
  ; when the gopher server sends data back to the client

  did -r gopher 12
  did -a gopher 12 Transfering data

  ; update the status bar

  if ($sockerr > 0) {
    ; something got screwed up during the read

    did -r gopher 12
    did -a gopher 12 error transfering data

    ; update the status bar

    return
  }

  if (%gopher_client.filename == $null) {
    :nextread
    sockread -fn &gopher_client.buffer

    ; Binary transfer is faster and doesn't lock up the rest of mirc
    ; while the data is being read (you get major laggage reading large
    ; amounts of text line by line)

    if ($sockbr == 0) {
      return
    }

    bwrite $scriptdir\gopher.tmp -1 -1 &gopher_client.buffer

    ; store the data the isn't displayed in the listbox

    bwrite $scriptdir\cache\ $+ %gopher_client.history.current -1 -1 &gopher_client.buffer

    ; cache the data

    goto nextread
  }
  else {
    :nextread
    sockread -f &gopher_client.buffer
    if ($sockbr == 0) {
      return
    }
    did -r gopher 12
    did -a gopher 12 Saving binary file

    bwrite $getdir $+ %gopher_client.filename  -1 -1 &gopher_client.buffer
    .write $scriptdir\cache\ $+ %gopher_client.history.current 
    .write $scriptdir\gopher.tmp

    goto nextread
  }
}

on *:sockclose:gopher_client:{
  ; when finished reading the gopher data

  did -r gopher 12
  did -a gopher 12 Done

  ; update the status bar

  if (%gopher_client.filename == $null) {
    var %temp = 1
    while ( %temp <= $lines($scriptdir\gopher.tmp) ) {
      .did -a gopher 9 $format_output($read($scriptdir\gopher.tmp,nt, %temp))
      inc %temp
    }
    ; diaplay the text relivent to the user in the listbox
  }
  else .splay -w $scriptdir\chord.wav

  ; play a sound to note that the binary file download is finished
}
