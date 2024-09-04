    .data
recebe_num: .asciz "Dê o valor de um número:\n"
entrada:    .asciz "%f"
saida_el:   .asciz "%f\n"
pivo_msg:   .asciz "Dê o valor para o pivô:\n"

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
    movl $0, -80(%ebp)          # -80(%ebp) == qtd de elementos em vetor_menores
                                # -144(%ebp) até -88(%ebp) == double vetor_menores[8]
    movl $0, -148(%ebp)         # -148(%ebp) == qtd de elementos em vetor_maiores
                                # -212(%ebp) até -156(%ebp) == double vetor_maiores[8] 
    leal -80(%ebp), %edi        # Como se fosse uma struct { int qtd; double vetor[8] };
    leal -148(%ebp), %esi
    leal -64(%ebp), %edx
    call divide
    
    leal -144(%ebp), %edi
    call print_vetor
    leal -212(%ebp), %edi
    call print_vetor

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
    pushl $saida_el
    call printf
    addl $4, %esp
    incl -8(%ebp)
    jmp prv_loop
prv_fim:
    movl %ebp, %esp
    popl %ebp
    ret

divide:
    pushl %ebp
    movl %esp, %ebp
    subl $32, %esp
    movl %edi, -4(%ebp)         # -4(%ebp) == struct { int qtd; double vetor[8] } *menores;
    movl %esi, -8(%ebp)         # -8(%ebp) == struct { int qtd; double vetor[8] } *maiores;
    movl %edx, -12(%ebp)        # -12(%ebp) == *vetor
    movl $0, -16(%ebp)          # -16(%ebp) == int i = 0;
div_loop:
    movl $8, %eax
    cmpl %eax, -16(%ebp)
    je div_fim
    movl -16(%ebp), %eax
    movl $8, %ebx
    mull %ebx
    addl -12(%ebp), %eax
    flds (%eax)
    fcomi %st(1), %st(0)
    ja div_maior                # elemento atual de *vetor maior que pivo
    movl -4(%ebp), %eax         # menores
    movl (%eax), %eax
    movl $8, %ebx
    mull %ebx
    addl -4(%ebp), %eax
    addl $4, %eax               # vetor[8] começa 4 bytes depois do ponteiro
    fstpl (%eax)
    movl -4(%ebp), %eax
    movl (%eax), %ebx
    incl %ebx
    movl %ebx, (%eax)
div_ret:    
    incl -16(%ebp)
    jmp div_loop
div_maior:
    movl -8(%ebp), %eax
    movl (%eax), %eax
    movl $8, %ebx
    mull %ebx
    addl -8(%ebp), %eax
    addl $4, %eax
    fstpl (%eax)
    movl -8(%ebp), %eax
    movl (%eax), %ebx
    incl %ebx
    movl %ebx, (%eax)
    jmp div_ret
div_fim:    
    movl %ebp, %esp
    pop %ebp
    ret
