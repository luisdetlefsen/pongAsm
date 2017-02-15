format MZ

push cs
pop ds
push cs
pop es


;set video mode
mov ah,0
mov al,0x10 ;vga 640x350  16 colors
int 0x10

mainLoop:
call clearScreen
call drawBackground
call drawObjects
call readInput
call updateState
jmp mainLoop

clearScreen:
mov [CURR_COLOR],0
jmp repaintBall
cs2:
cmp [P1_DY],0
jnz repaintP1
cs1:
cmp [P2_DY],0
jnz repaintP2
@@:

ret
repaintBall:
mov ax,[B_Y]
push ax
sub ax,[B_DY]
mov [B_Y],ax
mov ax,[B_X]
push ax
sub ax,[B_DX]
mov [B_X],ax
call drawBall
pop ax
mov [B_X],ax
pop ax
mov [B_Y],ax
jmp cs2

repaintP1:
mov ax,[P1_Y]
push ax
sub ax,[P1_DY]
mov [P1_Y],ax
call drawP1Bar
pop ax
mov [P1_Y],ax
jmp cs1

repaintP2:
mov ax,[P2_Y]
push ax
sub ax,[P2_DY]
mov [P2_Y],ax
call drawP2Bar
pop ax
mov [P2_Y],ax
jmp @r



drawBackground:
mov al,[OBJ_COLOR]
mov [CURR_COLOR],al
mov [x1],0
mov ax,[MAX_X]
mov [x2],ax
mov [y1],0
mov ax,[MAX_Y]
mov [y2],ax
call drawRectangle
ret
ret

drawObjects:
mov al,[OBJ_COLOR]
mov [CURR_COLOR],al
call drawBall
call drawP1Bar
call drawP2Bar
ret

drawBall:
mov ax,[B_X]
sub ax,[BORDER_SIZE]
mov [x1],ax

mov ax,[B_X]
add ax,[BORDER_SIZE]
mov [x2],ax

mov ax,[B_Y]
sub ax,[BORDER_SIZE]
mov [y1],ax

mov ax,[B_Y]
add ax,[BORDER_SIZE]
mov [y2],ax
call drawRectangle
ret

drawP1Bar:
mov ax,[P1_X]
sub ax,[BORDER_SIZE]
mov [x1],ax

mov ax,[P1_X]
add ax,[BORDER_SIZE]
mov [x2],ax

mov ax,[P1_Y]
sub ax,[BAR_HEIGHT]
mov [y1],ax

mov ax,[P1_Y]
add ax,[BAR_HEIGHT]
mov [y2],ax
call drawRectangle
ret

drawP2Bar:
mov ax,[P2_X]
sub ax,[BORDER_SIZE]
mov [x1],ax

mov ax,[P2_X]
add ax,[BORDER_SIZE]
mov [x2],ax

mov ax,[P2_Y]
sub ax,[BAR_HEIGHT]
mov [y1],ax

mov ax,[P2_Y]
add ax,[BAR_HEIGHT]
mov [y2],ax
call drawRectangle
ret

readInput:

mov ah,1
int 0x16
jnz keyPressed
@@:
ret
keyPressed:
mov ah,0
int 0x16
cmp ah,0x11
jz w
cmp ah,0x1f
jz s
cmp ah,0x17
jz i
cmp ah,0x25
jz k
cmp ah,1
jz exit
jmp @r
w:
mov [P1_DY],-1
jmp @r
s:
mov [P1_DY],1
jmp @r
i:
mov [P2_DY],-1
jmp @r
k:
mov [P2_DY],1
jmp @r


updateState:
mov ax,[P1_Y]
add ax,[P1_DY]
mov [P1_Y],ax

mov ax,P1_DY
push [P1_Y]
push ax
call checkPCollision
pop ax
pop ax

mov ax,[P2_Y]
add ax,[P2_DY]
mov [P2_Y],ax


mov ax,P2_DY
push [P2_Y]
push ax
call checkPCollision
pop ax
pop ax


mov ax,[B_X]
add ax,[B_DX]
mov [B_X],ax
mov ax,[B_Y]
add ax,[B_DY]
mov [B_Y],ax

call checkBallCollision
ret


checkPCollision:
push bp
mov bp,sp

mov ax,[bp+6]
add ax,[BAR_HEIGHT]
mov dx,ax
mov ax,[MAX_Y]
sub ax,[BORDER_SIZE]
cmp dx,ax
jz pBorderHit

mov ax,0
add ax,[BORDER_SIZE]
mov dx,ax
mov ax,[bp+6]

sub ax,[BAR_HEIGHT]
cmp ax,dx
jz pBorderHit
jmp @f

pBorderHit:
mov ax,0
mov di,[bp+4]
mov [di],ax

@@:

mov sp,bp
pop bp
ret


checkBallCollision:
mov ax,0
add ax,[BORDER_SIZE]
mov dx,ax
mov ax,[B_X]
sub ax,[BORDER_SIZE]
cmp ax,dx
jz p2Win
w1:
mov dx,ax
mov ax,[P1_X]
add ax,[BORDER_SIZE]
cmp ax,dx
jnz @f
mov ax,[P1_Y]
add ax,[BAR_HEIGHT]
mov dx,ax
mov ax,[B_Y]
sub ax,[BORDER_SIZE]
inc ax
cmp ax,dx
jge @f
mov ax,[P1_Y]
sub ax,[BAR_HEIGHT]
mov dx,ax
mov ax,[B_Y]
add ax,[BORDER_SIZE]
cmp ax,dx
jle @f
jmp changeXDir




@@:
mov ax,[MAX_X]
sub ax,[BORDER_SIZE]
mov dx,ax
mov ax,[B_X]
add ax,[BORDER_SIZE]
cmp ax,dx
jz p1Win
w2:
mov dx,ax
mov ax,[P2_X]
sub ax,[BORDER_SIZE]
cmp dx,ax
jnz @f
mov ax,[P2_Y]
add ax,[BAR_HEIGHT]
mov dx,ax
mov ax,[B_Y]
sub ax,[BORDER_SIZE]
inc ax
cmp ax,dx
jge @f
mov ax,[P2_Y]
sub ax,[BAR_HEIGHT]
mov dx,ax
mov ax,[B_Y]
add ax,[BORDER_SIZE]
cmp ax,dx
jle @f
jmp changeXDir



@@:
mov ax,0
add ax,[BORDER_SIZE]
mov dx,ax
mov ax,[B_Y]
sub ax,[BORDER_SIZE]
cmp ax,dx
jz changeYDir
w3:
mov ax,[MAX_Y]
sub ax,[BORDER_SIZE]
mov dx,ax
mov ax,[B_Y]
add ax,[BORDER_SIZE]
cmp ax,dx
jz changeYDir

ret





p2Win:

push [P2_WIN_LEN]
push P2_WIN
call showWinner
pop dx
pop dx
jmp w1



p1Win:
push [P2_WIN_LEN]
push P1_WIN
call showWinner
pop dx
pop dx
jmp w2


changeXDir:
neg [B_DX]
ret

changeYDir:
neg [B_DY]

ret



showWinner:
push bp
mov bp,sp
mov ah,0x13
mov al,1
mov bh,0
mov bl,1100_1100b
mov cx,[bp+6]
mov dl,30 ;col
mov dh,10 ;row
mov bp,[bp+4]
int 0x10
mov cx,[EXIT_MSG_LEN]
mov dl,26
mov dh,11
mov bp, EXIT_MSG
int 0x10

mov sp,bp
pop bp
call keyPause
call exit
ret

drawRectangle:
mov ah,0x0c
mov al,[CURR_COLOR]
mov bh,0

;upper bound
mov dx,[y1]
push ax
mov ax,dx
add ax,[BORDER_SIZE]
mov [t0],ax
inc [t0]
pop ax
d1:
mov cx,[x2]
inc cx
@@:
dec cx
int 0x10
cmp cx,[x1]
jnz @r
inc dx
cmp [t0],dx
jnz d1

;lower bound
mov dx,[y2]
push ax
mov ax,dx
sub ax,[BORDER_SIZE]
mov [t0],ax
dec [t0]
pop ax
d2:
mov cx,[x2]
inc cx
@@:
dec cx
int 0x10
cmp cx,[x1]
jnz @r
dec dx
cmp [t0],dx
jnz d2

;left bound
mov cx,[x1]
dec cx
push ax
mov ax,cx
add ax,[BORDER_SIZE]
mov [t0],ax
pop ax
d3:
inc cx
mov dx,[y2]
inc dx
@@:
dec dx
int 0x10
cmp dx,[y1]
jnz @r
cmp [t0],cx
jnz d3

;right bound
mov cx,[x2]
inc cx
push ax
mov ax,cx
sub ax,[BORDER_SIZE]
mov [t0],ax
pop ax
d4:
dec cx
mov dx,[y2]
inc dx
@@:
dec dx
int 0x10
cmp dx,[y1]
jnz @r
cmp [t0],cx
jnz d4
ret


keyPause:
mov ah,0
int 0x16
ret

exit:
mov ah,0
mov al,2
int 0x10
mov ax,0x4c00
int 0x21



P1_COLOR db 1
P2_COLOR db 2
BG_COLOR db 0
OBJ_COLOR db 3
CURR_COLOR db 16

P1_X dw 20
P1_Y dw 150
P2_X dw 620
P2_Y dw 150
B_X dw 300
B_Y dw 150

P1_DY dw 0
P2_DY dw 0
B_DX dw 1
B_DY dw 1

BAR_HEIGHT dw 50
BORDER_SIZE dw 2

P1_WIN db 'Player 1 Won!'
P1_WIN_LEN dw $-P1_WIN
P2_WIN db 'Player 2 Won!'
P2_WIN_LEN dw $-P2_WIN
EXIT_MSG db 'Press any key to exit'
EXIT_MSG_LEN dw $-EXIT_MSG

t0 dw 0
x1 dw 0
x2 dw 0
y1 dw 0
y2 dw 0
MAX_X dw 639
MAX_Y dw 349