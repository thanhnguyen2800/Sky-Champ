;
; Invaders in 512 bytes
; ... (header giữ nguyên)
;

    %ifndef pure8088
pure8088:       equ 1
        cpu 8086
    %endif

    %ifndef com_file
com_file:       equ 0
    %endif

base:           equ 0xfc80

shots:          equ base+0x00
old_time:       equ base+0x0c
score:          equ base+0x0e   ;*** ADDED: Score variable (2 bytes)
level:          equ base+0x10
lives:          equ base+0x11
sprites:        equ base+0x12

SHIP_ROW:       equ 0x5c*OFFSET_X
X_WIDTH:        equ 0x0140
OFFSET_X:       equ X_WIDTH*2
SPRITE_SIZE:    equ 4

SPACESHIP_COLOR:        equ 0x1c
BARRIER_COLOR:          equ 0x0b
SHIP_EXPLOSION_COLOR:   equ 0x0a
INVADER_EXPLOSION_COLOR:        equ 0x0e
BULLET_COLOR:           equ 0x0c
START_COLOR:    equ ((sprites+SPRITE_SIZE-(shots+2))/SPRITE_SIZE+0x20)

    %if com_file
        org 0x0100
    %else
        org 0x7c00
    %endif
        mov ax,0x0013
        int 0x10
        cld
        mov ax,0xa000
        mov ds,ax
        mov es,ax
        mov ah,0x04
        mov [level],ax

restart_game:
        xor ax,ax
        mov cx,level/2
        xor di,di
        rep
        stosw

        mov ax,[di]
        inc ax
        inc ax
        stosw
        mov ah,al
        xchg ax,dx

        mov ax,SPACESHIP_COLOR*0x0100+0x00
        stosw
        mov ax,SHIP_ROW+0x4c*2
        stosw

        mov ax,0x08*OFFSET_X+0x28
        mov bx,START_COLOR*0x0100+0x10
in1:    mov cl,0x0b
in5:    stosw
        add ax,0x0b*2
        xchg ax,bx
        stosw
        inc ah
        xchg ax,bx
        loop in5
        add ax,0x09*OFFSET_X-0x000b*0x000b*2
        cmp bh,START_COLOR+55
        jne in1

        mov di,0x55*0x280+0x10*2
        mov cl,5
in48:
        mov ax,BARRIER_COLOR*0x0100+0x04
        call draw_sprite
        add di,0x1e*2
        loop in48

in14:
        mov si,sprites+SPRITE_SIZE

in46:
        cmp byte [si+2],0x20
        jc in2
        inc ch
        cmp ch,55
        je restart_game

in6:
        lodsw
        xchg ax,di
        lodsw
        cmp al,0x28
        je in27
        cmp al,0x20
        jne in29
        mov byte [si-2],0x28
in29:   call draw_sprite
in27:   cmp si,sprites+56*SPRITE_SIZE
        jne in46
        mov al,dh
        sub al,2
        jc in14
        xor al,1
        mov dl,al
        mov dh,al
        jmp in14

in2:
        xor byte [si+2],8

        inc bp
        and bp,7
    %if pure8088
        push dx
        push si
        push bp
    %else
        pusha
    %endif
        jne in12
in22:
        mov ah,0x00
        int 0x1a
        cmp dx,[old_time]
        je in22
        mov [old_time],dx

        ;*** ADDED: Draw score at top-left corner after each tick
        call draw_score

in12:
    %if 1
        mov si,shots
        mov cx,4
        lodsw
        cmp ax,X_WIDTH
        xchg ax,di
        jc in31
        call zero
        sub di,X_WIDTH+2
        mov al,[di]
        sub al,0x20
        jc in30
    %if pure8088
        push si
        push di
    %else
        pusha
    %endif
        mov ah,SPRITE_SIZE
        mul ah
        add si,ax
        lodsw
        xchg ax,di
        mov byte [si],0x20
        ;*** ADDED: Increase score when invader is hit
        inc word [score]
        mov ax,INVADER_EXPLOSION_COLOR*0x0100+0x08
        call draw_sprite
    %if pure8088
        pop di
        pop si
    %else
        popa
    %endif
        jmp in31

in24:
        lodsw
        or ax,ax
        je in23
        cmp ax,0x60*OFFSET_X
        xchg ax,di
        jnc in31
        call zero
        add di,X_WIDTH-2

in30:
        mov ax,BULLET_COLOR*0x0100+BULLET_COLOR
        mov [si-2],di
        cmp byte [di+X_WIDTH],BARRIER_COLOR
        jne in7

in31:   xor ax,ax
        mov [si-2],ax

in7:    cmp byte [di],SPACESHIP_COLOR
        jne in41
        mov word [sprites],SHIP_EXPLOSION_COLOR*0x0100+0x38
in41:
        call big_pixel
in23:   loop in24
    %endif

        mov si,sprites
        lodsw
        or al,al
        je in42
        add al,0x08
        jne in42
        mov ah,SPACESHIP_COLOR
        dec byte [lives]
        js in10
in42:   mov [si-2],ax
        mov di,[si]
        call draw_sprite
        jne in43

        mov ah,0x02
        int 0x16
    %if com_file
        test al,0x10
        jnz in10
    %endif

        test al,0x04
        jz in17
        dec di
        dec di

in17:   test al,0x08
        jz in18
        inc di
        inc di
in18:
        test al,0x03
        jz in35
        cmp word [shots],0
        jne in35
        lea ax,[di+(0x04*2)]
        mov [shots],ax
in35:
        xchg ax,di
        cmp ax,SHIP_ROW-2
        je in43
        cmp ax,SHIP_ROW+0x0132
        je in43
in19:   mov [si],ax
in43:
    %if pure8088
        pop bp
        pop si
        pop dx
    %else
        popa
    %endif

        mov ax,[si]
        cmp dl,1
        jbe in9
        add ax,0x0280
        cmp ax,0x55*0x280
        jc in8
in10:
    %if com_file
        mov ax,0x0003
        int 0x10
    %endif
        int 0x20

in9:    dec ax
        dec ax
        jc in20
        add ax,4
in20:   push ax
        shr ax,1
        mov cl,0xa0
        div cl
        dec ah
        cmp ah,0x94
        pop ax
        jb in8
        or dh,22
in8:    mov [si],ax
        add ax,0x06*0x280+0x03*2
        xchg ax,bx

        mov cx,3
        in al,(0x40)
        cmp al,0xfc
        jc in4

        mov di,shots+2
in45:   cmp word [di],0
        je in44
        scasw
        loop in45
in44:
        mov [di],bx
in4:
        jmp in6

        ;
        ; Bitmaps for sprites
        ;
bitmaps:
        db 0x18,0x18,0x3c,0x24,0x3c,0x7e,0xFf,0x24
        db 0x00,0x80,0x42,0x18,0x10,0x48,0x82,0x01
        db 0x00,0xbd,0xdb,0x7e,0x24,0x3c,0x66,0xc3
        db 0x00,0x3c,0x5a,0xff,0xa5,0x3c,0x66,0x66
        db 0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00

bit:    jc big_pixel
zero:   xor ax,ax
big_pixel:
        mov [di+X_WIDTH],ax
        stosw
        ret

draw_sprite:
    %if pure8088
        push cx
        push di
        pushf
    %else
        pusha
    %endif
in3:    push ax
        mov bx,bitmaps
        cs xlat
        xchg ax,bx
        mov cx,10
        clc
in0:    mov al,bh
        mov ah,bh
        call bit
        shl bl,1
        loop in0
        add di,OFFSET_X-20
        pop ax
        inc ax
        test al,7
        jne in3
    %if pure8088
        popf
        pop di
        pop cx
    %else
        popa
    %endif
        ret

;*** ADDED: Draw score subroutine
;    Draws score digits at top-left (row 0, col 0)
;    Destroys: AX, BX, CX, DX, DI
;--------------------------------------------------
; draw_score: vẽ score 3 chữ số ở góc trái trên
;--------------------------------------------------
draw_score:
        push ax
        push bx
        push cx
        push dx
        push di
        push si

        ; Xóa vùng score: 3 chữ số * 6 cột * 5 hàng
        ; Mỗi big-pixel = 2 byte ngang, 2 dòng screen
        ; Vùng cần xóa: 36 pixel ngang x 10 dòng screen
        mov cx,10               ; 10 dòng screen (5 hàng big-pixel * 2)
        xor di,di               ; Góc trái trên = offset 0
ds_clr_row:
        push cx
        xor ax,ax
        mov cx,18               ; 18 word = 36 bytes = 36 pixel ngang
        push di
        rep stosw
        pop di
        add di,X_WIDTH          ; Xuống 1 dòng screen (X_WIDTH = 320 bytes? không, = 0x140 = 320 pixels = 320 bytes trong mode 13h)
        pop cx
        loop ds_clr_row

        ; Tính 3 chữ số từ score
        mov ax,[score]
        xor dx,dx
        mov bx,100
        div bx                  ; AX = hundreds, DX = remainder
        mov [ds_h],al           ; lưu chữ số hàng trăm
        mov ax,dx
        xor dx,dx
        mov bx,10
        div bx                  ; AX = tens, DX = ones
        mov [ds_t],al
        mov [ds_o],dl

        ; Vẽ chữ số hàng trăm tại cột 0
        xor di,di
        mov al,[ds_h]
        call draw_digit

        ; Vẽ chữ số hàng chục tại cột 12 screen pixels = 6 big-pixel * 2
        mov di,6*2
        mov al,[ds_t]
        call draw_digit

        ; Vẽ chữ số hàng đơn vị tại cột 24 screen pixels
        mov di,12*2
        mov al,[ds_o]
        call draw_digit

        pop si
        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret

ds_h:   db 0    ; temp storage
ds_t:   db 0
ds_o:   db 0

;--------------------------------------------------
; draw_digit: vẽ chữ số 0-9 dạng 5x5 big-pixel
; AL = digit (0-9)
; DI = screen offset (góc trái trên của chữ số)
;--------------------------------------------------
draw_digit:
        push ax
        push bx
        push cx
        push dx
        push di

        ; Tính offset trong digit_bitmaps: AL * 5
        xor ah,ah
        mov bx,5
        mul bx                  ; AX = AL*5
        add ax,digit_bitmaps
        mov bx,ax               ; BX = con trỏ đến bitmap của digit

        mov cx,5                ; 5 hàng
dd_row:
        push cx
        push di
        cs mov al,[bx]          ; lấy 1 byte bitmap
        inc bx
        mov cx,5                ; 5 cột
        mov ah,0x0f             ; màu trắng sáng
dd_col:
        shl al,1                ; CF = bit cao nhất
        jnc dd_off
        ; Vẽ big-pixel: 2 byte ở dòng hiện tại, 2 byte ở dòng kế
        mov [di],ah
        mov [di+1],ah
        mov [di+X_WIDTH],ah
        mov [di+X_WIDTH+1],ah
        jmp dd_next
dd_off:
        ; Xóa (đã xóa trước rồi, không cần làm gì)
dd_next:
        add di,2                ; cột tiếp theo (2 pixel ngang)
        loop dd_col
        pop di
        add di,X_WIDTH*2        ; xuống 2 dòng screen = 1 hàng big-pixel
        pop cx
        loop dd_row

        pop di
        pop dx
        pop cx
        pop bx
        pop ax
        ret

;--------------------------------------------------
; Bitmap 5x5 cho chữ số 0-9 (bits 7..3 của mỗi byte)
;--------------------------------------------------
digit_bitmaps:
        db 0b11110000,0b10010000,0b10010000,0b10010000,0b11110000  ; 0
        db 0b01100000,0b00100000,0b00100000,0b00100000,0b11110000  ; 1
        db 0b11110000,0b00010000,0b11110000,0b10000000,0b11110000  ; 2
        db 0b11110000,0b00010000,0b11110000,0b00010000,0b11110000  ; 3
        db 0b10010000,0b10010000,0b11110000,0b00010000,0b00010000  ; 4
        db 0b11110000,0b10000000,0b11110000,0b00010000,0b11110000  ; 5
        db 0b11110000,0b10000000,0b11110000,0b10010000,0b11110000  ; 6
        db 0b11110000,0b00010000,0b00110000,0b00100000,0b00100000  ; 7
        db 0b11110000,0b10010000,0b11110000,0b10010000,0b11110000  ; 8
        db 0b11110000,0b10010000,0b11110000,0b00010000,0b11110000  ; 9

    %if com_file
    %else
        times 510-($-$$) db 0x4f
        db 0x55,0xaa
    %endif