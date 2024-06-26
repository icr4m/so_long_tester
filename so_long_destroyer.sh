#!/bin/bash

make re

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
DEF_COLOR='\033[0m'

# Create invalids maps

mkdir -p bad_map

invalid_maps=(
"1111111\n1P00C01\n10000E1\n1C01101\n1010E01\n1111111"
"111111111\n1P0000P01\n101111101\n100C00001\n101011101\n100001E01\n111111111"
"111111\n1P0C01\n101101\n100001\n111111"
"1111111\n1P00001\n\n101X111\n1000C01\n1C01001\n100E101\n1111111"
"11111111\n1P000001\n\n10101101\n1C000E01\n11111111"
"1111111\n1P0C001\n1 10111\n1 00C01\n1010101\n1000E01\n1111111"
"1111111\n1P00001\n1011111\n1000001\n1011111\n100E001\n1111111"
"1111111111111111111111111111111111111111111111111111111111111\n1P0000000000000000000000000000000000000000000000000000000E111\n1111111111111111111111111111111111111111111111111111111111111"
"1111111\n1P00001\n1000001\n1000001\n1000001\n1000E01\n1111111"
"1111111\n1P00001\n1011111\n1000001\n1C010E1\n100E0E1\n1111111"
"111111\n1P0C01\n10 101\n1000E1\n111111"
"1111111\n1P00001\n101111\n100C001\n1010101\n1000E01\n1111111"
"1111111\n1000C01\n1000011\n1C01101\n1010E01\n1111111"
"1111111\n1P00001\n101#111\n1000C01\n1C01001\n100E101\n1111111"
"1111111\n1P11111\n1111111\n1C11111\n1111E11\n1111111"
"1111111\n1P0CCC1\n1C11111\n1C00001\n11010C1\n1C10EC1\n1111111"
"1111111\n1P02001\n1011111\n1020001\n1012101\n1003E01\n1111111"
"1111111\n1P00001\n1011111\n1000001\n1110101\n10000E1\n1111111"
"1111111\n1P00001\n1000001\n1C00001\n1010101\n1000001\n1111111"
"1P0C01\n10101\n100001\n101E01\n111111\n111111\n111111"
)

i=1
for map in "${invalid_maps[@]}"; do
    map_file="bad_map/map${i}.ber"
    echo -e "$map" > "$map_file"
    ((i++))
done

check_output(){
    local map_file=$1
    local EXPECTED_OUTPUT="$2"
    output=$(./so_long "$map_file")

    {
        read -r line1
        read -r line2
    } <<< "$output"
    
    if echo "$line1" | grep -q "Error"; then
        printf "${GREEN}[OK]${DEF_COLOR} "
    else
        printf "${RED}[KO] Expected: Error${DEF_COLOR} "
    fi
    printf "\n"
}

check_for_leaks() {
    local map_file=$1
    local message=$2
    local map_name=$3

    valgrind --leak-check=full ./so_long "$map_file" > valgrind_output.txt 2>&1

    if grep -q "All heap blocks were freed -- no leaks are possible" valgrind_output.txt; then
        LEAKS=0
    else
        LEAKS=1
    fi

    if [ $LEAKS -eq 1 ]; then
        printf "${RED}[MKO] LEAKS ${DEF_COLOR}\n"
        # cat valgrind_output.txt
    else
        printf "${GREEN}[MOK]${DEF_COLOR}\n"
    fi

    printf "The test: %s\n" "$message"
    printf "The map: %s\n" "$map_name"

    rm valgrind_output.txt
}
# Check OUTPUT FOR ERROR MAP
check_output "bad_map/map1.ber" "Too much exit."
check_output "bad_map/map2.ber" "Too much start."
check_output "bad_map/map3.ber" "No exit found."
check_output "bad_map/map4.ber" "Map contains an empty line."
check_output "bad_map/map5.ber" "Map contains an empty line."
check_output "bad_map/map6.ber" "Map contains an empty character."
check_output "bad_map/map7.ber" "No collectibles found."
check_output "bad_map/map8.ber" "Map is oo big"
check_output "bad_map/map9.ber" "No collectibles found."
check_output "bad_map/map10.ber" "Too much exit."
check_output "bad_map/map11.ber" "Map contains an empty character."
check_output "bad_map/map12.ber" "Map is not rectangular."
check_output "bad_map/map13.ber" "No start found."
check_output "bad_map/map14.ber" "Unknown character in the map."
check_output "bad_map/map15.ber" "No path found."
check_output "bad_map/map16.ber" "No path found."
check_output "bad_map/map17.ber" "Unknown character in the map."
check_output "bad_map/map18.ber" "No collectibles found."
check_output "bad_map/map19.ber" "No exit found."
check_output "bad_map/map20.ber" "Map is not rectangular."

# Check IF ERROR MAP GOT LEAKS
check_for_leaks "bad_map/map1.ber" "Too much exit." "map1.ber"
check_for_leaks "bad_map/map2.ber" "Too much start." "map2.ber"
check_for_leaks "bad_map/map3.ber" "No exit found." "map3.ber"
check_for_leaks "bad_map/map4.ber" "Map contains an empty line." "map4.ber"
check_for_leaks "bad_map/map5.ber" "Map contains an empty line." "map5.ber"
check_for_leaks "bad_map/map6.ber" "Map contains an empty character." "map6.ber"
check_for_leaks "bad_map/map7.ber" "No collectibles found." "map7.ber"
check_for_leaks "bad_map/map8.ber" "Map is oo big" "map8.ber"
check_for_leaks "bad_map/map9.ber" "No collectibles found." "map9.ber"
check_for_leaks "bad_map/map10.ber" "Too much exit." "map10.ber"
check_for_leaks "bad_map/map11.ber" "Map contains an empty character." "map11.ber"
check_for_leaks "bad_map/map12.ber" "Map is not rectangular" "map12.ber"
check_for_leaks "bad_map/map13.ber" "No start found." "map13.ber"
check_for_leaks "bad_map/map14.ber" "Unknown character in the map." "map14.ber"
check_for_leaks "bad_map/map15.ber" "No path found." "map15.ber"
check_for_leaks "bad_map/map16.ber" "No path found." "map16.ber"
check_for_leaks "bad_map/map17.ber" "Unknown character in the map." "map17.ber"
check_for_leaks "bad_map/map18.ber" "No collectibles found." "map18.ber"
check_for_leaks "bad_map/map19.ber" "No exit found." "map19.ber"
check_for_leaks "bad_map/map20.ber" "Map is not rectangular." "map20.ber"