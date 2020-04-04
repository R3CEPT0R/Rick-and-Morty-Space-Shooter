; #########################################################################
;
;   stars.asm - Assembly file for EECS205 Assignment 1
;   AUTHOR: LENIN ESTRADA
;   NetID: lae4127
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive


include stars.inc

.DATA
        ;Dimensions: 640x480
	;; If you need to, you can place global variables here
        xarray DWORD 290,332,261,56,412,87,505,489,366,250,545,572,339,468,456,547,517,594,516,491,
                     352,306,143,484,56,328,42,359,307,618,526,558,591,519,287,491,639,259,525,317,
                     300,427
                     	
        ITMO DWORD 418,119,469,173,77,467,428,204,282,351,303,281,475,3,359,305,326,151,154,381,46,465,
                    192,61,217,447,267,236,122,438,374,470,456,434,479,23
                    
        count DWORD 50
        step DWORD ?
        
.CODE
DrawStarField proc USES edi esi ecx
    mov edi, OFFSET xarray              ;here we set to the beginning of array
    mov esi, OFFSET ITMO                ;same but for ITMO
    mov ecx, LENGTHOF xarray            ;ecx=lenght of xarray
    mov step, 9                         ;step

    
	;; Place your code here
	L1:
            mov count,ecx               ;save outer loop count
            mov ecx, count              ;setting inner loop count
            
        L2:
            INVOKE DrawStar,[edi],step             ;INVOKE DrawStar
            INVOKE DrawStar,step,[esi]             ;INVOKE DrawStar
            INVOKE DrawStar,[edi],[esi]            ;INVOKE DrawStar
            add edi, TYPE xarray                   ;point to the next element in xarray 
            add esi, TYPE ITMO                     ;same but for ITMO array
            add step, 10                           ;add 10 to step
            loop L2                                ;repeat inner loop
            
            mov ecx, count                         ;restore outer loop count
            loop L1                                ;repeat outer

	ret  			; Careful! Don't remove this line
DrawStarField endp



END
