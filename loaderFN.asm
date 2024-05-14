     ;MICRO SPARTA DOS 4.7
	 
; w wersji 4.7 dodac mo¿naby przechodzenie po kolejnych "ekranach" z lista plikow klawiszami
; "prawo"/"lewo" albo "gora"/"dol" ... ... ale to b.trudne
; ze wzgledu na mozliwosc roznej liczby plikow (stron) w zaleznosci czy wyswietlamy
; dlugie nazwy czy nie - nie da sie tego latwo zliczyc

; dodany "Backspace" jako powrot do katalogu wyzej.

; w wersji 4.6c zmieniony sposob rozpoznawania wielkosci sektora, dodane czytanie
; bloku PERCOM przy zmianie dysku...
; UWAGA! Bufor na pierwszy sektor ma dalej 128b, bezposrednio za nim jest bufor na sektor
; mapy, ktory moze byc zamazywany w chwili odczytu pierwszego sektora bez problemow.


; w wersji 4.6b poprawione dwa male bugi i dodane kulturalne wyjscie do DOS (Shift+Esc) ...
; ..... moznaby w tym momencie sprawdzac czy jest w ogole DOS w pamieci, bo bez DOS bedzie SelfTest
	 
; w wersji 4.6 wyeliminowane chwilowe przelaczanie na domyslne kolory, ró¿ne poprawki procedur,
; ¿eby wiêcej gier siê uruchamia³o (zmiany w resecie i zmiennych systemowych)
	 
; w wersji 4.5 obsluga napedow 9-15 pod Ctrl-litera gotowa (napedy 1-8 zdublowane pod klawiszami 1-8 i Ctrl-litera
; wyswietlanie "numeru" napedu w zaleznosci jak sie go wybierze (Dn: lub n: - cyfra lub litera)
	 
; w wersji 4.4 (niepublikowanej) poprawiony blad. Nie moze byc dwa razy po sobie znacznika dziury w skompresowanej mapie
; czyli dziura max 127 sektorow a nie jak porzednio 254
; dodatkowo zapamietanie (na czas resetu przed czyszczeniem pamieci)
; stanu aktywnych urzadzen PBI i odtworzenie go po resecie (dzieki Drac030)

; stan urzadzen na szynie PBI	 
PDVMASK = $0247
	 
; nowa koncepcja zrobiona:

; 1. wywaliæ turbo 'top-drive'

; 2. przerobiæ loader i menu na obs³ugê sektorów dow. d³ugoœci

; 3. przepisac czytanie tablicy sektorów indeksowych z loadera do menu:
;    a. w menu odczytywane s¹ wszystkie sektory tablicy indeksowej
;    b. budowana jest "skompresowana" tablica offsetów w stosunku do pierwszego sektora na nast. zasadzie:
;       mamy nast. znaczniki : (nowa koncepcja)
;       1xxxxxxx  -- (0xxxxxxx = ile sektorów omin¹æ) . Op³aci siê u¿ywaæ do max 255 sektorów do przeskoczenia.
;       0xxxxxxx  -- (0xxxxxxx = ile kolejnych sektorów wczytaæ)
;       00000000  -- nastêpne 2 bajty to numer kolejnego sektora do odczytania
;               

; 4. nowa 'skompresowana' tablica indeksowa podwyzsza memlo

	 
     ;START ADDR = 1FFD
     ;END ADDR = 28C9
         ;.OPT noList
         
           icl 'lib/SYSEQU.ASM'

     
acktimeout = $a
readtimeout = 2


STACKP = $0318
CRITIC = $42
DRETRY = $02BD
CASFLG = $030F
CRETRY = $029C


CASINI = $02
;WARMST = $08
BOOT   = $09
DOSVEC = $0a
DOSINI = $0c
;APPMHI = $0e

IRQENS = $10


; zmienne procedury ladowania pliku (w miejscu zmiennych CIO - ktore sa nieuzywane - niestety teraz sa)

; najmlodszy z trzech bajtow zliczajacych do konca pliku - patrz ToFileEndH
ToFileEndL = $28
CompressedMapPos = $3D ; pozycja w skompresowanej mapie pliku

CheckSUM = $30
SecLenUS = $31
SecBuffer = $32
CRETRYZ = $34
TransmitError =$35
Looperka = $36
StackCopy = $37


SAVMSC = $58
; Adres bufora przechowywania Aktualnie obrabianego sektora zawierajacego
; katalog
CurrentDirBuf = $CA
; adres konca tego bufora (2 bajty)
CurrentDirBufEnd = $CC
; Adres (w buforze CurrentDirBuff, ale bezwzgledny) poczatku informacji
; o obrabianym pliku (skok co $17)
CurrentFileInfoBuff = $D0
; Numer sektora ktory nalezy przeczytac - mapy sektorow aktualnego katalogu (2 bajty)
DirMapSect = $D2
; Flaga ustawiana na 1 kiedy skoncza sie pliki do wyswietlenia w danym katalogu
; oznacza wyswietlanie ostatniej strony i jednoczesnie mowi o tym, ze po spacji
; ma byc wyswietlany katalog od poczatku
LastFilesPageFlag = $D6
; Licznik nazw plikow wyswietlonych aktualnie na ekranie, po wyswietleniu strony
; zawiera liczbe widocznych na ekranie plikow (1 bajt)
NamesOnScreen = $D9
; wskaznik pozycji w mapie sektorow czytanego katalogu (2 bajty) - nowa zmienna
; wczesniej byl 1 bajt w $D6
InMapPointer = $E2
; zmienna tymczasowa na ZP (2 bajty)
TempZP = $E4

VSERIN = $020a
COLPF1S = $02c5
COLPF2S = $02c6
COLBAKS = $02c8

COLDST = $0244
;MEMTOP = $02e5
;MEMLO  = $02e7

KBCODES = $02fc

DDEVIC = $0300
DUNIT  = $0301
DCOMND = $0302
DBUFA  = $0304
DBYT   = $0308
DAUX1  = $030a
DAUX2  = $030b

ICCMD = $0342
ICBUFA = $0344
;ICBUFA+1 = $0345
ICBUFL = $0348
;ICBUFL+1 = $0349
ICAX1 = $034a
ICAX2 = $034b

GINTLK = $03FA ; 0 brak carta - potrzebne przy wylaczaniu Sparty X by oszukac OS ze nie bylo carta

AUDF3  = $d204
AUDF4 = $d206
AUDC4 = $d207
AUDCTL = $d208
SKSTRES = $d20a
SEROUT = $D20d
SERIN = $D20d
IRQEN = $D20e
IRQST = $D20e


SKSTAT = $d20f
SKCTL = $d20f


PBCTL  = $d303
PORTB  = $d301

VCOUNT = $D40B

JCIOMAIN   = $e456
JSIOINT   = $e459
JTESTROM = $e471
JRESETWM = $e474
JRESETCD = $e477

	org $1FFD

; adres bufora na sektor wczytywanego pliku w oryginale $0800, ale moze wydluzyc sie procedura
; uwaga, ty juz odjety offset, wiec w procedurze nie odejmujemy!!!
FileSecBuff = loader.FirstMapSectorNr   ; po przepisaniu
TempMEMLO = loader.FirstMapSectorNr   ; Koniec procedury loader (poczatek bufora)

START
     JMP   FirstRun           ;1FFD  4C 70 21

	 
; procedura ladujaca, ktora zostanie przepisana pod adres $0700 po wybraniu programu
; do wczytania !!!!!!

movedproc 
	.local loader, $0700
 
; adres poczatkowy pamieci do ktorej zapisujemy kolejny ladowany blok pliku
InBlockAddr
    .WO 00  ; word
; dlugosc ladowanego bloku 
BlockLen
    .WO 00 ; word
; zmienna tymczasowa potrzebna do obliczenia dlugosci bloku
BlockATemp
    .WO 00
FileInit		; skok JSR pod adres inicjalizacji po (przed) kazdym nastepnym bloku binarnym
     JSR   GoInitAddr
FileNextBlock
     ; wczytanie kolejnego bloku binarnego
     JSR   FileGetBlockStart    ; pobranie dwoch bajtow (adres poczatku bloku)
     CPY  #$88  ; czy EOF
     jeq  EndOfFile
     LDA   InBlockAddr
     AND   InBlockAddr+1
     CMP  #$FF							; jesli oba sa $FF to.....
     BNE   FileNoFFFFHead
     JSR   FileGetBlockStart 	; pobranie jeszcze raz  
FileNoFFFFHead
     mwa InBlockAddr BlockATemp     ; zapamietanie adresu poczatkowego bloku (na chwile)
     LDA #<BlockLen
     sta InBlockAddr
     lda #>BlockLen
     sta InBlockAddr+1
     JSR GetFile2Bytes    ; pobranie dwoch bajtow - ; Pobranie adresu konca ladowanego bloku
     CPY  #$88  ; czy EOF
     beq  EndOfFile
     ; wyliczenie d³ugoœci bloku programu binarnego
     sec
     lda BlockLen
     sbc BlockATemp
     sta BlockLen
     lda BlockLen+1
     sbc BlockATemp+1
     sta BlockLen+1
     inw BlockLen
     mwa BlockATemp InBlockAddr     ; odtworzenie adresu poczatkowego bloku
     SEC
WhatIsIt
     BCS   FileNoFirstBlock 			; tu wstawiany jest raz (na poczatku) rozkaz LDA ($0D),Y
										; ktory tylko wylacza skok !!!
     DEC   WhatIsIt  			; Przywraca poprzednie BCS z poprzedniego wiersza!!
     LDA   InBlockAddr          		; Czyli TO wykona sie tylko RAZ
     STA   $02E0           				; Wpisujac adres pierwszego bloku do ard. startu
     LDA   InBlockAddr+1          		; na wypadek gdyby plik nie konczyl sie blokiem
     STA   $02E1           				; z adresem startu (bywa i tak).
FileNoFirstBlock
     LDA  #<Jrts         		; do adresu inicjacji wpisanie adresu rozkazu RTS
     STA   $02E2          				; bo po kazdym bloku odbywa sie tam skok
     LDA  #>Jrts          	; jesli nie jest to blok z adresem inicjacji
     STA   $02E3       					; to dzieki temu nic sie nie stanie
     
BlockReadLoop							;; petla odczytujaca z pliku blok binarny 
     JSR  GetFileBytes
     CPY  #$88  ; czy EOF
     beq  EndOfFile
     jne   FileInit        				; koniec bloku - skok pod adres inicjalizacji
FileGetBlockStart
     LDA #<InBlockAddr
     sta InBlockAddr
     lda #>InBlockAddr
     sta InBlockAddr+1
     JMP GetFile2Bytes    ; pobranie dwoch bajtow
GoInitAddr
     JMP  ($02E2)
EndOfFile								; to wykona sie przy nieoczekiwanym (i oczekiwanym) koncu pliku
     LDA  #>(JRESETWM-1)     ; cieply start (RESET) zamiast SelfTestu
     PHA
     LDA  #<(JRESETWM-1)
     PHA
     JMP  ($02E0)
Jrts
     RTS
GetFile2Bytes
    mwa #2 BlockLen
GetFileBytes
      LDX #16 ; kanal 1
      LDA #CGBINR ; rozkaz BGET
      STA ICCOM,X ; COMMAND
      LDA InBlockAddr
      STA ICBUFA,x
      LDA InBlockAddr+1
      STA ICBUFA+1,x
      LDA BlockLen
      STA ICBUFL,x
      LDA BlockLen+1
      STA ICBUFL+1,x
      JMP CIO

; koniec czesci glownejprocedury ladowania pliku przepisywanej pod $0700
; tu zaczyna sie (takze przepisywana) procedura wykonujaca sie tylko raz
; w tym miejscu potem bedzie bufor
; Tutaj wpisywany jest przez menu loadera numer pierwszego sektora
; mapy pliku do wczytania, potrzebny tylko na starcie ladowania
zzzzzz  ; dla wygody - ta etykieta powinna miec $2100 jesli procedura ja poprzedzajaca miesci sie na stronie
FirstMapSectorNr
     .WO $0000
blokDanychIO_Loader
    .BY $31,$01,$52,$40,<FileSecBuff,>FileSecBuff,$0A,$00,$80,$00
; Dlugosc sektora to dwa ostatnie bajty bloku danych ($0080 lub $0100)
SecLen = blokDanychIO_Loader+8 ; SecLen wskazuje na komórki do wpisania d³ugoœci sektora przed przepisaniem procki na stronê $0700
SectorNumber
    .WO $0000
; dwa starsze bajty (bo to wielkosc 3 bajtowa) dlugosci pliku odjetej od $1000000
; dzieki czemu mozna stwierdzic osiagniecie konca pliku przez zwiekszanie tych
; bajtow (wraz z najmlodszym) i sprawdzanie czy osiagnieto ZERO
ToFileEndH
     .WO $0000  ; do usuniecia
SioJMP
     JSR   JSIOINT
  ;   BMI   ReadErrorLoop				; jesli blad odczytu sektora to czytamy ponownie
     RTS
LoadStart
	 ; na poczatek czyszczenie pamieci od MEMLO do MEMTOP
     LDY   MEMLO
     LDA   MEMLO+1
     STA   InMemClearLoop+2
OutMemClearLoop
     LDA  #$00
InMemClearLoop
     STA   $0900,Y
     INY
     BNE   InMemClearLoop
     INC   InMemClearLoop+2
     LDA   InMemClearLoop+2
     CMP   MEMTOP+1
     BCC   OutMemClearLoop
     LDA   MEMTOP+1
     STA   LastMemPageClear+2
     LDY   MEMTOP
     LDA  #$00
LastMemPageClear
     STA   $8000,Y
     DEY
     CPY  #$FF
     BNE   LastMemPageClear
	 ; wyczyszczona, wiec ....
     LDA  #$FF
     STA   KBCODES
     INC   WhatIsIt	; zmiana BCS omijajacego procedure na LDA (adres pierwszego bloku do STARTADR)
     JMP   FileNextBlock
; tymczasowe przechowanie najmlodszego bajtu licznika do konca pliku
; sluzy do przepisania tego bajtu z glownego programu do zmiennej loadera
tempToFileEndL
     .BY $00
    .endl
JAkieTurbo
USmode
	 .BY $01     ; 0 - brak turbo   1 - Ultra Speed
QMEG
     .BY $01    ;1 - brak QMEGa     0 - jest QMEG
BootDrive
     .BY $00    ;Numer stacji dysków z której sie BOOT robi
BootShift
     .BY $01	; stan Shift w czasie bootowania (przyda sie jednak)  1 - bez shift  0 - Shift wcisniety
FolderTurbo
	 .BY $01	; 00 wy³¹cza turbo 01 - zostawia tak jak jest - ty ma sie wpisywac znacznik turbo dla katalogu z MSDOS.DAT
NewColors
	 .BY $00   ; 00 oznacza ze nie zaladowano kolorow z pliku DAT i trzeba ustawic standardowe - inna wartosc zaladowano
; Zamiana 4 mlodszych bitow z A na liczbe Hex w Ascii (tez w A)
bin2AsciiHex
     AND  #$0F 
     ORA  #$30 
     CMP  #$3A
     BCC   labelka 
     CLC
     ADC  #$07
labelka
     RTS 
Edriver
     .BY "E:",$9b      
EditorOpen
     ; otwarcie ekranu !!!
     LDX  #$00             ; kanal nr 0
     JSR   CloseX           ; najpierw Zamkniecie Ekranu
     BMI   ErrorDisplay
     LDX  #$00             ; kanal nr 0
     LDA  #$03 
     STA   ICCMD,X 
     LDA  #$0C 
     STA   ICAX1,X
     STA   ICBUFL,X
     LDA  #$00 
     STA   ICAX2,X
     STA   ICBUFL+1,X
     LDA  #<Edriver
     STA   ICBUFA,X
     LDA  #>Edriver
     STA   ICBUFA+1,X
     JSR   JCIOMAIN            ; Otwarcie "E:" w trybie Gr.0
     BMI   ErrorDisplay
     RTS
	 
mainprog
     LDA   QMEG       ; jesli jest QMEG to wylacza sie tryb US
	 AND   BootShift  ; i jak byl Shift w czasie bootowania tez sie wylacza
     STA   USmode           
     BEQ   NoUSSpeed
     ; Pytanie stacji o predkosc transmisji Happy/US-Doubler
     ldy  #<blokDanychIO_GetUSSpeed    
     ldx  #>blokDanychIO_GetUSSpeed
     jsr   Table2DCB
     jsr   JSIOINT             ; wysylamy "?"
     bpl   USSpeed
     lda   #0		; blad odczytu wiec nie ma USspeed - zerujemy wiec flage
	 sta   USmode
	 beq   NoUSSpeed
USSpeed
	 LDY #$2
USstatprint
	 LDA ONtext,y
	 STA USstatus,y
	 DEY
	 bpl USstatprint

NoUSSpeed
     JMP   ReadMainDir        
Error148
     LDY  #$94             ; kod bledu do Y
     ; wyswietlenie komunikatu o bledzie - kod bledu w Y
ErrorDisplay
     TYA
     PHA
     JSR   Close1
     PLA 
     PHA
     LSR
     LSR 
     LSR
     LSR
     JSR   bin2AsciiHex  ; 4 starsze bity na HEX
     STA   ErrorNumHex
     PLA 
     JSR   bin2AsciiHex  ; 4 mlodsze bity na HEX
     STA   ErrorNumHex+1 
     JSR   PrintXY
     .BY $00,$00  
     .BY $7d              ; kod czyszczenia ekranu
     .BY "ERROR - $"
ErrorNumHex
     .BY "00",$00
     ; czekamy na dowolny klawisz
     LDA  #$FF
     STA   KBCODES 
WaitKloop
     LDX   KBCODES
     INX 
     BEQ   WaitKloop 
     STA   KBCODES    ; w A jest $FF
     ; ------------------
     ; na wypadek wybrania nieistniejacej stacji
     ; po bledzie przechodzimy na te z ktorej sie ladowalismy
     LDA BootDrive
	 ;LDA #1
     JSR SeTDriveNR
     ; -----------------
     JMP   mainprog     ; i odpalamy program od nowa
ReadMainDir
     JSR  ReadPERCOM
     LDX  #>FirstSectorBuff
     LDY  #<FirstSectorBuff
     JSR   ReadFirstSect
; Sprawdzenie wersji DOSa pod ktora formatowany byl dysk
     LDA   FirstSectorBuff+$20
     CMP  #$11            ; Sparta DOS 1.1
     BEQ   SpartaDisk
     CMP  #$20            ; Sparta DOS 2.x 3.x Sparta DOS X 4.1x/4.2x
     BEQ	SpartaDisk
	 CMP  #$21			   ; Nowy format Sparta DOS X >= 4.39 (moga byc sektory wieksze niz 256b)
     BNE   Error148       ; Nieobslugiwany format dyskietki
SpartaDisk
     LDX  #$00 
; pobranie dlugosci sektora ($00 lub $80) - poprawione dla wiekszych niz 256
     LDA   FirstSectorBuff+$1F
     BMI   Sektor128b
	 TAX
	 LDA  #$00
     INX                   ; i wyliczenie starszego bajtu
Sektor128b
     STA   .adr loader.SecLen	; przed przepisaniem
     STX   .adr loader.SecLen+1	; przed przepisaniem
	 ; pokazanie na ekranie
	 LDA   DensityCodes,X
	 STA   DensityDisplay
; pobranie numeru pierwszego sektora mapy sektorow glownego katalogu
     LDY   FirstSectorBuff+$09
     LDX   FirstSectorBuff+$0A
; odczyt katalogu, ktorego mapa zaczyna sie w sektorze y*256+x
ReadDIR
; ustawienie znacznika wlaczenia Turbo dla katalogu
	 LDA  #$01
	 STA   FolderTurbo
     STY   DirMapSect
     STX   DirMapSect+1
     LDA  #>DirSectorBuff
     STA   CurrentFileInfoBuff+1
     STA   CurrentDirBuf+1
     LDA  #<DirSectorBuff
     STA   CurrentFileInfoBuff
     STA   CurrentDirBuf
     LDA  #$00 
	 STA   NewColors       ; wyzerowanie kolorow tak zeby jak nie bedzie ich w DAT ustawily sie standardowe (akurat mamy 0 w A)
     STA   $D4
     STA   $D5
     LDA  #$17
     JSR   label39
     LDA   CurrentFileInfoBuff
     STA   CurrentDirBufEnd
     LDA   CurrentFileInfoBuff+1
     STA   CurrentDirBufEnd+1
     LDA  #$00
     STA   $D7
     STA   $D8
     LDA   CurrentDirBuf
     STA   CurrentFileInfoBuff
     LDA   CurrentDirBuf+1
     STA   CurrentFileInfoBuff+1
label46
     LDA   CurrentFileInfoBuff+1
     CMP   CurrentDirBufEnd+1
     BCC   label40
     BNE   ToStartOfDir
     LDA   CurrentFileInfoBuff
     CMP   CurrentDirBufEnd
     BCS   ToStartOfDir
label40
     LDY  #$00
     LDA  (CurrentFileInfoBuff),Y
     AND  #$38
     CMP  #$08
     BNE   label42
     LDY  #$10
     LDX  #$0A
label43
     LDA  (CurrentFileInfoBuff),Y
     CMP   ProgName,X
     BNE   label42
     DEY
     DEX
     BPL   label43
     BMI   DATfileFound
ProgName
     .BY "MSDOS   DAT"
label42
     LDA   CurrentFileInfoBuff
     CLC
     ADC  #$17
     STA   CurrentFileInfoBuff
     BCC   label45
     INC   CurrentFileInfoBuff+1
label45
     JMP   label46
; znaleziono plik z dlugimi nazwami
DATfileFound
     ; numer pierwszego sektora mapy sektorow pliku MSDOS.DAT przepisujemy do
	 ; wskaznika aktualnego sektora mapy pliku/katalogu. Dzieki temu przy skoku do procedury czytania
	 ; sektora mapy, przeczyta sie wlasnie ten pierwszy
     LDY  #$01
     LDA  (CurrentFileInfoBuff),Y
     STA   DirMapSect 
     INY
     LDA  (CurrentFileInfoBuff),Y 
     STA   DirMapSect+1
     INY
     LDA  (CurrentFileInfoBuff),Y
     STA   $D4
     INY 
     LDA  (CurrentFileInfoBuff),Y 
     STA   $D5
     INY
     LDA  (CurrentFileInfoBuff),Y
     BEQ   label47
     LDA  #$FF
     STA   $D4 
     STA   $D5
label47
     LDA   CurrentDirBufEnd
     STA   CurrentFileInfoBuff
     LDA   CurrentDirBufEnd+1
     STA   CurrentFileInfoBuff+1
     LDA  #$2E
     JSR   label39
     LDA   CurrentFileInfoBuff
     STA   $CE
     LDA   CurrentFileInfoBuff+1
     STA   $CF
     INC   $D8
; ustawienie wskaznikow dla listy wyswietlanych plikow na poczatek katalogu
ToStartOfDir
	 LDA  #$00
     STA   LastFilesPageFlag
     LDA   CurrentDirBuf
     CLC
     ADC  #$17
     STA   CurrentFileInfoBuff
     LDA   CurrentDirBuf+1
     ADC  #$00
     STA   CurrentFileInfoBuff+1
StatusBarPrint
     JSR   PrintXY
     .BY $00,$00
     .BY $7d
DensityDisplay
     .BY +$80," D"
DriveDisp1        ;                               "
     .BY +$80,"A: MSDOS 4.7  QMEG:"
QMEGstatus
	 .BY +$80,"OFF/BAS:"
BASstatus
	 .BY +$80,"OFF/US:"
USstatus
	 .BY +$80,"OFF "  ; w inversie
     .BY $00
; Nowa (minus pierwsza ;) linijka opisu na dole
	 JSR PrintXY
	 .BY $11,$15
	 .BY +$80,"1"
	 .BY "-"
	 .BY +$80,"8"
	 .BY " or "
     .BY +$80,"ctrl"
	 .BY "+"
	 .BY +$80,"A..O"
	 .BY " Drive"
	 .BY $00
; Pierwsza linijka opisu na dole strony
     JSR   PrintXY
     .BY $01,$16
     .BY +$80,"SPACE"
     .BY ":Continue  "
     .BY +$80,"SHIFT"
     .BY "+...No High Speed"
     .BY $00 
; Druga linijka opisu na dole strony
     JSR   PrintXY
     .BY $02,$17
     .BY +$80,"ESC"
     .BY ":All files  "
     .BY +$80,">"
     .BY ":Main Dir.  "
     .BY +$80,"<"
     .BY ":UP-DIR."
     .BY $00
     LDA  #$00
     STA   NamesOnScreen
label68
     LDA   CurrentFileInfoBuff+1
     CMP   CurrentDirBufEnd+1
     BCC   NoLastFileInDir
     BNE   LastFilesPageJump
     LDA   CurrentFileInfoBuff
     CMP   CurrentDirBufEnd
     BCS   LastFilesPageJump
NoLastFileInDir
     LDY  #$00
     LDA  (CurrentFileInfoBuff),Y 
     BEQ   LastFilesPageJump
     LDX  #$22
     LDA  #$20    ; spacja
label50
     STA   GameName,X
     DEX 
     BPL   label50
     LDY  #$10
     LDX  #$0A
label51
     LDA  (CurrentFileInfoBuff),Y
     STA   GameName,X
     DEY
     DEX
     BPL   label51
     LDA   NamesOnScreen
     CLC
     ADC  #$41   ; literka "A"
     STA   GameKeySymbol
     LDA   $D8
     BNE   label52
     LDY  #$00
  ; status sprawdzanego pliku
     LDA  (CurrentFileInfoBuff),Y 
     AND  #$19
     CMP  #$09
  ; sprawdzamy czy Nie skasowany, zabezpieczony i "w uzyciu"
     BEQ   label53
     LDX   $D7
     BEQ   label54
     CMP  #$08
     BNE   label54
label53
  ; jeszcze raz status sprawdzanego pliku
     LDA  (CurrentFileInfoBuff),Y
     AND  #$20
  ; sprawdzenie czy to podkatalog jesli nie 'label55' (czyli plik)
     BEQ   label55
  ; obsluga wyswietlenia nazwy podlatalogu (dopisanie "<SUB-DIR>")
     LDX  #$08
label56
     LDA   SubDirText,X
     STA   GameName+12
     DEX
     BPL   label56
label55
     JMP   GameNamePrint
LastFilesPageJump
     JMP   LastFilesPage
label54
     JMP   label59
label52
     LDY  #$00
     LDA  (CurrentFileInfoBuff),Y
     AND  #$18
     CMP  #$08
     BNE   label54
     LDA   CurrentDirBufEnd
     STA   $D4
     LDA   CurrentDirBufEnd+1
     STA   $D5
label65
     LDA   $D5
     CMP   $CF
     BCC   label60
     BNE   label54 
     LDA   $D4
     CMP   $CE
     BCS   label54
; tu trzebaby sprawdzic * - tyle ze sprawdzaloby sie to przy szukaniu kazdej nazwy
label60
     LDY #$00
	 LDA ($D4),Y
	 CMP #'*'
	 BNE CompareNames
	 STA NewColors
	 JSR Asteriks
CompareNames
; Porownanie nazwy pliku do wyswietlenia z nazwa z MSDOS.DAT
     LDY  #$0A      ; 8+3 znaki
Checking62
     LDA  ($D4),Y 
     CMP   GameName,Y 
     BNE   CheckNextName  ; jesli to nie ta nazwa sprawdzamy nastepna z bufora dlugich nazw
     DEY
     BPL   Checking62
; Wpisanie nazwy "ekranowej" zamiast nazwy pliku
     LDY  #$0B     ; przesuniecie o 11 bajtow zeby ominac nazwe DOSowa pliku
ReplacingName
     LDA  ($D4),Y 
     STA   GameName-$0B,Y  ; nadpisujemy nazwe pliku w buforze wyswietlania
     INY 
     CPY  #$2E
     BCC   ReplacingName
     BCS   GameNamePrint
CheckNextName
     LDA   $D4 
     CLC
     ADC  #$2E
     STA   $D4
     BCC   label64
     INC   $D5
label64
     JMP   label65
GameNamePrint
     LDA   NamesOnScreen
     CLC
     ADC  #$02
     STA   YposGameName
     JSR   PrintXY
     .BY $01
YposGameName
     .BY $02
GameKeySymbol
     .BY "A) "
GameName
     .BY "                                   "
     .BY $00 
     LDA   NamesOnScreen
     ASL
     TAX
     LDA   CurrentFileInfoBuff
     STA   FirstSectorsTable,X
     LDA   CurrentFileInfoBuff+1
     STA   FirstSectorsTable+1,X
     LDA   CurrentFileInfoBuff
     CLC
     ADC  #$17
     STA   CurrentFileInfoBuff
     BCC   label66
     INC   CurrentFileInfoBuff+1
label66
     INC   NamesOnScreen
     LDA   NamesOnScreen
     CMP  #$13
     BCS   ContArrowsPrint    ; jest wiecej plikow niz sie zmiescilo na ekranie
     JMP   label68
label59
     LDA   CurrentFileInfoBuff 
     CLC
     ADC  #$17
     STA   CurrentFileInfoBuff
     BCC   label69
     INC   CurrentFileInfoBuff+1
label69
     JMP   label68
MainDirKEY
     JMP   ReadMainDir
UpDirKEY
     LDY  #$02
     LDA  (CurrentDirBuf),Y
     TAX 
     DEY
     ORA  (CurrentDirBuf),Y 
     BEQ   KeyboardProc
     LDA  (CurrentDirBuf),Y
     TAY 
     JMP   ReadDIR
EscKEY
     ; sprawdzmy czy z Shift
     LDA   SKSTAT   ; jesli jest Shift to czyscimy ekran i do DOS !!!
	 and   #$08
     BNE   NoSHIFTEsc
	 JSR EditorOpen
	 JMP (DOSVEC)
NoSHIFTEsc	 
     LDX  #$00
     STX   $D8 
     INX 
     STX   $D7
ToStartOfDirJump
     JMP   ToStartOfDir
SpaceKEY
     LDA   LastFilesPageFlag	; jesli wyswietlona zostala ostatnia strona listy
     BNE   ToStartOfDirJump	; to wyswietlamy liste od poczatku
     JMP   StatusBarPrint		; a jesli nie lecimy z wyswietlaniem dalej
; Wyswietlenie strzalek pokazujacych ze jest wiecej plikow niz miesci sie na ekranie
ContArrowsPrint
     JSR   PrintXY
     .BY $01,$15
     .BY $1D		; strzalka w dol
     .BY $00
     JSR   PrintXY
     .BY $0E,$15
     .BY $1D		; strzalka w dol
     .BY $00
     JMP   KeyboardProc
LastFilesPage
     INC   LastFilesPageFlag
KeyboardProc
	 LDA  NewColors
	 BNE  ColorsAlreadySet
     LDA  #$C4 	; ustawienie koloru t³a i liter
     STA   COLPF2S
     STA   COLBAKS
	 LDA  #$CA
	 STA   COLPF1S
ColorsAlreadySet
     JSR   GetKey
     AND #%01111111  ; eliminujemy invers	 
	 BEQ  KeyboardProc  ; na pocz¹tku wykluczamy 0 (znak serduszka) - to dla wygody ustalania numeru napedu
     CMP  #$3E  ; ">"
     BEQ   MainDirKEY
     CMP  #$3C  ; "<"
     BEQ   UpDirKEY
	 CMP  #$7E  ; BackSpace
     BEQ   UpDirKEY
     CMP  #$1B  ; Esc
     BEQ   EscKEY
     CMP  #$20  ; Spacja
     BEQ   SpaceKEY
     ; ----------------
	 ; sprawdzenie ctrl+A do ctrl+O (kody od $01 do $0f)
	 CMP #$10
	 BCS noCtrlLetter ; jesli kod mniejszy od 16 to naped (0 wykluczylismy na poczatku)
	 JSR SeTDriveLetter
	 JMP mainprog
noCtrlLetter
     ; sprawdzenie klawiszy 1-8
     CMP #'1'
     BCC NoNumber
     CMP #'9'
     BCS NoNumber
     SEC
     SBC #'0'
     JSR SeTDriveNR
     JMP mainprog
     ; -----------------
NoNumber
     CMP #'a'   ; czy nie ma capsa
	 BCC BigLetters    ; mniejsza od 'a' wiec duza - C tu bedzie skasowany
	 SBC #$20  ; tu nie trzeba SEC bo C jest zawsze ustawiony (odejmujemy $20 - przestawiamy z malych na duze)
BigLetters
     SEC
     SBC  #'A'  ; "A"     ; czy klawisz A lub wiekszy
     CMP   NamesOnScreen              ; czy mniejszy lub równy iloœci plików widocznych na ekranie
     BCS   KeyboardProc    ; jesli spoza zakresu wracamy do czekania na klawisz
     ASL 
     TAX 
     LDA   FirstSectorsTable,X
     STA   $D4
     LDA   FirstSectorsTable+1,X 
     STA   $D5
     LDY  #$00
     LDA  ($D4),Y
     AND  #$20             ; sprawdzamy czy to klatalog czy plik
     BEQ   GOtoLoader     ; jesli plik to skaczemy do pracedury przygotowujacej loader
     ; a jesli katalog, pobieramy poczatek jego mapy sektorow i odczytujemy go na ekran
     LDY  #$02
     LDA  ($D4),Y 
     TAX
     DEY
     LDA  ($D4),Y
     TAY
     JMP   ReadDIR
SubDirText
     .BY "<SUB-DIR>"
GOtoLoader
     JSR   DiscChangeCheck   ; Sprawdzenie czy w miedzyczasie nie zostala zmieniona dyskietka
     BEQ   DiskNotChanged1
     JMP   ReadMainDir        ; jesli zmieniono to skok na poczatek programu i ponowny odczyt katalogu glownego
DiskNotChanged1
	 LDA   FolderTurbo
	 BEQ   SetTurboOFF
     LDA   SKSTAT   ; jesli jest Shift to odpowiednio ustawiamy flage przed samym zaladowaniem pliku !!!
	 and   #$08
     BNE   NoSHIFT
SetTurboOFF
     STA   USmode  ; tutaj mamy 0 w A wiec nie potrzeba LDA #0
NoSHIFT
     LDY  #$01
     LDA  ($D4),Y
     STA   .adr loader.FirstMapSectorNr	; przed przepisaniem
	 sta  blokDanychIO+$A   ; od razu do bloku IOCB
     INY
     LDA  ($D4),Y
     STA   .adr loader.FirstMapSectorNr+1	; przed przepisaniem
	 sta  blokDanychIO+$B   ; od razu do bloku IOCB
     INY
     LDA  ($D4),Y
     EOR  #$FF
     STA   .adr loader.tempToFileEndL
     INY
     LDA  ($D4),Y
     EOR  #$FF
     STA   .adr loader.ToFileEndH	; przed przepisaniem
     INY
     LDA  ($D4),Y
     EOR  #$FF
     STA   .adr loader.ToFileEndH+1	; przed przepisaniem
; wszystko zapamietane mozna robic mape sektorow....
; skompresowana mapa bedzie tworzona w buforze sektora katalogu
; czyli DirSectorBuff
; sektor mapy przed kompresja leci do DirMapSectorBuff
; UWAGA
; Zeby dzialala ta ladna procedura Bernaska mapa na poczatku musi
; zawierac rozkaz przeczytania pierwszego sektora!!!!!
CompressedMap = DirSectorBuff
; czytamy pierwszy sektor mapy
	 LDY #<DirMapSectorBuff
     LDX #>DirMapSectorBuff
	 Jsr ReadSector
; pobieramy numer pierwszego sektora pliku i od razu robimy wpis w mapie !!!
     LDA #00
	 STA CompressedMapCounter
	 STA CompressedMapCounter+1
	 JSR AddToCompressedMAP
     LDA DirMapSectorBuff+4
	 STA PrevFileSector
	 JSR AddToCompressedMAP
     LDA DirMapSectorBuff+5
	 sta PrevFileSector+1
	 JSR AddToCompressedMAP
 ; Inicjujemy liczniki
    .zpvar MapCounter,CompressedMapCounter, MapCounterMem .word =$80
	.zpvar PrevFileSector, MapPositionMem .word
	.zpvar SectorOffset .word
	.zpvar SectorsCounter .byte
     LDA #$00
	 STA MapCounter+1
	 STA SectorsCounter
	 lda #$06
	 STA MapCounter
GenerateCompressedMap
     CLC
	 LDA #<DirMapSectorBuff
	 ADC MapCounter
	 STA MAPPositionMem
	 LDA #>DirMapSectorBuff
	 ADC MapCounter+1
	 STA MAPPositionMem+1
	 LDX #0
	 LDY #1
 	 LDA (MAPPositionMem,x)
     ORA (MAPPositionMem),y
	 BEQ Sector00
	 SEC
	 LDA (MAPPositionMem,x)
	 SBC PrevFileSector
	 STA SectorOffset
	 LDA (MAPPositionMem),y
	 SBC PrevFileSector+1
	 STA SectorOffset+1
	 ; mamy odstep miedzy poprzednim a nastepnym sektorem
     BNE OffsetToBig
	 LDA SectorOffset
	 BMI OffsetToBig  ; max przeskok 127 sektorow
     CMP #$01
	 BNE JumpForward
	 ; kolejny sektor
	 ; zwiekszamy wiec licznik
	 inc SectorsCounter
	 LDA SectorsCounter
	 CMP #%01111111
	 BNE GetNextMapWord
	 ; tu licznik dotarl do konca zerujemy go
	 ; dodajemy wpis do skompresowanej mapy i gotowe
	 JSR AddToCompressedMAP
	 LDA #0
	 STA SectorsCounter
	 BEQ GetNextMapWord
; ominiecie wyznaczonej iloœci sektorów (w A)
JumpForward
     JSR FlushBuffer
     LDA SectorOffset
	 ORA #%10000000
	 JSR AddToCompressedMAP
     JMP GetNextMapWord
; wyznaczenie skoku do nowego sektora pliku
OffsetToBig
     JSR FlushBuffer
     LDA #0
	 JSR AddToCompressedMAP
	 LDY #00
	 LDA (MAPPositionMem),y
	 JSR AddToCompressedMAP
     LDY #01
	 LDA (MAPPositionMem),y
	 JSR AddToCompressedMAP
GetNextMapWord
 ; zapamietanie numeru obecnego sektora do porownania potem	 
	 LDY #00
	 LDA (MAPPositionMem),y
	 STA PrevFileSector
     INY
	 LDA (MAPPositionMem),y
	 STA PrevFileSector+1
Sector00
     ADW MapCounter #2
ops01
     ; CPW MapCounter {.adr loader.SecLen}   ; a to nie dziala
	 LDA MapCounter+1
	 CMP .adr loader.SecLen+1
	 bne noteqal01
	 LDA MapCounter
	 CMP .adr loader.SecLen	 
noteqal01
     JNE GenerateCompressedMap
; czytamy nastepny sektor mapy
     ; sprawdzmy czy nie koniec
     LDA DirMapSectorBuff
     ORA DirMapSectorBuff+1
	 BEQ EndMakingMap
     LDA DirMapSectorBuff
	 sta  blokDanychIO+$A
	 LDA DirMapSectorBuff+1
	 sta  blokDanychIO+$B
	 LDY #<DirMapSectorBuff
     LDX #>DirMapSectorBuff
	 Jsr ReadSector
	 ; zerujemy licznik mapy
     LDA #$00
	 STA MapCounter+1
	 lda #$04
	 STA MapCounter
     JMP GenerateCompressedMap
; dpisanie bajtu z A do mapy sektorow skompresowanej
AddToCompressedMAP
     PHA
	 ; wyliczamy adresa
	 CLC
	 LDA CompressedMapCounter
	 ADC #<CompressedMap
	 STA xxxxbla
	 LDA CompressedMapCounter+1
	 ADC #>CompressedMap
	 STA xxxxbla+1
	 PLA
xxxxbla=*+1
	 STA $FFFF
	 INC CompressedMapCounter
	 BNE noinc013
	 INC CompressedMapCounter+1
noinc013
     RTS
FlushBuffer
     LDA SectorsCounter
	 BEQ NoFlush
	 JSR AddToCompressedMAP
	 LDA #0
     STA SectorsCounter
NoFlush
     RTS
EndMakingMap
     JSR FlushBuffer
LoaderGo
     LDY  #$00
     STY   COLDST
     LDA  #$01
     STA   BOOT
	 LDX  $700
	 CPX  #'S'   ; czy sparta, bo jesli tak, to wylaczamy carta
	 BNE  NoRunFromDOS
     STA   $03F8  ; to wylaczalo BASIC !!!
;	 STA   $D5EC  ; to wylacza SpartaDOS X
;	 STY   GINTLK ; i mowi OSowi, ze carta nigdy nie bylo :)
NoRunFromDOS
     LDA  #<AfterWormStart
     STA   DOSINI
     LDA  #>AfterWormStart
     STA   DOSINI+1
;     LDA  #>JRESETCD
;     STA   DOSVEC+1
;     LDA  #<JRESETCD
;     STA   DOSVEC
	 ; zapamietanie stanu urzadzen PBI
	 LDA PDVMASK
	 STA PDVMASKtemp
     JMP   JRESETWM        ; wymuszenie cieplego resetu - z ustawionymi odpowiednimi prametrami powrotu
AfterWormStart
     ; wyznaczamy MEMlo, najpierw dodajemy dlugosc bufora na sektor
	 ; do koncowego adresu naszej procedury
	 ; odtworzenie stanu PBI
	 LDA PDVMASKtemp
	 STA PDVMASK
;     JSR EditorOpen   ; zamiast cieplego startu czyszczenie ekranu
	 CLC
     LDA   #<TempMEMLO
	 ADC   .adr loader.SecLen
     STA   MEMLO
	 STA   CompressedMapPos
;	 STA   pointerMov2b-1   ; przygotowanie procedury przepisujacej
;     STA   APPMHI           ; wlasciwie tu powinno byc to samo co po pozniejszym zwiekszeniu MEMLO !!!!
     LDA   #>TempMEMLO
     ADC   .adr loader.SecLen+1
     STA   MEMLO+1
	 STA   CompressedMapPos+1
;	 STA   pointerMov2b
;     STA   APPMHI+1
	 ; tu w MEMLO mamy pierwszy wolny bajt za buforem sektora
	 ; jest to jednoczesnie adres umieszczenia skompresowanej
	 ; mapy sektorow pliku dla loadera ale MINUS 1
	 DEW   CompressedMapPos
	 ; teraz trzeba dodac dlugosc skompresowanej mapy bitowej
	 ; i wpisac w procedurze przepisujacej turbo (modyfikacja kodu)
	 CLC
	 LDA MEMLO
;	 ADC CompressedMapCounter
;	 STA MEMLO
	 STA TurboRelocADDR
	 LDA MEMLO+1
;	 ADC CompressedMapCounter+1
;	 STA MEMLO+1
	 STA TurboRelocADDR+1
     LDA  #<JTESTROM
     STA   DOSINI
     LDA  #>JTESTROM
     STA   DOSINI+1
;	 DEC   BOOT  ; przestawiamy z 2 na 1 (z CASINI na DOSINI)
;     INC   $033D  ; bajty kontrolne zimnego startu
;     INC   $033E  ; zmiana ich wartosci wymusza
;     DEC   $033F  ; zimny start po RESET  (blokujemy bo niektore gry startujace przez zmiane wektorow i skok do reset nie dzialaja)
     LDX  #$00
	 STX   WARMST    ; zerowanie WARMST informuje programy ze byl zimny reset a nie cieply (The Last Starfighter)
;	 STX   BOOT
; przepisanie glownej procedury ladujacej - DWIE STRONY pamieci
moveloop1
     LDA   movedproc,X
     STA   $0700,X 
     LDA   movedproc+$0100,X
     STA   $0800,X
     INX
     BNE   moveloop1
; przepisanie skompresowanej mapy sektorow pliku za bufor sektora
/* moveloop2
     DEW   CompressedMapCounter    ; zmiejszamy licznik dlugasci mapy
pointerMov2a=*+2
	 LDA   CompressedMap,x     ; kod samomodyfikujacy sie
pointerMov2b=*+2
     STA   $FFFF,x              ; kod samomodyfikujacy sie
	 LDA   CompressedMapCounter
	 AND   CompressedMapCounter+1
     CMP   #$FF                      ; jesli licznik = -1 to przepisalismy cala mape !!!
	 BEQ   SectorMapReady
  	 INX
	 BNE   moveloop2
	 inc   pointerMov2a
	 inc   pointerMov2b
	 bne   moveloop2 
SectorMapReady
 */
     JSR   ADDspeedProc   ; procedura relokujaca procedury turbo (jesli potrzebne) i podnaszaca odpowiednio MEMLO
	 JSR   MEMLOprint     ; wyswietlenie wartosci MEMLO (moze wyswietlac i inne rzeczy)

     LDX  #$00
     TXA
; wstepne czyszczenie (reszte RAM czysci procedura ladujaca - dzieki czemu czysci tez program glowny)
ClearLoop1
     STA   $0100,X 		; STOS !!!
     STA   $0400,X			; bufor magnetofonu (128) i obszar zarezerwowany?? (drugie 128b)
     STA   $0500,X 
     STA   $0600,X 
     CPX  #$80             ;tylko ponad $80
     BCC   NoZpage
     STA   $00,X           ; czyli polowa strony zerowej
NoZpage
     INX
     BNE   ClearLoop1
     LDX  #$FF
     TXS 					; "wyzerowanie wskaznika STOSU
     
     ; a tutaj otwieramy kanal 1 CIO do odczytu 

      LDX #16 ; kanal 1
      LDA #COPN ; rozkaz OPEN
      STA ICCOM,X ; COMMAND
        LDA #$04    ; READ
        STA ICAUX1,X
        LDA #$00
        STA ICAUX2,X
      LDA # <FileToOpen
      STA ICBADR,X
      LDA # >FileToOpen
      STA ICBADR+1,X
      JSR CIO
	 
     JMP   loader.LoadStart     ; po przepisaniu 
FileToOpen
     .BYTE 'H:SCORCH.XEX',0
; Sprawdzenie odpowiednich flag i przepisanie za loaderem procedury obslugi odpowiedniego Turba
; na koniec odpowiednie zmodyfikowanie MEMLO
ADDspeedProc
     LDA   USmode
	 beq   NoHappyLoader
; wyznaczamy offset procedury
    SEC
	LDA #<HappyUSMovedProc
	SBC MEMLO
	STA HappyOffset
	LDA #>HappyUSMovedProc
	SBC MEMLO+1
	STA HappyOffset+1

	LDY #0
	LDX #[$A-1]  ;xjsrA - the last
	; relokujemy skoki pod offset z MEMLO
HappyRelocate
	SEC
	LDA xjsrTableL,x
	STA SecBuffer
	LDA xjsrTableH,x
	STA SecBuffer+1
	LDA (SecBuffer),y
	SBC HappyOffset
	STA (SecBuffer),y
	INY
	LDA (SecBuffer),y
	SBC HappyOffset+1
	STA (SecBuffer),y
	DEY
	DEX
	BPL HappyRelocate

     LDX  #[EndHappyUSProc-HappyUSMovedProc-1]
label72x
     LDA   HappyUSMovedProc,X
TurboRelocADDR=*+1
     STA   $0A00,X
     DEX
	 CPX #$FF
     BNE   label72x
   LDY   #[EndHappyUSProc-HappyUSMovedProc]
     LDX   #$00
; Zwiekszenie Memlo o dlugosc procedury i przelaczenie skoku do niej.
label73
     TYA
     CLC
     ADC   MEMLO
     STA   MEMLO
     TXA
     ADC   MEMLO+1
     STA   MEMLO+1
     LDA   TurboRelocADDR
     STA   loader.SioJMP+1               ; po przepisaniu
     LDA   TurboRelocADDR+1
     STA   loader.SioJMP+2             ; po przepisaniu
NoHappyLoader
     RTS



; UWAGA !!!!!!!!!!!!!!
; Ta procedura ma maksymalna dlugosc jaka moze miec!!!!!
; powiekszenie jej O BAJT spowoduje ze przekroczy strone
; i nie przepisze sie prawidlowo na swoje miejsce !!!!!	 
HappyUSMovedProc ;

	LDA DBUFA
	STA SecBuffer
	LDA DBUFA+1
	STA SecBuffer+1

	LDA DBYT
	STA SecLenUS

	SEI
	TSX
	STX StackCopy
	LDA #$0D
	STA CRETRYZ
	 ;command retry on zero page
CommandLoop
HappySpeed = *+1
	LDA #$28 ;here goes speed from "?"
	STA AUDF3
	LDA #$34
	STA PBCTL ;ustawienie linii command
	LDX #$80
DelayLoopCmd
	DEX
	BNE DelayLoopCmd
	STX AUDF4 ; zero
	STX TransmitError
;	pokey init
	LDA #$23
xjsr1	JSR SecTransReg
	;

	CLC
	LDA DDEVIC    ; tu zawsze jest $31 (przynajmniej powinno)
	ADC DUNIT     ; dodajemy numer stacji
	ADC #$FF	; i odejmujemy jeden (jak w systemie Atari)
	STA CheckSum
	STA SEROUT
	LDA DCOMND
xjsr2	JSR PutSIOByte
	LDA DAUX1
xjsr3	JSR PutSIOByte
	LDA DAUX2
xjsr4	JSR PutSIOByte
	LDA CheckSum
xjsr5	JSR PutSIOByte

waitforEndOftransmission
	LDA IRQST
	AND #$08
	BNE waitforEndOftransmission

	LDA #$13
xjsr6	JSR SecTransReg

	LDA #$3c
	STA PBCTL ;command line off
; two ACK's
	LDY #2
DoubleACK
xjsr7	JSR GetSIOByte
	CMP #$44
	BCS ErrorHere
	DEY
	BNE DoubleACK

	;ldy #0
	STY CheckSum
ReadSectorLoop
xjsr8	JSR GetSIOByte
	STA (SecBuffer),y
xjsr9	JSR AddCheckSum
	INY
	CPY SecLenUS
	BNE ReadSectorLoop

xjsrA	JSR GetSIOByte
	CMP CheckSum
	BEQ EndOfTransmission
;error!!!
ErrorHere
	LDY #$90
	STY TransmitError
	LDX StackCopy
	TXS
	DEC CRETRYZ
	BNE CommandLoop

EndOfTransmission
	LDA #0
	STA AUDC4
	LDA IRQENS
	STA IRQEN
	CLI
	LDY TransmitError
	RTS

SecTransReg
	STA SKCTL
	STA SKSTRES
	LDA #$38
	STA IRQEN
	LDA #$28
	STA AUDCTL
	LDA #$A8
	STA AUDC4
	RTS

PutSIOByte
	TAX
waitforSerial
	LDA IRQST
	AND #$10
	BNE waitforSerial

	STA IRQEN
	LDA #$10
	STA IRQEN

	TXA
	STA SEROUT

AddCheckSum
	CLC
	ADC CheckSum
	ADC #0
	STA CheckSum
	RTS

GetSIOByte
	LDX #10  ;acktimeout
ExternalLoop
	LDA #0
	STA looperka
InternalLoop
	LDA IRQST
	AND #$20
	BEQ ACKReceive
	DEC looperka
	BNE InternalLoop
	DEX
	BNE ExternalLoop
	BEQ ErrorHere
ACKReceive
	; zero we have now
	STA IRQST
	LDA #$20
	STA IRQST
	LDA SKSTAT
	STA SKSTRES
	AND #$20
	BEQ ErrorHere
	;
	LDA SERIN
	RTS
EndHappyUSProc


; Rozkaz DCB "?" pobierrajacy predkosc dla Happy i US-Doubler
blokDanychIO_GetUSSpeed
     .BY $31,$01,"?",$40
     .WO HappySpeed
     .BY $07,$00,$01,$00,$00,$0A
DirMapEnd
     JMP   label75
label39
     STA   $DA 
     LDA   CurrentFileInfoBuff
     STA   $DB
     LDA   CurrentFileInfoBuff+1
     STA   $DC
     JSR   DiscChangeCheck   ; Sprawdzenie czy w miedzyczasie nie zostala zmieniona dyskietka
     BEQ   DiscNotChanged2
     PLA
     PLA
     JMP   ReadMainDir
DiscNotChanged2
     ; odczyt sektora mapy wskazywanego przez DirMapSec
     LDA   DirMapSect
     STA   blokDanychIO+10
     LDA   DirMapSect+1
     STA   blokDanychIO+11
     ORA   blokDanychIO+10
     BEQ   DirMapEnd
     LDX  #>DirMapSectorBuff
     LDY  #<DirMapSectorBuff
     JSR   ReadSector
	 ; zostal wczytany kolejny sektor mapy nalezy wiec zapamietac we wskazniku DirMapSec
	 ; numer nastepnego sektora mapy. To 2 pierwsze bajty z bufora na sektor mapy
     LDA   DirMapSectorBuff
     STA   DirMapSect
     LDA   DirMapSectorBuff+1
     STA   DirMapSect+1
     LDA  #$04 
	 STA   InMapPointer		; --
	 LDA  #$00					; --
	 STA   InMapPointer+1		; --
label80
	 LDY   InMapPointer		; --
     CPY   .adr loader.SecLen	; przed przepisaniem
	 BNE   NoNextMapSector		; --
	 LDA   InMapPointer+1			; --
	 CMP   .adr loader.Seclen+1	; --
     BEQ   DiscNotChanged2
NoNextMapSector
	; pobranie numeru nastepnego sektora katalogu z mapy sektorow
	 ; tymczasowy adrez na ZP
	 LDA  #<DirMapSectorBuff		; --
	 STA   TempZP					; --
	 CLC							; --
	 LDA  #>DirMapSectorBuff		; --
	 ADC   InMapPointer+1			; --
	 STA   TempZP+1				; --
     LDA   (TempZP),Y
     STA   blokDanychIO+10
     INY
     LDA   (TempZP),Y
     STA   blokDanychIO+11
     ORA   blokDanychIO+10 
     BEQ   label75
	 ; i zwiekszenie wskaznika mapy o 2
     INY
	 STY   InMapPointer
	 BNE   NoIncH				; --
	 INC   InMapPointer+1		; --
NoIncH
     LDA   MEMTOP
     SEC
     SBC   CurrentFileInfoBuff
     LDA   MEMTOP+1
     SBC   CurrentFileInfoBuff+1
     BEQ   label75
     LDY   CurrentFileInfoBuff
     LDX   CurrentFileInfoBuff+1
     JSR   ReadSector
     LDA   $D4
     ORA   $D5
     BNE   label79
     LDY  #$03
     LDA  (CurrentFileInfoBuff),Y
     STA   $D4
     INY
     LDA  (CurrentFileInfoBuff),Y
     STA   $D5
     INY
     LDA  (CurrentFileInfoBuff),Y
     BEQ   label79
     LDA  #$FF
     STA   $D4
     STA   $D5
label79
     LDA   CurrentFileInfoBuff
     CLC
     ADC   .adr loader.SecLen	; przed przepisaniem
     STA   CurrentFileInfoBuff
     LDA   CurrentFileInfoBuff+1
     ADC   .adr loader.SecLen+1	; przed przepisaniem
     STA   CurrentFileInfoBuff+1
     LDA   $D4
     SEC
     SBC   .adr loader.SecLen	; przed przepisaniem
     STA   $D4
     LDA   $D5
     SBC   .adr loader.SecLen+1	; przed przepisaniem
     STA   $D5
     BCS   label80
     LDA   CurrentFileInfoBuff
     CLC 
     ADC   $D4 
     STA   CurrentFileInfoBuff
     LDA   CurrentFileInfoBuff+1
     ADC   $D5
     STA   CurrentFileInfoBuff+1
label75
     LDA   $DC
     CMP   CurrentFileInfoBuff+1
     BCC   label81 
     BNE   label82
     LDA   $DB
     CMP   CurrentFileInfoBuff
     BCC   label81
     BNE   label82
     RTS
label81
     LDA   $DB
     CLC
     ADC   $DA
     STA   $DB
     BCC   label75
     INC   $DC
     JMP   label75
label82
     LDA   $DB
     SEC
     SBC   $DA
     STA   CurrentFileInfoBuff
     LDA   $DC
     SBC  #$00
     STA   CurrentFileInfoBuff+1
     RTS
; odczyt bloku PERCOM i ustalenie rozmiaru pierwszego sektora
ReadPERCOM
     LDA  #$04
     STA   DiskRetryCount
ReadPERCOMretry
     LDY  #<blokDanychIO_PERCOM
     LDX  #>blokDanychIO_PERCOM
     JSR   Table2DCB
     JSR   GoSIO
     BMI   PercomError
	 ; blok odczytany - ustawmy dlugosc 1 sektora
	 LDA   PERCOMdata+6
	 CMP   #$01			; jesli dlugosc sektora to 256b - pierwszy sektor ustawiamy na 128
	 BEQ   Set1Sect128  ; w pozostalych wypadkach zostawiamy jak jest
     RTS 
PercomError
     DEC   DiskRetryCount
     BNE   ReadPERCOMretry
	 ; blok nieodczytany - dlugosc 1 sektora na $80
Set1Sect128
     LDA  #$00
	 STA   PERCOMdata+6
	 LDA  #$80
	 STA   PERCOMdata+7
	 RTS
blokDanychIO_PERCOM
     .BY $31,$01,$4E,$40
     .WO PERCOMdata
     .BY $0A,$00,12,$00,$01,$00
; wczytuje pierwszy sektor dysku pod adres zawarty w X(starszy) i Y(mlodszy)
ReadFirstSect
     LDA  #$01
     STA   blokDanychIO+10 
     LDA  #$00 
     STA   blokDanychIO+11
	 LDA   PERCOMdata+6
	 STA   blokDanychIO+9		; --- obsluga sektorow ponad 256b
     LDA   PERCOMdata+7
     JMP   ReadSector1
; Wczytuje sektror ustalajac jego dlugosc na podstawie blokDanychIO_Loader (SecLen)
; reszta danych jak nizej (A nie wazne)
ReadSector
     LDA   .adr loader.SecLen+1		; --- obsluga sektorow ponad 256b
	 STA   blokDanychIO+9			; --- obsluga sektorow ponad 256b
     LDA   .adr loader.SecLen	; przed przepisaniem
ReadSector1
     STA   blokDanychIO+8
     STX   blokDanychIO+5
     STY   blokDanychIO+4 
     LDA  #$04
     STA   DiskRetryCount
DiskReadRetry
     LDY  #<blokDanychIO
     LDX  #>blokDanychIO
     JSR   Table2DCB
     JSR   GoSIO
     BMI   label85
     RTS 
label85
     DEC   DiskRetryCount
     BNE   DiskReadRetry 
     PLA
     PLA
     JMP   ErrorDisplay
blokDanychIO
     .BY $31,$01,$52,$40
     .WO DirMapSectorBuff
     .BY $0A,$00,$80,$00,$01,$00
DiskRetryCount
     .BY $00
PrintXY
     PLA
     STA   $C8
     PLA
     STA   $C9
     LDA  #$00
     STA   $DF
     JSR   label87
     PHA
     JSR   label87
     STA   $DE
     ASL
     ASL
     CLC
     ADC   $DE
     ASL
     ASL
     ROL   $DF
     ASL
     ROL   $DF
     CLC
     ADC   SAVMSC
     STA   $DE
     LDA   $DF
     ADC   SAVMSC+1
     STA   $DF
     PLA
     TAY
label92
     JSR   label87
     CMP  #$00
     BEQ   label88
     CMP  #$7D
     BEQ   label89
     LDX  #$00
     STX   $E0 
     CMP  #$80
     ROR   $E0
     AND  #$7F
     CMP  #$20 
     BCS   label90 
     ORA  #$40
     BNE   label91
label90
     CMP  #$60
     BCS   label91
     SEC
     SBC  #$20
label91
     ORA   $E0
     STA  ($DE),Y
     INY
     JMP   label92 
label89
     TYA
     PHA
     LDA   SAVMSC
     STA   $E0
     LDA  #$03
     TAX
     CLC 
     ADC   SAVMSC+1
     STA   $E1
     LDY  #$BF
     LDA  #$00
label93
     STA  ($E0),Y
     DEY
     CPY  #$FF
     BNE   label93
     DEC   $E1
     DEX
     BPL   label93
     PLA
     TAY
     JMP   label92
label88
     LDA   $C9
     PHA
     LDA   $C8
     PHA 
     RTS
label87
     INC   $C8
     BNE   label94
     INC   $C9
label94
     LDX  #$00 
     LDA  ($C8,X) 
     RTS
GoErrorDisp
     JMP   ErrorDisplay
; Skok do Sio lub procedury Turbo
GoSIO
     LDY  USmode
     BEQ  StandardSpeed
     JMP  HappyUSMovedProc ; mozna skakac do tej procki
StandardSpeed
     JMP   JSIOINT
; Przepisuje 12 bajtow z adresy podanego w X(starszy) i Y(mlodszy)
; do bloku kontroli transmisji szeregowej DCB
Table2DCB
     STY   IOtableAddr+1
     STX   IOtableAddr+2
     LDX  #$0B
IOtableAddr
     LDA   $FFFF,X 
     STA   DDEVIC,X
     DEX 
     BPL   IOtableAddr
     RTS
Close1
     LDX  #$10 
CloseX
     LDA  #$0C
     STA   ICCMD,X
     JMP   JCIOMAIN 
GetKey
     LDX  #$10
     LDA  #$03
     STA   ICCMD,X 
     LDA  #$04
     STA   ICAX1,X
     LDA  #$00
     STA   ICAX2,X
     STA   ICBUFL+1,X
     LDA  #$FF
     STA   ICBUFL,X
     LDA  #<Kdriver
     STA   ICBUFA,X
     LDA  #>Kdriver
     STA   ICBUFA+1,X
     JSR   JCIOMAIN
     BMI   GKeyError
     LDX  #$10
     LDA  #$00
     STA   ICBUFL,X
     STA   ICBUFL+1,X
     LDA  #$07
     STA   ICCMD,X
     JSR   JCIOMAIN
     BMI   GKeyError
     PHA
     JSR   Close1
     BMI   GKeyError
     PLA 
     RTS
GKeyError
     JMP   GoErrorDisp
Kdriver
     .BY "K:",$9B
DiscChangeCheck
     LDY  #<DirMapSectorBuff
     LDX  #>DirMapSectorBuff
     JSR   ReadFirstSect
     LDX  #$7F
label98
     LDA   FirstSectorBuff,X
     CMP   DirMapSectorBuff,X
     BNE   ChangedD
     DEX 
     BPL   label98
     LDA  #$00
ChangedD
     RTS
     ; obsluga gwiazdki
	 ; w komorkach $D4 $D5 jest adres linii z pliku MSDOS.DAT zaczynajacej sie od *
	 ; w Y jest ) - X moze lepiej nie ruszac :)
Asteriks
     LDY #11  ; pierwszy HEX za nazwa pliku (czyli pierwsze znaki dlugiej nazwy)
	 JSR GetHexNumber
	 STA COLPF1S   ; literki
     INY
	 JSR GetHexNumber
	 STA COLPF2S   ; tlo
	 INY
	 JSR GetHexNumber
	 STA COLBAKS   ; ramka
	 INY
	 JSR GetHexNumber
	 STA FolderTurbo  ; znacznik turbo (00 bez turbo , 01 tak jak bylo)
	 RTS
	 ; pobiera z pod adresu wskazanago przez ($D4),Y dwa kolejne znaki liczby HEX
	 ; i zamienia na bajt w A
GetHexNumber
	 JSR GetHEX4bits
	 ASL
	 ASL
	 ASL
	 ASL
	 STA TempZP ; zmienna potrzebna tylko przy jakims chwilowym obliczeniu, wiec tu sie przyda.
	 INY
	 JSR GetHEX4bits
     ORA TempZP
	 RTS
GetHEX4bits	 
	 LDA ($D4),Y
	 SEC
	 SBC #'0'
	 CMP #$0A ; sprawdzmy czy cyfra
	 BCC IsNumber
	 SBC #7   ; Carry jest ustawiony, a miedzy 9 i A jest jeszcze 7 znakow
IsNumber
     RTS
	 ; Ustawia numer satcji wg A
SeTDriveNR
	 CMP #$09
	 BCS SetDriveLetter  ; jesli wieksze lub rowne od 9 to litera zamiast cyfry
	 JSR SeTblokDanychDrive
     CLC
     ADC #'0'+$80   ; dodajemy do kodu cyfry 0
	 STA DriveDisp1
	 LDA #'D'+$80    ; literka D przed numerem napedu
	 STA DriveDisp1-1
     RTS
SeTDriveLetter
	 JSR SeTblokDanychDrive
     CLC
     ADC #'A'+$7F   ; $7f bo to $80 - 1 , a kod litery A trzeba zmniejszyc o 1 i dodac numer napedu
	 STA DriveDisp1
	 LDA #' '+$80    ; literka D przed numerem napedu - tutaj spacja
	 STA DriveDisp1-1
     RTS
SeTblokDanychDrive
     STA .adr loader.blokDanychIO_Loader+1	; przed przepisaniem
     STA blokDanychIO+1
     STA blokDanychIO_GetUSSpeed+1
	 STA blokDanychIO_PERCOM+1
     RTS
; wyswietlenie na czystm ekranie info zaraz przed rozpoczeciem ladowania pliku	 
MEMLOprint
     LDA MEMLO
     PHA 
     LSR 
     LSR 
     LSR
     LSR
     JSR   bin2AsciiHex 
     STA   MEMLOvalue+2
     PLA
     JSR   bin2AsciiHex 
     STA   MEMLOvalue+3
     LDA MEMLO+1
     PHA 
     LSR 
     LSR 
     LSR
     LSR
     JSR   bin2AsciiHex 
     STA   MEMLOvalue
     PLA
     JSR   bin2AsciiHex 
     STA   MEMLOvalue+1
     JSR PrintXY
     .BY 28,23
     .BY "MEMLO: $"
MEMLOvalue
	 .BY "0000"
     .BY $00	 
	 RTS
	 
; Tablica adresow wszystkich rozkazow skokow w procedurze Turbo

xjsrTableL
	.BY <[xjsr1+1],<[xjsr2+1],<[xjsr3+1]
	.BY <[xjsr4+1],<[xjsr5+1]
	.BY <[xjsr6+1],<[xjsr7+1],<[xjsr8+1]
	.BY <[xjsr9+1],<[xjsrA+1]
xjsrTableH
	.BY >[xjsr1+1],>[xjsr2+1],>[xjsr3+1]
	.BY >[xjsr4+1],>[xjsr5+1]
	.BY >[xjsr6+1],>[xjsr7+1],>[xjsr8+1]
	.BY >[xjsr9+1],>[xjsrA+1]
; miejsce na wyliczony offset o jaki przesuwamy procedure
HappyOffset
    .WO $0000
; kody gestosci do wyswietlenia na ekranie - takie poziome kreski od chudej do grubej :)
DensityCodes
	.by +$80,"sdq"
	;.by "SDQ"
    ;.by $0e,$15,$a0
ONtext
    .BY +$80,"ON "
OFFtext
    .BY +$80,"OFF"
; miejsce na przechowanie stanu urzadzen PBI (przez reset)
PDVMASKtemp
	.BY $00
; miejsce na blok PERCOM
PERCOMdata
; miejsce na tablice trzymajaca numery pierwszych sektorow map bitoeych plikow aktualnie wyswietlanych na liscie
FirstSectorsTable=*+12 ; omijamy 12b na percom
     ; zostawiamy $30 bajtow wolnego
	 
FirstSectorBuff=[[>[*+$2f+12]]+1]*$100 ; ($80 bajtow) ustawienie na granicy strony ale po ominieciu $30 i 12 bajtow
ProgramEnd=FirstSectorBuff
DirMapSectorBuff=FirstSectorBuff+$80 ; tutaj aktualny sektor mapy sektorow katalogu
DirSectorBuff=FirstSectorBuff+$280 ; tutaj sektor katalogu
FirstRun
; odnotowujemy stan Shift z Bootowania
     LDA   SKSTAT 
	 and   #$08
     BNE   NoSHIFTboot  
     STA   BootShift   ; w A jest 0 wiec nie trzeba LDA #0
NoSHIFTboot
;  Sprawdzamy czy jest basic i ustawiamy status na ekranie
     LDA PORTB
	 AND #$02
	 BNE BrakBasica
	 ; jest Basic
	 LDY #$2
BASstatprint
	 LDA ONtext,y
	 STA BASstatus,y
	 DEY
	 bpl BASstatprint
BrakBasica	 
;  Sprawdzamy istnienie QMEGa
     ldy #$06  ; bo 6 znaków w ROMie testujemy
testQMEGloop
	 LDA $C001,y
	 CMP QMEGstring,y
	 bne brakQMEGa
	 dey
	 bpl testQMEGloop
	 ; jest QMEG 
	 LDA #0
	 STA QMEG
	 LDY #$2
Qstatprint
	 LDA ONtext,y
	 STA QMEGstatus,y
	 DEY
	 bpl Qstatprint
brakQMEGa
     ; kombinacja z dodaniem identyfikatara i odjeciem 1 - bo tak dziwnie OS robi
     LDA DDEVIC
     clc	 
	 ADC DUNIT
     sec
     SBC #$01
     AND #$0F	 ; zapamietanie numeru urzadzenia
	 STA BootDrive
     JSR SeTDriveNR
	 JSR EditorOpen
     JMP mainprog
QMEGstring
	.BY "QMEG-OS",0
	.BY "HS procedures for Happy/US-Doubler, big sectors loader and compressed file map by Pecus & Pirx 2010-05-26"
	;.OPT List
	

     org $02e0
     .WO LoaderGo
    ; .WO START 
	; na koniec pliku dwa bajty $00 bez naglowka (dla bootloadera)
;    OPT h-
;	org $0000
;	.WO $0000
	