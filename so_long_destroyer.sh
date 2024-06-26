#!/bin/bash

make re -C ../

clear

valgrind --leak-check=full .././so_long maps/map2.ber > valgrind_output.txt 2>&1

if grep -q "All heap blocks were freed -- no leaks are possible" valgrind_output.txt; then
    LEAKS=0
else
    LEAKS=1
fi

if [ $LEAKS -eq 1 ]; then
    printf "${RED}$C.[MKO] LEAKS ${DEF_COLOR}\n"
    cat valgrind_output.txt
else
    printf "${GREEN}$C.[MOK]${DEF_COLOR}\n"
fi

rm valgrind_output.txt