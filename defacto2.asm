;defacto2 ad
;sensenstahl
;www.sensenstahl.com
;fasm 1.69.31
;listening: carpenter brut - beware the beast

;assuming values at start of the intro: ax = bx = 0 / cx = 255
;global used variable: bp for scanning/moving the string/scroller

;basicially "7x7.m56" but 2 big scrollers and quite a bit of text. recycling? fo shizzle!
;in the end more a side product since using 13h saves quite a few bytes compared to textmode
;which i realized while working on "7x7.m56". but why abandon an idea which i like? anyway,
;less comments than in the previous intro and a bit more messy.

org 100h
use16

start:   push 0a000h     ;vga
         pop es          ;clears memory at 0a000h
         mov al,13h      ;by setting all bytes to 0
         int 10h         ;when video mode is activated

         mov ah,09h      ;print string to vga
         mov dx,text     ;ds needs to be unchanged
         int 21h         ;drop the string

         push 08000h     ;vscreen
         pop ds

cls:
xor ax,ax
xchg al,byte[es:bx] ;grab string + erase on vga
mov byte[ds:bx],al  ;copy string to part of vscreen which is not copied to vga
                    ;and not visible
inc bx
jnz cls


xor bp,bp           ;needed
main:

mov ax,1302h ;19 and 2
             ;save 1b below at test/add of 19
again:

;get the string data, convert it and show the text
mov cl,79;80;80 ;ch = always 0 ;startpos in textmode

mov di,bp ;set start pos for scan on 320*200
scan:

xor bx,bx
scan2:
mov si,di ;for checking + grabbing the saved text

cmp al,1           ;2nd text active?
jne stay           ;no so continue and scroll from right to left
neg si             ;scroll from left to right
add si,320*9-80-34 ;set pos to grab 2nd text
stay:

cmp byte[ds:bx+si],ch;0 ;pixel on buffer of 320*200 string?
je skip                 ;nope

imul si,bx,4;3;2        ;size up steps for y
add si,di               ;pos of scan
sub si,bp               ;exclude movement of scroller
;shl si,2;2;3           ;size up x and y
mov ch,16               ;15 high

cmp al,1                ;2nd text active?
jne stay3               ;no
imul si,bx,3;4;2;3;2    ;size up steps for y
sub si,di               ;pos of scan
add si,bp               ;exclude movement
;shl si,2;3             ;size up x and y
add si,320*4-162        ;adjust pos of negative scroller
;mov ch,12              ;11 high
stay3:

shl si,2;2;3            ;size up x and y for both versions
;mov ch,16              ;15 high

sizeup:
mov dl,6;4;8            ;5 wide
sizeup2:

;mov al,42;80;9
mov dh,cl               ;shading
;add dh,ch
shr dh,3                ;make grayscale
add dh,ah;19
cmp al,1                ;2nd text active?
jne stay2               ;no
cmp byte[ds:si+320*42],dh;19;only draw on existing larger text!
ja nono
;shr dh,1
;adc dh,74;50;74;103;42;80;9
stay2:
mov byte[ds:si+320*42],dh ;draw
nono:

inc si               ;draw 1 line
dec dl               ;for each
jnz sizeup2          ;found pixel
add si,320-6;-4;-8   ;next row
dec ch               ;loop
jnz sizeup           ;until done

skip:
add bx,320    ;next row in 320*200
;cmp bx,320*8 ;done full height or letters which are 8*8?
cmp bh,0ah    ;save 1b
jne scan2

inc di               ;next pos on 320*200
loop scan            ;do whole screen 80*50


dec al ;ah < > 0
jnz again ;draw both scrollers

;well ...
bar:
add byte[ds:bx+320*32-1],102-17
add byte[ds:bx+320*156-1],66-17
dec bx
jnz bar

;start of grabber-window in 320*200
;which moves from left to right
;to make scroller fake scroll
inc bp
cmp bp,320-92;-40
jne fine
mov bp,-92;-40 ;correct start
fine:

mov dx,3dah     ;wait for vsync for constant speed
;vsync1:        ;to slow things down and make the
;in al,dx       ;scroller actually readable ;)
;test al,8
;jnz vsync1
vsync2:
in al,dx
test al,8
jz vsync2

;cx = 0 here
mov di,320*20 ;start pos outside of stored string data
mov ch,64h ;mov cx,320*80 ;6400h
           ;draws 160 heigh because of stosw
flip:
mov ax,1211h;6566h;4342h;1f1eh;
xchg ax,word[ds:di]
stosw ;incl add di,2
loop flip

         in al,60h            ;read keyboard buffer
         dec al               ;ESC?
         jnz main             ;nothing so go on

breaker: ret                  ;back to dos, staying in 80*50
;        0        1         2         3         4         5
;        12345678901234567890123456789012345678901234567890
;                     max length here V                           and here V
text db '//BBSTROS+CRACKTROS+NFOS+ART/           DEFACTO2.NET @ FILES THE DL$'