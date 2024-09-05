    .data
recebe_num: .asciz "Dê o valor de um número:\n"
entrada:    .asciz "%f"
saida_el:   .asciz "%f\n"
pivo_msg:   .asciz "Dê o valor para o pivô:\n"
menor_msg:  .asciz "Vetor de menores: "
maior_msg:  .asciz "Vetor de maiores: "
elemento:   .asciz "%f "
newline:    .asciz "\n"

    .text
    .globl main

main:
    pushl %ebp
    movl %esp, %ebp
    subl $256, %esp

    leal -64(%ebp), %edi        # -64(%ebp) == double vetor[8]
    call preenche_vetor

    pushl $pivo_msg
    call printf
    leal -72(%ebp), %eax        # -72(%ebp) == double pivo;
    pushl %eax
    pushl $entrada
    call scanf
    addl $12, %esp
    leal -72(%ebp), %eax
    flds (%eax)                 # pivo ficará no %st(1)
    leal -136(%ebp), %edi       # double menores[8]
    leal -200(%ebp), %esi       # double maiores[8]
    leal -64(%ebp), %edx
    call divide

    pushl $menor_msg
    call printf
    addl $4, %esp
    leal -136(%ebp), %edi
    call print_vetor
    pushl $maior_msg
    call printf
    addl $4, %esp
    leal -200(%ebp), %edi
    call print_vetor

    leal -64(%ebp), %edi
    call print_vetor

    fstpl (%esp)
    pushl $saida_el
    call printf
    addl $4, %esp

    pushl $0
    call exit

preenche_vetor:                 # preenche_vetor(double* vetor) Seguindo o padrão de System-V: %edi == *vetor
    pushl %ebp
    movl %esp, %ebp
    subl $16, %esp
    movl %edi, -4(%ebp)         # -4(%ebp) == *vetor
    movl $0, -8(%ebp)           # -8(%ebp) => int i = 0;
pv_loop:
    movl $8, %eax
    cmpl %eax, -8(%ebp)
    je pv_fim
    pushl $recebe_num
    call printf
    movl -8(%ebp), %eax
    movl $8, %ebx
    mull %ebx
    addl -4(%ebp), %eax
    pushl %eax
    pushl $entrada
    call scanf
    addl $12, %esp
    incl -8(%ebp)
    jmp pv_loop
pv_fim:
    movl %ebp, %esp
    popl %ebp
    ret

print_vetor:                    # print_vetor(double* vetor) %edi == *vetor
    pushl %ebp
    movl %esp, %ebp
    subl $32, %esp
    movl %edi, -4(%ebp)         # -4(%ebp) == *vetor
    movl $0, -8(%ebp)           # -8(%ebp) == int i = 0;
prv_loop:
    movl $8, %eax
    cmpl %eax, -8(%ebp)
    je prv_fim
    movl -8(%ebp), %eax
    movl $8, %ebx
    mull %ebx
    addl -4(%ebp), %eax
    flds (%eax)
    fstpl (%esp)
    pushl $elemento
    call printf
    addl $4, %esp
    incl -8(%ebp)
    jmp prv_loop
prv_fim:
    pushl $newline
    call printf
    movl %ebp, %esp
    popl %ebp
    ret

divide:
    pushl %ebp
    movl %esp, %ebp
    subl $32, %esp
    movl %edi, -4(%ebp)         # -4(%ebp) == double* menores
    movl %esi, -8(%ebp)         # -8(%ebp) == double* maiores
    movl %edx, -12(%ebp)        # -12(%ebp) == *vetor
    movl $0, -16(%ebp)          # -16(%ebp) == int i = 0;
    movl $0, -20(%ebp)          # -20(%ebp) == qtd de elementos em menores
    movl $0, -24(%ebp)          # -24(%ebp) == qtd de elementos em maiores
div_loop:
    movl $8, %eax
    cmpl %eax, -16(%ebp)
    je div_fim
    movl -16(%ebp), %eax
    movl $8, %ebx
    mull %ebx
    addl -12(%ebp), %eax
    fldl (%eax)
    fcomi %st(1)
    ja div_maior                # elemento atual de *vetor maior que pivo
    movl -20(%ebp), %eax
    movl $8, %ebx
    mull %ebx
    addl -4(%ebp), %eax         # menores + qtd_menores * tamanho double
    fstpl (%eax)
    incl -20(%ebp)
div_ret:    
    incl -16(%ebp)
    jmp div_loop
div_maior:
    movl -24(%ebp), %eax
    movl $8, %ebx
    mull %ebx
    addl -8(%ebp), %eax         # maiores + qtd_maiores + tamanho double
    fstpl (%eax)
    incl -24(%ebp)
    jmp div_ret
div_fim:    
    movl %ebp, %esp
    pop %ebp
    ret
