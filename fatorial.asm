.MODEL small
.STACK 100h
.DATA
    frase       DB   'Digite um numero: $'
    erro        DB   'So existem fatoriais de numeros postivos!$'
    erro2       DB   'Nao suportamos fatoriais maiores que 12!$'
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
        mov entrada[bx], al ; no al está o char digitado; o coloco em entrada na posicao bx
        inc bx ; incremento bx (aumento 1)

        cmp al, 13 ; comparo o char digitado com 13, que é ENTER
        jne digitacao ; salto para digitacao se for diferente

    dec bx
    mov entrada[bx], '$' 

    mov ax, 0
    mov bx, 0
    mov cx, 10
    mov dx, 0
    mov di, 0
    cmp byte ptr entrada[bx], '-'
    jne guardar
    mov dx, offset erro
    mov ah,9 ; selecionei a acao de printar texto terminado com $
    int 21h  ; executa a acao selecionada acima
    mov  ax, 4c00h
    int  21h

    guardar:
        mul cx
        mov bx, 0
        mov bl, byte ptr entrada[di]
        sub bl, 48
        add ax, bx
        inc di
        cmp byte ptr entrada[di], '$'
        jne guardar

    cmp ax, 12
    jle fatorial
    mov dx, offset erro2
    mov ah,9 ; selecionei a acao de printar texto terminado com $
    int 21h  ; executa a acao selecionada acima
    mov  ax, 4c00h
    int  21h

    fatorial:
        mov bx, 0
        mov dx, 0
        mov cx, ax
        cmp cx, 2
        jnl fatorar
        mov cx, 2
        mov ax, 1
        fatorar:
            dec cx
            mov bx, ax
            mov ax, dx
            mul cx
            mov dx, ax
            mov ax, bx
            mov bx, dx
            mul cx
            add dx, bx
            cmp cx, 1
            jg fatorar


    printar:
        mov  num_low, ax
        mov  num_hig, dx
        mov  bx, 10
        mov  cx, 0

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