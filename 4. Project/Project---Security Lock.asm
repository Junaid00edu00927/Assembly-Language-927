
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt
include emu8086.inc
.MODEL SMALL
.DATA   
        ;I    DB 0d
        SIZE EQU 10
        HEAD DB '________________Security lock________________','$'
        MSG1 DB 13, 10, 'Enter your ID:$'
        MSG2 DB 13, 10, 'Enter your Password:$'
        MSG3 DB 13, 10, 'ERROR ID not Found!$'
        MSG4 DB 13, 10, 'Wrong Password! Access denied$'
        MSG5 DB 13, 10, 'Correct! Welocome to the Safe$'
        MSG6 DB 13, 10, 'Too Long password!$'
        TEMP_ID DW 1 DUP(?),0
        TEMP_Pass DB 1 DUP(?)
        IDSize = $-TEMP_ID
        PassSize = $-Temp_Pass
        ID  DW        'A150', 'B255', 'CE20', 'BB71', 'D111', 'E500', 'F432', 'EC12', '5321', '9876' 
        Password DB   1,      2,      3,      4,       7,     10,     11,     13,     12,      14
    
.CODE
MAIN        PROC
            MOV AX,@DATA   ;In
            MOV DS,AX
            MOV AX,0000H
            

Title:      LEA DX,HEAD
            MOV AH,09H
            INT 21H

ID_PROMPT:  LEA DX,MSG1
            MOV AH,09H
            INT 21H
            
            
ID_INPUT:   MOV BX,0
            MOV DX,0
            LEA DI,TEMP_ID
            MOV DX,IDSize
            CALL get_string
            

CheckID:    MOV BL,0
            MOV SI,0

AGAIN:      MOV AX,ID[SI] 
            MOV DX,TEMP_ID
            CMP DX,AX
            JE  PASS_PROMPT
            INC BL
            ADD SI,4
            CMP BL,SIZE
            JB  AGAIN
            
ERRORMSG:   LEA DX,MSG3
            MOV AH,09H
            INT 21H
            JMP ID_PROMPT
             
            
PASS_PROMPT:LEA DX,MSG2
            MOV AH,09H
            INT 21H
            
Pass_INPUT: CALL   scan_num
            CMP    CL,0FH
            JAE    TooLong
            MOV    BH,00H
            MOV    DL,Password[BX]
            CMP    CL,DL
            JE     CORRECT 

            
INCORRECT:  LEA DX,MSG4
            MOV AH,09H
            INT 21H
            JMP ID_PROMPT
            
CORRECT:    LEA DX,MSG5
            MOV AH,09H
            INT 21H
            JMP Terminate

TooLong:    LEA DX,MSG6
            MOV AH,09H
            INT 21H
            JMP PASS_PROMPT
            

DEFINE_SCAN_NUM
DEFINE_GET_STRING
Terminate:        
END MAIN        
=============================================================================================
=============================================================================================
=============================================================================================
=============================================================================================
=============================================================================================
=============================================================================================
=============================================================================================

; ------------------------------------------------------------
; CheckID: Compare entered ID against all stored IDs one by one
; ------------------------------------------------------------
CheckID:    MOV BL, 0                ; BL = counter (tracks which ID index we're checking)
            MOV SI, 0                ; SI = byte offset into ID array (starts at 0)

AGAIN:      MOV AX, ID[SI]           ; Load 2-byte ID entry at current offset SI into AX
            MOV DX, TEMP_ID          ; Load user-entered ID from TEMP_ID into DX
            CMP DX, AX               ; Compare entered ID with stored ID
            JE  PASS_PROMPT          ; If equal ? ID matched, jump to password prompt
            INC BL                   ; No match ? increment ID index counter
            ADD SI, 4                ; Advance SI by 4 bytes (each ID entry = 4 bytes in DW)
            CMP BL, SIZE             ; Have we checked all SIZE (10) entries?
            JB  AGAIN                ; If not, loop back and check next ID

; ------------------------------------------------------------
; ERRORMSG: ID not found in any record ? show error, retry
; ------------------------------------------------------------
ERRORMSG:   LEA DX, MSG3             ; Load "ERROR ID not Found!" message
            MOV AH, 09H
            INT 21H                  ; Display error message
            JMP ID_PROMPT            ; Jump back to re-enter ID

; ------------------------------------------------------------
; PASS_PROMPT: ID matched ? now ask for the password
; (BL still holds the matched index, used to look up correct password)
; ------------------------------------------------------------
PASS_PROMPT:LEA DX, MSG2             ; Load "Enter your Password:" message
            MOV AH, 09H
            INT 21H                  ; Display MSG2

; ------------------------------------------------------------
; Pass_INPUT: Read password as a number using scan_num macro
; CL will contain the entered numeric value after the call
; BL still holds the matched ID index from CheckID
; ------------------------------------------------------------
Pass_INPUT: CALL scan_num            ; Read a number from keyboard ? result stored in CL
            CMP  CL, 0FH             ; Is entered value >= 15 (0x0F)?
            JAE  TooLong             ; If yes ? password too large, jump to TooLong handler
            MOV  BH, 00H             ; Clear BH so BX = BL (clean 16-bit index into Password[])
            MOV  DL, Password[BX]    ; Load correct password for matched ID index into DL
            CMP  CL, DL              ; Compare entered password (CL) with stored password (DL)
            JE   CORRECT             ; If equal ? correct password, jump to success

; ------------------------------------------------------------
; INCORRECT: Password did not match ? show error, restart
; ------------------------------------------------------------
INCORRECT:  LEA DX, MSG4             ; Load "Wrong Password! Access denied" message
            MOV AH, 09H
            INT 21H                  ; Display MSG4
            JMP ID_PROMPT            ; Restart from ID entry

; ------------------------------------------------------------
; CORRECT: Both ID and Password matched ? grant access
; ------------------------------------------------------------
CORRECT:    LEA DX, MSG5             ; Load "Correct! Welcome to the Safe" message
            MOV AH, 09H
            INT 21H                  ; Display success message
            JMP Terminate            ; Exit the program

; ------------------------------------------------------------
; TooLong: Password number was too large (>= 15) ? warn and retry
; ------------------------------------------------------------
TooLong:    LEA DX, MSG6             ; Load "Too Long password!" message
            MOV AH, 09H
            INT 21H                  ; Display MSG6
            JMP PASS_PROMPT          ; Ask for password again

; ------------------------------------------------------------
; Macro Definitions (expanded inline by emu8086 assembler)
; ------------------------------------------------------------
DEFINE_SCAN_NUM                      ; Inserts scan_num subroutine code here
DEFINE_GET_STRING                    ; Inserts get_string subroutine code here

; ------------------------------------------------------------
; Terminate: End of program
; ------------------------------------------------------------
Terminate:
END MAIN                             ; Mark end of MAIN procedure and program entry point
    
     
