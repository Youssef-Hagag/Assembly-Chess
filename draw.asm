include macros.inc

extrn draw_selector1:far
extrn draw_selector2:far
extrn bKing:byte
extrn wKing:byte
extrn bQueen:byte
extrn wQueen:byte
extrn bRook:byte
extrn wRook:byte
extrn bBishop:byte
extrn wBishop:byte
extrn bKnight:byte
extrn wKnight:byte
extrn bPawn:byte
extrn wPawn:byte
extrn bSquare:byte
extrn wSquare:byte

public draw_cell, get_cell_start, init_draw
public row, col, cell_start, shape_to_draw, init_draw

.model small
.stack 64
.data
col dw 0
row dw 0
cell_start dw 0
shape_to_draw dw 0



.code
;----------------------------------------------------Helping Function for draw_cell----------------------------------------------------
drawLine proc
     
     ;don't push SI!!!
     push ax
     push bx    
     push cx
     push dx
     push di
     
     mov cx,25
     draw_pixel:
          mov al,ds:[si]
          cmp al,02h
          je skip_pixel
          mov es:[di],al
          skip_pixel:
          inc si
          inc di
     loop draw_pixel
          
     pop di
     pop dx
     pop cx
     pop bx
     pop ax
     ret 
drawLine endp

;--------------------------------------------------------Useful-everywhere-------------------------------------------------------------

get_cell_start proc far
     ;gets cell cell_start from row and col values and stores it in the variable "cell_start"
     PUSH_ALL
     mov ax,25
     mul col
     mov bx,ax

     ;the sole reason why col and row is a word instead of a byte
     mov ax,8000
     mul row
     add ax,bx

     mov cell_start,ax
     POP_ALL
     ret
get_cell_start endp

draw_cell proc far
     ;draws a cell with the shape_to_draw at the selected row and col    
     PUSH_ALL
     mov cx,25
     call get_cell_start
     mov di,cell_start
     mov si, shape_to_draw
     draw_cell_loop:
          call drawLine
          add di,320
     loop draw_cell_loop
     POP_ALL
     ret
draw_cell endp

;-------------------------------------------------------Exclusive Functions---------------------------------------------------------------------

get_init_piece proc
     ;gets the offset of the initial piece based on row and col and stores it in "shape_to_draw"
     cmp row,1
     je bpa
     cmp row,6
     je wpa

     cmp row,0
     je black
     cmp row,7
     je white

     bpa:
     mov shape_to_draw,offset bPawn
     ret
     wpa:
     mov shape_to_draw,offset wPawn
     ret

     white:
     cmp col,0 
     je wro
     cmp col,1
     je wkn
     cmp col,2 
     je wbi
     cmp col,3
     je wqe
     cmp col,4 
     je wki
     cmp col,5
     je wbi
     cmp col,6 
     je wkn
     cmp col,7
     je wro

     wkn:
     mov shape_to_draw,offset wKnight
     ret
     wbi:
     mov shape_to_draw,offset wBishop
     ret
     wro:
     mov shape_to_draw,offset wRook
     ret
     wki:
     mov shape_to_draw,offset wKing
     ret
     wqe:
     mov shape_to_draw,offset wQueen
     ret

     black:
     cmp col,0 
     je bro
     cmp col,1
     je bkn
     cmp col,2 
     je bbi
     cmp col,3
     je bqe
     cmp col,4 
     je bki
     cmp col,5
     je bbi
     cmp col,6 
     je bkn
     cmp col,7
     je bro

     bkn:
     mov shape_to_draw,offset bKnight
     ret
     bbi:
     mov shape_to_draw,offset bBishop
     ret
     bro:
     mov shape_to_draw,offset bRook
     ret
     bqe:
     mov shape_to_draw,offset bQueen
     ret
     bki:
     mov shape_to_draw,offset bKing
     ret 
get_init_piece endp

draw_board_pieces proc
     mov row,0
     draw_board:
     mov col,0

     draw_row:
   
     call get_init_piece
     call draw_cell

     inc col
     cmp col,7
     jle draw_row

     cmp row,1
     jne normal_inc
     add row,4
     normal_inc:
     inc row
     cmp row,7
     jle draw_board

     ret
draw_board_pieces endp

draw_empty_board proc
     ;draws empty white and black board
     mov shape_to_draw,offset wSquare
     mov bl,0ffh
     mov row,0
     draw_board2:
     mov col,0

     draw_row2:
     call draw_cell

     ;switching between black and white squares
     not bl
     cmp col,7
     je white_square ;not really white square, but to skip switching colors after the end of a row

     cmp bl,0
     je black_square
     mov shape_to_draw,offset wSquare
     jmp white_square
     black_square:
     mov shape_to_draw,offset bSquare
     white_square:

     inc col
     cmp col,7
     jle draw_row2

     not bl
     inc row
     cmp row,7
     jle draw_board2
     
     ret
draw_empty_board endp

init_draw proc
     mov ax,0A000H
     mov es,ax
     
     mov ah,0
     mov al,13h
     int 10h

     call draw_empty_board
     call draw_board_pieces
     call draw_selector1
     call draw_selector2
     ret
init_draw endp
end