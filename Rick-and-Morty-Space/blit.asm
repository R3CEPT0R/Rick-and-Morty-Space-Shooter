; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 3
;;  AUTHOR: LENIN ESTRADA
;   NetID: lae4127
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
include trig.inc
include blit.inc

.DATA	

.CODE
DrawPixel PROC USES edx edi eax ecx x:DWORD, y:DWORD, color:DWORD
        LOCAL screenWidth:DWORD, screenHeight:DWORD
        mov edx,x                   ;edx=x
        mov edi,y                   ;edi=y
        mov screenWidth, 640        ;screenWidth=640    
        mov screenHeight, 480       ;screenHeight=480
        cmp edx,0                   
        jl done                     ;if(x<0) go to done
        cmp edx, screenWidth        
        jge done                    ;if x >= 640 (the screen width)go to done
        cmp edi, 0                  
        jl done                     ;same bounds checking for y
        cmp edi, screenHeight
        jge done                    ;same as line 33 but for y
        mov ecx, color              ;ecx=color
        mov eax, y                  ;eax=y
        mov edx, screenWidth        ;edx=screenWidth
        mul edx                     ;eax=y*640
        add eax, x                  ;eax=y*640+x
        add eax, ScreenBitsPtr      ;eax=ScreenBitsPtr+y*640+x
        mov BYTE PTR[eax], cl       ;move cl (Byte) into PTR[ScreenBitsPtr+y*640+x]        
    done:      
	ret 			    ; Don't delete this line!!!
DrawPixel ENDP

BasicBlit PROC USES ecx esi edi ptrBitmap:PTR EECS205BITMAP , xcenter:DWORD, ycenter:DWORD
        LOCAL transparency:BYTE, counter:DWORD, x0:DWORD, x1:DWORD, y0:DWORD, y1:DWORD  
        mov ecx, ptrBitmap                              ;ecx=beginning of EECS205BITMAP
        mov counter,0                                   ;counter=0
        mov bl, (EECS205BITMAP PTR[ecx]).bTransparent   ;bl=the transparency field
        mov transparency, bl                            ;transparency=bl (the transparency)
        mov esi, xcenter                                ;esi=xcenter
        mov x0, esi                                     ;x0=xcenter
        mov x1, esi                                     ;x1=xcenter
        mov esi, (EECS205BITMAP PTR[ecx]).dwWidth       ;get dwWidth and store in esi
        sar esi,1                                       ;(esi=dwWidth/2)
        sub x0,esi                                      ;x0=x0-dwWidth/2
        add x1,esi                                      ;x1=x1+dwWidth/2
        mov esi, ycenter                                ;esi=ycenter
        mov y0,esi                                      ;essentially repeating lines 64-69 but for y
        mov y1, esi
        mov esi, (EECS205BITMAP PTR[ecx]).dwHeight
        sar esi, 1
        sub y0,esi
        add y1, esi      
    OUTER_LOOP:
        mov esi, x1
        cmp x0,esi                                      ;if(x0>=x1), jump to inner loop
        jge INNER_LOOP
        mov esi, (EECS205BITMAP PTR[ecx]).lpBytes   
        mov edi, counter
        mov dl, BYTE PTR[esi+edi]                   
        mov al, transparency
        cmp dl, al
        je increments                                   ;if(dl!=al), call DrawPixel procedure, if they are, increment counter, x0, and then go back to outer loop
        INVOKE DrawPixel,x0,y0,[esi+edi]      
    increments:
        inc counter                                     ;counter++
        inc x0                                          ;x0++
        jmp OUTER_LOOP                                  ;go back to outer loop       
    INNER_LOOP:
        inc y0                                          ;y0++
        mov esi,y0                                      ;esi=y0
        cmp esi,y1              
        jge done                                        ;if(y0>=y1), then we are finished
        mov esi,(EECS205BITMAP PTR[ecx]).dwWidth        ;else
        sub x0, esi                                     ;x0 -= esi
        jmp OUTER_LOOP                                  ;jump back to outer loop
    done:    
	ret 		                                ;we return 
BasicBlit ENDP

RotateBlit PROC USES ecx edx ebx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:FXPT
    LOCAL counter:DWORD, transparency:BYTE, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, dstX:DWORD, dstY:DWORD, x:DWORD, y:DWORD, srcX:DWORD, srcY:DWORD, screenWidth:DWORD, screenHeight:DWORD
        mov screenWidth, 639                                    ;I could just use the immediates when comparing, but I prefer to just move them to a variable for clarity 
        mov screenHeight, 479                                   
        INVOKE FixedCos, angle
        mov ecx, eax                                            ;ecx=FixedCos(angle)
        INVOKE FixedSin, angle  
        mov edi, eax                                            ;edi=FixedSin(angle)
        mov counter, 0                                          ;initialize counter to 0
        mov esi, lpBmp                                          ;esi=lpBmp
        mov bl, (EECS205BITMAP PTR[esi]).bTransparent           ;bl=bTransparent field
        mov transparency, bl                                    ;tColor=bl
        ;finding shiftX
        mov eax, (EECS205BITMAP PTR[esi]).dwWidth
        imul ecx
        sar eax,1                                               ;divide by two since sar 1 = x/2^1 = dividing by two
        mov shiftX,eax                                      
        mov eax, (EECS205BITMAP PTR[esi]).dwHeight
        imul edi
        sar eax,1                                           
        sub shiftX, eax                                         ;shiftX=(EECS205BITMAP PTR [esi]).dwWidth*cosa/2 - (EECS205BITMAP PTR [esi]).dwHeight*sina/2   
        ;finding shiftY
        mov eax, (EECS205BITMAP PTR[esi]).dwHeight
        imul ecx
        sar eax,1
        mov shiftY, eax
        mov eax, (EECS205BITMAP PTR[esi]).dwWidth
        imul edi
        sar eax, 1
        add shiftY, eax                                         ;shiftY=(EECS205BITMAP PTR [esi]).dwWidth*cosa/2 + (EECS205BITMAP PTR [esi]).dwWidth*sina/2       
        ;continue 
        mov eax, (EECS205BITMAP PTR[esi]).dwWidth
        mov ebx, (EECS205BITMAP PTR[esi]).dwHeight
        add eax, ebx
        mov dstWidth, eax                                       ;dstWidth=(EECS205BITMAP PTR [esi]).dwWidth + (EECS205BITMAP PTR [esi]).dwHeight
        mov dstHeight, eax                                      ;dstHeight=dstWidth
        neg eax
        mov dstX, eax                                           ;dstX=-dstWidth
        mov dstY, eax                                           ;dstY=-dstHeight
        sar shiftY, 16                                          ;we shift by 16 to obtain the integer part of shiftY
        sar shiftX, 16                                          ;same, but for shiftX    
        jmp COND1   
    INNER:
        mov eax, dstX
        imul ecx
        mov srcX, eax
        mov eax, dstY
        imul edi                    
        add srcX, eax                                           ;srcX=dstX*cosa + dstY*sina  
        mov eax, dstY
        imul ecx
        mov srcY, eax
        mov eax, dstX
        imul edi
        sub srcY, eax                                           ;srcY=dstY*cosa - dstX*sina  
        sar srcX, 16
        sar srcY, 16      
        cmp srcX, 0
        jl dstY_inc
        mov eax, (EECS205BITMAP PTR[esi]).dwWidth
        cmp srcX, eax                                           ;from here to line 197, do all the comparisons from the "if" statement in the homework pseudocode
        jge dstY_inc      
        cmp srcY,0
        jl dstY_inc      
        mov eax, (EECS205BITMAP PTR[esi]).dwHeight 
        cmp srcY, eax
        jge dstY_inc      
        mov eax, xcenter
        add eax, dstX
        sub eax, shiftX
        cmp eax,0
        jl dstY_inc      
        mov eax, xcenter
        add eax,dstX
        sub eax, shiftX
        cmp eax, screenWidth
        jge dstY_inc
        mov eax, ycenter
        add eax, dstY
        sub eax, shiftY
        cmp eax,0
        jl dstY_inc      
        mov eax, ycenter
        add eax,dstY
        sub eax, shiftY
        cmp eax, screenHeight
        jge dstY_inc      
        mov eax, (EECS205BITMAP PTR[esi]).dwWidth
        mov edx, srcY
        imul edx                                                ;if (srcX >= 0 && srcX < (EECS205BITMAP PTR [esi]).dwWidth &&           
        add eax, srcX                                           ;srcY >= 0 && srcY < (EECS205BITMAP PTR [esi]).dwHeight &&       
        add eax, (EECS205BITMAP PTR[esi]).lpBytes               ;(xcenter+dstX-shiftX) >= 0 && (xcenter+dstX-shiftX) < 639 &&
        mov dl, BYTE PTR[eax]                                   ;(ycenter+dstY-shiftY) >= 0 && (ycenter+dstY-shiftY) < 479 && 
        cmp dl, transparency                                    ;bitmap pixel (srcX,srcY) is not transparent)
        je dstY_inc                                             
        mov ebx, xcenter                                        ;end of comparisons 
        add ebx, dstX
        sub ebx, shiftX                                         ;(xcenter+dstX-shiftX)
        mov x, ebx                                              ;variable x to hold (xcenter+dstX-shiftX)
        mov ebx, ycenter
        add ebx, dstY
        sub ebx, shiftY
        mov y, ebx                                              ;y=ycenter+dstY-shiftY
        mov al, BYTE PTR[eax]                                   ;al=color
        INVOKE DrawPixel, x, y, al                   ;if all comparisons were true, then we call DrawPixel with x, y, and the color       
    dstY_inc:
        inc dstY                                                ;dstY++            
    COND2:
        mov eax, dstY                                           ;basically the second for-loop condition
        cmp eax, dstHeight
        jl INNER
        inc dstX                  
    COND1:
        mov eax, dstHeight                                      ;the first for-loop condition
        neg eax                                                 ;dstX = -dstWidth
        mov dstY, eax
        mov eax, dstX
        cmp eax, dstWidth
        jl COND2        
        ret 			                                 ; Don't delete this line!!!		
RotateBlit ENDP
END