; #########################################################################
;
;   lines.asm - Assembly file for EECS205 Assignment 2
;   AUTHOR: LENIN ESTRADA
;   NetID: lae4127
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include stars.inc
include lines.inc
.DATA
	;; If you need to, you can place global variables here
        delta_x DWORD ?
        delta_y DWORD ?
        inc_x DWORD ?
        inc_y DWORD ?	
.CODE
DrawLine PROC USES edi edx ebx ecx x0:DWORD, y0:DWORD, x1:DWORD, y1:DWORD, color:DWORD
    ;; Place your code here
       mov edx,x1                           ;edx=x1
       sub edx,x0                           ;edx=edx-x0
       cmp edx,0 
       jge getX                             ;(x1-x0)<0
       neg edx                              ;negating a negative makes it positive
 getX: mov delta_x, edx                     ;if not negative, delta_x=edx=(x1-x0)
       mov edx, y1                          ;edx=y1
       sub edx, y0                          ;edx=y1-y0
       cmp edx, 0                   
       jge getY                             ;(y1-y0)>0, go to getY (which sets delta_y to this expression)
       neg edx                              ;else turn edx into positive
 getY: mov delta_y, edx
       mov edx, x0                          ;edx=x0
       cmp edx,x1                  
       jl incx                              ;edx (x0) < x1
       mov inc_x,-1                         ;else inc_x=1
       jmp continue1                        ;keep going 
 incx:
       mov inc_x, 1                         ;inc_x=1
 continue1:
       mov edx, y0                          ;edx=y0
       cmp edx,y1                 
       jl incy                              ;(y0<y1)
       mov inc_y, -1                        ;else inc_y=-1
       jmp continue2                        ;and we continue
 incy:
       mov inc_y, 1                         ;inc_y=1
 continue2:
       mov edx, delta_x                     ;edx=delta_x
       cmp edx,delta_y            
       jg deltaX                            ;(delta_x>delta_y)
       mov ebx, delta_y                     ;else    ebx=delta_y
       shr ebx, 1                           ;exploits shifts (shifting right by one = dividing by 2^1 = 2
       neg ebx                              ;negate the result -(delta_y / 2)
       jmp currents                
 deltaX:
       mov ebx,delta_x                      ;ebx=delta_x
       shr ebx, 1                           ;same thing as line 61
 currents:
       mov edx, x0                          ;edx=x0
       mov ecx, y0                          ;ecx=y0      
       INVOKE DrawPixel,edx,ecx,color   
       jmp OrComparison                     ;we jump to our comparisons       
  do:
       INVOKE DrawPixel,edx,ecx,color       ;while true, invoke drawpixel
       mov edi,ebx                          ;edi=ebx prev_error=error
       neg delta_x                          ;-delta_x
       cmp edi, delta_x                     ;compare them
       jle body                             ;(prev_error > -delta_y)
       sub ebx, delta_y                     ;else    error=error-delta_y
       add edx, inc_x                               ;curr_x=curr_x+inc_x
body: neg delta_x                           ;was false, so restor delta_x to be positive
       cmp edi, delta_y                     ;we continue to the next if statement 
       jge OrComparison                     ;(implies the comparison was not true, so we go back to evaluating
       add ebx, delta_x                     ;implies true, so error=error+delta_x
       add ecx, inc_y                       ;curr_y=curr_y+inc_y   
 OrComparison:  
       cmp edx, x1
       jne do                               ;this whole block is equivalent to while(curr_x != x1 || curr_y != y1)
       cmp ecx, y1
       jne do   
       ret                                  ;Don't delete this line...you need it ----- ELSE we return
DrawLine ENDP
END
