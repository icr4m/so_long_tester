#!/bin/bash

if [ -f "$so_long" ]; then
    make re
else
    make
fi

clear

RED='\033[0;31m'
GREEN='\033[0;32m'
DEF_COLOR='\033[0m'
BLUE='\033[0;94m'
CYAN='\033[0;96m'
YELLOW='\033[0;93m'
MAGENTA='\033[0;95m'

# Create invalids maps

mkdir -p TESTbad_map

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
    map_file="TESTbad_map/map${i}.ber"
    echo -e "$map" > "$map_file"
    ((i++))
done

# Create valid maps

mkdir -p TESTgood_map

valid_maps=(
"111111\n1P0C11\n1110E1\n111111"
"111111111111\n1P0000000001\n111CCCCCC011\n100000000001\n11100000CCC1\n100000000001\n1100000000E1\n111111111111"
)

j=1
for map in "${valid_maps[@]}"; do
    map_file="TESTgood_map/map${j}.ber"
    echo -e "$map" > "$map_file"
    ((j++))
done


check_output() 
{
    local map_file=$1
    ./so_long "$map_file" > test_check.txt 2>&1 

    SO_LONG_EXIT_CODE=$?

    if [ $SO_LONG_EXIT_CODE -eq 139 ]; then
        printf "${RED}[KO] SEGFAULT${DEF_COLOR} "
        rm -rf test_check.txt
        return
    fi

    LINE=$(head -n 1 test_check.txt)
    LINE2=$(sed -n '2p' test_check.txt)

    if echo "$LINE" | grep -q "Error"; then
        printf "${GREEN}[OK]${DEF_COLOR} "
    else
        printf "${RED}[KO] Expected: Error${DEF_COLOR} "
    fi

    rm -rf test_check.txt
}

check_for_leaks() {
    local map_file=$1
    local message=$2
    local map_name=$3

    printf "${BLUE}The test: %s${DEF_COLOR}\n" "$message"
    printf "${BLUE}The map: %s${DEF_COLOR}\n" "$map_name"

    valgrind --leak-check=full ./so_long "$map_file" > valgrind_output.txt 2>&1

    SO_LONG_EXIT_CODE=$?

   if [ $SO_LONG_EXIT_CODE -eq 139 ]; then
        printf "${RED}[KO] SEGFAULT${DEF_COLOR}\n"
        return

    elif grep -q "All heap blocks were freed -- no leaks are possible" valgrind_output.txt; then
        LEAKS=0
    else
        LEAKS=1
    fi

    if [ $LEAKS -eq 1 ]; then
        printf "${RED}[MKO] LEAKS ${DEF_COLOR}\n"
    elif [ $LEAKS -eq 0 ]; then
        printf "${GREEN}[MOK]${DEF_COLOR}\n"
    fi

    rm valgrind_output.txt
}

printf "${CYAN}"

cat << "EOF"
   ____  _    _ _______ _____  _    _ _______   _____        _____ _______ 
  / __ \| |  | |__   __|  __ \| |  | |__   __| |  __ \ /\   |  __ \__   __|
 | |  | | |  | |  | |  | |__) | |  | |  | |    | |__) /  \  | |__) | | |   
 | |  | | |  | |  | |  |  ___/| |  | |  | |    |  ___/ /\ \ |  _  /  | |   
 | |__| | |__| |  | |  | |    | |__| |  | |    | |  / ____ \| | \ \  | |   
  \____/ \____/   |_|  |_|     \____/   |_|    |_| /_/    \_\_|  \_\ |_|   
                                                                                                                                       
EOF

printf "${DEF_COLOR}"

for map_file in TESTbad_map/*ber; do
    check_output "$map_file"
done

printf "\n"

printf "${YELLOW}"

cat << "EOF"
  _      ______          _  __ _____   _____        _____ _______ 
 | |    |  ____|   /\   | |/ // ____| |  __ \ /\   |  __ \__   __|
 | |    | |__     /  \  | ' /| (___   | |__) /  \  | |__) | | |   
 | |    |  __|   / /\ \ |  <  \___ \  |  ___/ /\ \ |  _  /  | |   
 | |____| |____ / ____ \| . \ ____) | | |  / ____ \| | \ \  | |   
 |______|______/_/    \_\_|\_\_____/  |_| /_/    \_\_|  \_\ |_|   
                                                                                                                         
EOF

printf "${DEF_COLOR}"

# Check IF ERROR MAP GOT LEAKS
check_for_leaks "TESTbad_map/map1.ber" "Too much exit." "map1.ber"
check_for_leaks "TESTbad_map/map2.ber" "Too much start." "map2.ber"
check_for_leaks "TESTbad_map/map3.ber" "No exit found." "map3.ber"
check_for_leaks "TESTbad_map/map4.ber" "Map contains an empty line." "map4.ber"
check_for_leaks "TESTbad_map/map5.ber" "Map contains an empty line." "map5.ber"
check_for_leaks "TESTbad_map/map6.ber" "Map contains an empty character." "map6.ber"
check_for_leaks "TESTbad_map/map7.ber" "No collectibles found." "map7.ber"
check_for_leaks "TESTbad_map/map8.ber" "Map is oo big" "map8.ber"
check_for_leaks "TESTbad_map/map9.ber" "No collectibles found." "map9.ber"
check_for_leaks "TESTbad_map/map10.ber" "Too much exit." "map10.ber"
check_for_leaks "TESTbad_map/map11.ber" "Map contains an empty character." "map11.ber"
check_for_leaks "TESTbad_map/map12.ber" "Map is not rectangular" "map12.ber"
check_for_leaks "TESTbad_map/map13.ber" "No start found." "map13.ber"
check_for_leaks "TESTbad_map/map14.ber" "Unknown character in the map." "map14.ber"
check_for_leaks "TESTbad_map/map15.ber" "No path found." "map15.ber"
check_for_leaks "TESTbad_map/map16.ber" "No path found." "map16.ber"
check_for_leaks "TESTbad_map/map17.ber" "Unknown character in the map." "map17.ber"
check_for_leaks "TESTbad_map/map18.ber" "No collectibles found." "map18.ber"
check_for_leaks "TESTbad_map/map19.ber" "No exit found." "map19.ber"
check_for_leaks "TESTbad_map/map20.ber" "Map is not rectangular." "map20.ber"

# Check if classic maps got leaks
check_for_leaks "TESTgood_map/map1.ber" "Perfect Map" "map1.ber"
check_for_leaks "TESTgood_map/map2.ber" "Perfect Map" "map2.ber"

printf "${MAGENTA}"

cat << "EOF"

  _____  ______  _____ _______ _____   ______     __  _____        _____ _______ 
 |  __ \|  ____|/ ____|__   __|  __ \ / __ \ \   / / |  __ \ /\   |  __ \__   __|
 | |  | | |__  | (___    | |  | |__) | |  | \ \_/ /  | |__) /  \  | |__) | | |   
 | |  | |  __|  \___ \   | |  |  _  /| |  | |\   /   |  ___/ /\ \ |  _  /  | |   
 | |__| | |____ ____) |  | |  | | \ \| |__| | | |    | |  / ____ \| | \ \  | |   
 |_____/|______|_____/   |_|  |_|  \_\\____/  |_|    |_| /_/    \_\_|  \_\ |_|   
                                                                                                                                                                                                                                                                                      
EOF

printf "${DEF_COLOR}"

read -p "Enter the path of the directory where the .xpm files are located: " repertoire

check_leak_images () {
    local map="$1"
    local repertoire="$2"
    
    if [ ! -d "$repertoire" ]; then
        printf "${RED}Bad directory : $repertoire${DEF_COLOR}\n"
        return 1
    fi

    local fichiers_xpm=$(find "$repertoire" -type f -name "*.xpm")

    if [ -n "$fichiers_xpm" ]; then
        for fichier in $fichiers_xpm; do
            local nom_base=$(basename "$fichier" .xpm)
            
            local nouveau_nom="prefixe_$nom_base.xpm"
            mv "$fichier" "$nouveau_nom"
            
            valgrind ./so_long "$map" > valgrind_output.txt 2>&1
            
            if grep -q "definitely lost" valgrind_output.txt; then
                printf "${RED}[MKO]${DEF_COLOR}\n"
            else
                printf "${GREEN}[MOK]${DEF_COLOR}\n"
            fi
            
            rm valgrind_output.txt
            
            mv "$nouveau_nom" "$fichier"
        done
    else
        printf "${RED}No .xpm files found in $repertoire or its subdirectories.${DEF_COLOR}\n"
    fi
}

check_leak_images "TESTgood_map/map1.ber" "$repertoire"

rm -rf TESTgood_map/
rm -rf TESTbad_map/