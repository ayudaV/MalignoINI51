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
        cmp al, 8 ; compara o char em al com BACKSPACE
        je backspace ; se for igual, pula para backspace:
        mov byte ptr entrada[bx], al ; no al está o char digitado; o coloco em entrada na posicao bx
        inc bx ; incremento bx (aumento 1)
        cmp al, 13 ; comparo o char digitado com 13, que é ENTER
        jne digitacao ; salto para digitacao se for diferente
        jmp tratarDig ; pula para tratarDig:
        backspace:
        dec bx ; volta um char na contagem
        mov byte ptr entrada[bx], 0 ; no al está o char digitado; o coloco em entrada na posicao bx
        cmp al, 13 ; comparo o char digitado com 13, que é ENTER
        jne digitacao ; salto para digitacao se for diferente
    
    tratarDig:
    dec bx
    mov entrada[bx], '$' ; substitui o caracter ENTER por $
    mov ax, 0
    mov bx, 0
    mov cx, 10
    mov dx, 0
    cmp byte ptr entrada[bx], '-' ; verifica se o numero é negativo
    je negative ; se for, pula para negative
    mov di, 0 ; os numeros serão lidos a partir do char 0
    jmp guardar ; pula para guardar:
    negative: 
        mov di, 1 ; os numeros serão lidos a partir do char 1 pois char 0 é -

    guardar:
        mov bx, ax ; move ax para uma variavel auxiliar
        mov ax, dx ; move dx para ax
        mul cx ; multiplica ax por 10
        mov dx, ax ; move ax de volta para dx
        mov ax, bx ; volta o valor para ax
        mov bx, dx ; move dx para uma variavel auxiliar
        mul cx ; multiplica ax por 10, o valor pode extrapolar para dx
        add dx, bx ; adiciona em dx o valor preservado em bx

        mov bx, 0
        mov bl, byte ptr entrada[di] ; move para bl o char
        sub bl, 48 ; transforma em int
        add ax, bx ; adiciona em ax o novo valor

        ; logica: Ex: 123
        ; multiplica 0 por 10, soma 1
        ; multiplica 1 por 10, soma 2 -> 12
        ; multiplica 12 por 10, soma 3 -> 123

        jnc soma ; se a soma disparou a flag de carry, devemos somar 1 em dx
        inc dx
        soma:

        inc di
        cmp byte ptr entrada[di], '$' ; verifica se chegou no final da string
        jne guardar ; se não chegou volta para o começo

    mov bx, 0
    cmp entrada[bx], '-' ; verifica se o numero é negativo
    jne printar 
    neg ax ; se for, inverte todos os bits e soma 1 na parte baixa. neg = not + 1
    not dx ; not: 10100110 -> 01011001

    printar:
        mov  num_low, ax
        mov  num_hig, dx
        mov  bx, 10
        mov  cx, 0
        cmp dh, 0 ; faz o equivalente de subtrair de dh, 0.
        jns extrair ; verifica se no resultado da subtração, o bit mais a esquerda é 1
        dec ax
        not ax ; inverte os bits de ax
        not dx 
        mov byte ptr [si], '-' ; move para o endereço de si, o caracter -
        inc si ; incrementa si para que os numeros sejam postos 1 casa pra frente na string
        mov  num_low, ax
        mov  num_hig, dx

    extrair: 
        mov  dx, 0
        mov  ax, num_hig
        div  bx ; divide a parte alta do numero por 10
        mov  num_hig, ax
        mov  ax, num_low
        div  bx ; divide a parte baixa do numero por 10
        mov  num_low, ax
        push dx ; empilha o resto da divisão
        inc  cx 
        cmp  ax, 0 ; verifica ax é zero
        jne  extrair ; se não for, volta para o início

    desempilhar:   
        pop  dx ; desempilha em dx 
        add  dl, 48 ; converte para char
        mov  [ si ], dl ; move para o endereco de si, o valor de dl
        inc  si
        loop desempilhar ; a cada loop CX--, se CX==0 encerra

    mov  ah, 9
    mov  dx, offset saida ; imprime saida
    int  21h  

    mov  ax, 4c00h ; finaliza o programa
    int  21h

end