#!/bin/bash

make re -C ../

clear

for map in bad_map/*.ber; do
    valgrind .././so_long "$map"
done