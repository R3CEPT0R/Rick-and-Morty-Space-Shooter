; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;   AUTHOR: LENIN ESTRADA
;   NetID: lae4127

; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

include trig.inc

.DATA
;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  Use reciprocal to find the table entry for a given angle
	                        ;;              (It is easier to use than divison would be)	
.CODE
FixedSin PROC USES ebx edx angle:FXPT
    LOCAL negative_angle:DWORD 
        xor eax, eax                ;clear eax
        mov negative_angle,0        ;negative_angle=0
        mov edx, angle              ;edx=angle
        cmp edx,0                   ;
        je pi_half                  ;if(angle == 0)    
    inc_neg:
        cmp edx,0                   
        jge dec_pos                 ;if(angle>=0)
        add edx, TWO_PI             ;angle += 2pi
        jmp inc_neg                         
    dec_pos:
        cmp edx, TWO_PI             
        jl two_pi                   ;if(angle < 2pi)
        sub edx, TWO_PI             ;angle -= 2pi
        jmp dec_pos             
    two_pi:
        cmp edx, PI                 
        jl pi                       ;if(angle<pi)
        sub edx, PI                 ;angle -= pi
        xor negative_angle,1        ;xOR negative angle with 1
        jmp two_pi        
    pi:
        cmp edx, PI_HALF               
        je equals_piHalf            ;if(angle == pi/2)
        cmp edx, PI_HALF            
        jl pi_half                  ;if(angle < pi/2)
        mov ebx, PI                 ;ebx=pi
        sub ebx, edx                ;ebx -= angle
        mov edx, ebx                ;angle= (ebx-angle)
        jmp pi                      
    equals_piHalf:
        mov eax,1                   ;eax=1
        shl eax, 16                 ;extract the integer part of the fixed point number
        ret                                      
    pi_half:
        mov eax, edx                ;eax=angle
        mov edx, PI_INC_RECIP       ;angle=5340353
        imul edx                    ;eax=angle*5340353
        movzx eax, WORD PTR[SINTAB+edx*2]       ;eax=SINTAB[angle]
        cmp negative_angle,0                    
        je done                         ;if(negative_angle==0), then done
        neg eax                         ;else we negate because it is negative        
    done:
        ret			; Don't delete this line!!!
FixedSin ENDP 
	
FixedCos PROC USES edi angle:FXPT
	xor eax, eax               ;clear eax
        mov edi, angle
        add edi, PI_HALF         ;edi=(angle+pi/2)
        INVOKE FixedSin, edi     ;Exploit trig identity cos(x)=sin(x+pi/2). In this case edi contains the expression (x+pi/2)
	ret			; Don't delete this line!!!	
FixedCos ENDP	
END
