.MODEL small
.STACK 100h
.DATA
    frase       DB   'Digite um numero: $'
    erro        DB   'So existem fatoriais de numeros postivos!$'
    erro2       DB   'Nao suportamos fatoriais maiores que 12!$'
    entrada     DB   12 DUP(0) 
    saida       DB   12 dup('$'); cria uma string repleta de $, isso facilita o algoritimo
    num_low     DW   ? ; parte baixa do numero 32 bits
    num_hig     DW   ? ; parte alta

.CODE
    mov ax,@data
    mov ds,ax
    mov dx, offset frase ; move pra dx o endereço de frase
    mov ah,9 ; selecionei a acao de printar texto terminado com $
    int 21h  ; executa a acao selecionada acima

    digitacao:  
        mov ah,1 ; selecionei acao de obter digitacao de um char, sem ENTER
        int 21h  ; executa a acao selecionada acima
        cmp al, 8 ; compara al com BACKSPACE
        je backspace ; pula se for igual
        mov entrada[bx], al ; no al está o char digitado; o coloco em entrada na posicao bx
        inc bx ; incremento bx (aumento 1)

        cmp al, 13 ; comparo o char digitado com 13, que é ENTER
        jne digitacao ; salto para digitacao se for diferente
        jmp tratarDig ; não entra em backspace:

    backspace:
        dec bx ; volta um caracter na contagem
        mov byte ptr entrada[bx], 0 ; no al está o char digitado; o coloco em entrada na posicao bx
        cmp al, 13 ; comparo o char digitado com 13, que é ENTER
        jne digitacao ; salto para digitacao se for diferente
    
    tratarDig:
    dec bx ; remove o caracter ENTER
    mov entrada[bx], '$' ;colocando um $ no lugar

    mov ax, 0 ; zera todas as variáveis
    mov bx, 0
    mov cx, 10 ; passa 10 para cx
    mov dx, 0
    mov di, 0
    cmp byte ptr entrada[bx], '-' ; verifica se o numero digitado é negativo
    jne guardar ; se não for pula direto para guardar:
    mov dx, offset erro ; move para dx o endereço de erro
    mov ah,9 ; selecionei a acao de printar texto terminado com $
    int 21h  ; executa a acao selecionada acima
    mov  ax, 4c00h ; finaliza o programa
    int  21h

    guardar:
        mul cx ; multiplica ax por 10
        mov bx, 0 ; zera bx
        mov bl, byte ptr entrada[di] ; move pra bl o caracter da entrada
        sub bl, 48 ; subtrai 48 para obter o int equivalente ao caracter do numero
        add ax, bx ; adiciona em ax, bx
        inc di ; soma + 1 em di
        cmp byte ptr entrada[di], '$' ; verifica se chegou no final da string
        jne guardar ; se não chegou volta para o começo

    cmp ax, 12 ; verifica se ax é menor que 12
    jle fatorial ; se for pula para fatorial:
    mov dx, offset erro2 ; move para dx o endereço de erro2
    mov ah,9 ; selecionei a acao de printar texto terminado com $
    int 21h  ; executa a acao selecionada acima
    mov  ax, 4c00h ; encerra o programa
    int  21h

    fatorial:
        mov bx, 0 ; zera as variaveis
        mov dx, 0
        mov cx, ax ; move pra cx, o valor de ax
        cmp cx, 2 ; verifica se cx é menor que 2
        jnl fatorar ; se não for pula para fatorar:
        mov cx, 2 ; move para cx, 2
        mov ax, 1 ; move para ax, 1
        ; desta maneira teremos fatorial de 1 e 0 valendo 1
        ; fatorial de 1 e 0: ax: 1 cx: 2 
        fatorar:
            dec cx ; subtrai 1 de cx
            mov bx, ax ; move ax para uma variavel auxiliar
            mov ax, dx ; coloca dx em ax
            mul cx ; multiplica ax por cx
            mov dx, ax ; move ax de volta para dx
            mov ax, bx ; volta o valor de ax
            mov bx, dx ; move dx para uma variavel auxiliar
            mul cx ; multiplica ax por cx, o valor que passar irá para dx
            add dx, bx ; adiciona a dx, o valor de bx, o valor que passou + o valor antigo
            cmp cx, 1 ; verifica se cx é mair que 1
            jg fatorar ; se for volta para o começo


    printar:
        mov  num_low, ax
        mov  num_hig, dx
        mov  bx, 10
        mov  cx, 0

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

    mov si, offset saida ; move para si, o endereço de saida
    desempilhar:   
        pop  dx ; desempilha em dx
        add  dl, 48 ; soma 48 para obter o numero em char
        mov  [ si ], dl ; move para o endereço de si, o valor de dl
        inc  si 
        loop desempilhar ; a cada loop ele subtrai 1 de cx, quando cx for zero ele encerra

    mov  ah, 9
    mov  dx, offset saida ; imprime o resultado do fatorial
    int  21h  

    mov  ax, 4c00h ; finaliza o programa
    int  21h

end