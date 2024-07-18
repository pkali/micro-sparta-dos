    .TITLE "IOMAC.LIB -- FTe system I/O macros"
    .PAGE "   Support Macros"
    .IF .NOT .DEF IOCB
      .ERROR "You must include SYSEQU.M65 ahead of this!!"
      .ENDIF 
;
; These macros are called by the actual I/O macros
; to perform the rudimentary register load functions.
;
;
; MACRO:  @CH
;
; Loads IOCB number (parameter 1) into X register.
;
; If parameter value is 0 to 7, immediate channel number
;   is assumed.
;
; If parameter value is > 7 then a memory location
;   is assumed to contain the channel number.
;
    .MACRO @CH 
    .IF %1>7
      LDA %1
      ASL A
      ASL A
      ASL A
      ASL A
      TAX 
      .ELSE 
      LDX #%1*16
      .ENDIF 
    .ENDM 
;
;
; MACRO:  @CV
;
; Loads Constant or Value into accumultor (A-register)
;
; If value of parameter 1 is 0-255, @CV
; assumes it's an (immediate) constant.
;
; Otherwise the value is assumed to
; be a memory location (non-zero page).
;
;
;
    .MACRO @CV 
    .IF %1<256
      LDA #%1
      .ELSE 
      LDA %1
      .ENDIF 
    .ENDM 
;
;
;
;
; MACRO:  @FL
;
; @FL is used to establish a filespec (file name)
;
; If a literal string is passed, @FL will
; generate the string in line, jump
; around it, and place its address
; in the IOCB pointed to by the X-register.
;
; If a non-zero page label is passed
; the MACRO assumes it to be the label
; of a valid filespec and uses it instead.
;
;
;
    .MACRO @FL 
    .IF %1<256
      JMP *+%1+4
@F    .BYTE %$1,0
      LDA # <@F
      STA ICBADR,X
      LDA # >@F
      STA ICBADR+1,X
      .ELSE 
      LDA # <%1
      STA ICBADR,X
      LDA # >%1
      STA ICBADR+1,X
      .ENDIF 
    .ENDM 
    .PAGE "   XIO macro"
;
; MACRO:  XIO
;
;  FORM:  XIO cmd,ch[,aux1,aux2][,filespec]
;
; ch is given as in the @CH macro
; cmd, aux1, aux2 are given as in the @CV macro
; filespec is given as in the @FL macro
;
; performs familiar XIO operations with/for OS/A+
;
; If aux1 is given, aux2 must also be given
; If aux1 and aux2 are omitted, they are set to zero
; If the filespec is omitted, "S:" is assumed
;
    .MACRO XIO 
    .IF %0<2 .OR %0>5
      .ERROR "XIO: wrong number of arguments"
      .ELSE 
       @CH  %2
       @CV  %1
      STA ICCOM,X ; COMMAND
      .IF %0>=4
         @CV  %3
        STA ICAUX1,X
         @CV  %4
        STA ICAUX2,X
        .ELSE 
        LDA #0
        STA ICAUX1,X
        STA ICAUX2,X
        .ENDIF 
      .IF %0=2 .OR %0=4
         @FL  "S:"
        .ELSE 
@@IO    .=  %0
         @FL  %$(@@IO)
        .ENDIF 
      JSR CIO
      .ENDIF 
    .ENDM 
    .PAGE "   OPEN macro"
;
; MACRO:  OPEN
;
;  FORM:  OPEN ch,aux1,aux2,filespec
;
; ch is given as in the @CH macro
; aux1 and aux2 are given as in the @CV macro
; filespec is given as in the @FL macro
;
; will attempt to open the given file name on
; the given channel, using the open "modes"
; specified by aux1 and aux2
;
    .MACRO OPEN 
    .IF %0<>4
      .ERROR "OPEN: wrong number of arguments"
      .ELSE 
      .IF %4<256
         XIO  COPN,%1,%2,%3,%$4
        .ELSE 
         XIO  COPN,%1,%2,%3,%4
        .ENDIF 
      .ENDIF 
    .ENDM 
    .PAGE "   BGET and BPUT macros"
;
; MACROS: BGET and BPUT
;
;   FORM: BGET ch,buf,len
;         BPUT ch,buf,len
;
; ch is given as in the @CH macro
; len is ALWAYS assumed to be an immediate
;   and actual value...never a memory address
; buf must be the address of an appropriate
;   buffer in memory
;
; puts or gets length bytes to/from the
;   specified buffer, uses binary read/write
;
;
; first: a common macro
;
    .MACRO @GP 
     @CH  %1
    LDA #%4
    STA ICCOM,X
    LDA # <%2
    STA ICBADR,X
    LDA # >%2
    STA ICBADR+1,X
    LDA # <%3
    STA ICBLEN,X
    LDA # >%3
    STA ICBLEN+1,X
    JSR CIO
    .ENDM 
;
    .MACRO BGET 
    .IF %0<>3
      .ERROR "BGET: wrong number of parameters"
      .ELSE 
       @GP  %1,%2,%3,CGBINR
      .ENDIF 
    .ENDM 
;
    .MACRO BPUT 
    .IF %0<>3
      .ERROR "BPUT: wrong number of parameters"
      .ELSE 
       @GP  %1,%2,%3,CPBINR
      .ENDIF 
    .ENDM 
;
    .PAGE "   PRINT macro"
;
; MACRO:  PRINT
;
;  FORM:  PRINT ch[,buffer[,length]]
;
; ch is as given in @CH macro
; if no buffer, prints just a RETURN
; if no length given, 255 assumed
;
; used to print text.  To print text without RETURN,
; length must be given.  See OS/A+ manual
;
; EXCEPTION: second parameter may be a literal
;  string (e.g., PRINT 0,"test"), in which
;  case the length (if given) is ignored.
;
    .MACRO PRINT 
    .IF %0<1 .OR %0>3
      .ERROR "PRINT: wrong number of parameters"
      .ELSE 
      .IF %0>1
        .IF %2<128
          JMP *+4+%2
@IO       .BYTE %$2,$9B
           @GP  %1,@IO,%2+1,CPTXTR
          .ELSE 
          .IF %0=2
             @GP  %1,%2,255,CPTXTR
            .ELSE 
             @GP  %1,%2,%3,CPTXTR
            .ENDIF 
          .ENDIF 
        .ELSE 
        JMP *+4
@IO     .BYTE $9B
         @GP  %1,@IO,1,CPTXTR
        .ENDIF 
      .ENDIF 
    .ENDM 
;
    .PAGE "   INPUT macro"
;
; MACRO:  INPUT
;
;  FORM:  INPUT ch,buf,len
;
; ch is given as in the @CH macro
; buf MUST be a proper buffer address
; len may be omitted, in which case 255 is assumed
;
; gets a line of text input to the given
;   buffer, maximum of length bytes
;
    .MACRO INPUT 
    .IF %0<2 .OR %0>3
      .ERROR "INPUT: wrong number of parameters"
      .ELSE 
      .IF %0=2
         @GP  %1,%2,255,CGTXTR
        .ELSE 
         @GP  %1,%2,%3,CGTXTR
        .ENDIF 
      .ENDIF 
    .ENDM 
    .PAGE "   CLOSE macro"
;
; MACRO:  CLOSE
;
;  FORM:  CLOSE ch
;
; ch is given as in the @CH macro
;
; closes channel ch
;
    .MACRO CLOSE 
    .IF %0<>1
      .ERROR "CLOSE: wrong number of parameters"
      .ELSE 
       @CH  %1
      LDA #CCLOSE
      STA ICCOM,X
      JSR CIO
      .ENDIF 
    .ENDM 
;
;;;;;;;;;;; END OF IOMAC.LIB ;;;;;;;;;;;;
;
