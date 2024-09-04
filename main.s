    .data
hello:  .asciz "Hello World!\n"

    .text
    .globl main

main:
    pushl $hello
    call printf
    addl $4, %esp

    pushl $0
    call exit
