#!/bin/bash


# Partie 3: Analyser le fichier

#if [ $# -ne 2 ]
#terminar de arreglar la parte de la entrada de parámetros
#then
#	echo "Entrée invalide. Veuillez réessayer." 
#fi

case $1 in

"-u")	 
echo "Les utilisateurs qui ont réussi à se connecter sont les suivantes:"
UT_ACCEP=$(zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 5 | uniq )
echo "${UT_ACCEP}"
 
echo "En total, le nombre total d'utilisateurs qui ont réussi à se connecter est:"
zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 5 | uniq | wc -l
;;

"-U")	

echo "Les utilisateurs qui n'ont pas réussi à se connecter sont les suivantes:"
zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 4 | uniq 

echo "En total, le nombre total d'utilisateurs qui n'ont pas réussi à se connecter est:"
zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 4 | uniq | wc -l
;;

"-i")
echo "La liste des adresses IP des utilisateurs qui ont réussi à se connecter sont les suivantes:"
IP_ACC=$(zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 7 | uniq | sort -u)
echo "${IP_ACC}"
;;
"-I")	
echo "La liste des adresses IP des utilisateurs qui n'ont pas réussi à se connecter sont les suivantes:"
IP_REJ=$(zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 6 | uniq | sort -u)
echo "${IP_REJ}"
;;

"-b")	

echo "La liste des adresses IP des utilisateurs qui étaient bloqués est la suivante:"
IP_BLOCK=$(zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d " " -f 3 | tr -d '"' | cut -d "/" -f 1 | uniq | sort -u )
echo "${IP_BLOCK}"

echo "Le nombre total des utilisateurs qui étaient bloqués est:"
zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d " " -f 3 | tr -d '"' | cut -d "/" -f 1 | uniq | wc -l


;;

"-B")	
echo "La liste des adresses IP des utilisateurs qui étaient bloquées, ainsi que leur temps de blocage (en secondes) est la suivante:"
zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d "(" -f 1 | cut -d ":" -f 2 | awk '
{ split($2,ip,"/"); total[ip[1]]+=$4 } END {for (i in total) print i, " time blocked: ", total[i], " secs"}'| tr -d '"' | sort -u


;;
"-n")	

zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d " " -f 3 | tr -d '"' | cut -d "/" -f 1 | uniq | sort -u > IP_BLOCK
zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 6 | uniq | sort -u > IP_REJ

echo "La liste des adresses IP des utilisateurs qui étaient rejetés mais pas bloquées est la suivante:"
BPR=$(comm -23 IP_BLOCK IP_REJ)
echo "${BPR}"

echo "Le nombre des utilisateurs qui étaient rejetés mais pas bloquées est:"
echo "${BPR}" | wc -l


;;
"-d")	
echo "La durée moyenne des blocages d'addresses IP est:"
zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d " " -f 5 | awk '
{ sum += $1 } END {print sum/NR, "secs" }'


;;
"-D")	

attF=$(zgrep "Attack from" $2 | zgrep $3 | cut -d ':' -f 2- | cut -d '[' -f 1 | cut -d "m" -f 1 | tail -1)
attD=$(zgrep "Attack from" $2 | zgrep $3 | cut -d ':' -f 2- | cut -d '[' -f 1 | cut -d "m" -f 1 | head -1)

echo "La date de début des attaques de l'adresse $2 est:"
date --date="$attD"

echo "  "

echo "La date de fin des attaques de l'adresse $2 est:"
date --date="$attF"

;;
"-f")	echo "Partie 10: pas fait";;


"-F")	echo "Partie 11: pas fait";;


"-c")	echo "Partie 12: pas fait";;


"-C")	echo "Partie 13: pas fait";;



esac
