.MODEL small
.STACK 100h
.DATA
    frase       DB   'Digite um numero: $'
    entrada     DB   12 DUP('$')
    saida       DB   12 dup('$')
    num_low     DW   ?
    num_hig     DW   ?

.CODE
    mov ax,@data
    mov ds,ax
    mov dx, offset frase
    mov si, offset saida

    mov ah,9 ; selecionei a acao de printar texto terminado com $
    int 21h  ; executa a acao selecionada acima

    mov bx, 0

    digitacao:  
        mov ah,1 ; selecionei acao de obter digitacao de um char, sem ENTER
        int 21h  ; executa a acao selecionada acima
        cmp al, 8
        je backspace
        mov byte ptr entrada[bx], al ; no al está o char digitado; o coloco em entrada na posicao bx
        inc bx ; incremento bx (aumento 1)
        cmp al, 13 ; comparo o char digitado com 13, que é ENTER
        jne digitacao ; salto para digitacao se for diferente
        jmp tratarDig
        backspace:
        dec bx
        mov byte ptr entrada[bx], 0 ; no al está o char digitado; o coloco em entrada na posicao bx
        cmp al, 13 ; comparo o char digitado com 13, que é ENTER
        jne digitacao ; salto para digitacao se for diferente
    
    tratarDig:
    dec bx
    mov entrada[bx], '$' 
    mov ax, 0
    mov bx, 0
    mov cx, 10
    mov dx, 0
    cmp byte ptr entrada[bx], '-'
    je negative
    mov di, 0
    jmp guardar
    negative:
        mov di, 1

    guardar:
        push ax
        mov ax, dx
        mul cx
        mov dx, ax
        pop ax
        mov bx, dx
        mul cx
        add dx, bx

        mov bx, 0
        mov bl, byte ptr entrada[di]
        sub bl, 48
        add ax, bx

        jnc soma
        inc dx
        soma:

        inc di
        cmp byte ptr entrada[di], '$'
        jne guardar

    mov bx, 0
    cmp entrada[bx], '-'
    jne printar
    neg ax
    xor dx, 0FFFFh

    printar:
        mov  num_low, ax
        mov  num_hig, dx
        mov  bx, 10
        mov  cx, 0
        cmp dh, 80h
        js extrair
        dec ax
        xor ax, 0FFFFh
        xor dx, 0FFFFh
        mov byte ptr [si], '-'
        inc si
        mov  num_low, ax
        mov  num_hig, dx

    extrair: 
        mov  dx, 0
        mov  ax, num_hig
        div  bx
        mov  num_hig, ax
        mov  ax, num_low
        div  bx
        mov  num_low, ax
        push dx
        inc  cx
        cmp  ax, 0
        jne  extrair

    desempilhar:   
        pop  dx                    
        add  dl, 48
        mov  [ si ], dl
        inc  si
        loop desempilhar

    mov  ah, 9
    mov  dx, offset saida
    int  21h  

    mov  ax, 4c00h
    int  21h

end