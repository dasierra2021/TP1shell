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
UT_ACCEP=$(zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 5 | uniq ) #on utilise la commande "zgrep" pour rechercher toutes les lignes contenant le texte "Accepted publickey for"; la commande "cut" pour extraire l'identifiant de l'utilisateur; et la commande "uniq" pour éliminer les doublons.
echo "${UT_ACCEP}"
echo "En total, le nombre total d'utilisateurs qui ont réussi à se connecter est:"
zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 5 | uniq | wc -l #"wc -l" pour compter le nombre total d'utilisateurs uniques ayant réussi à se connecter et affiche ce nombre à l'aide de la commande "echo".
;;

"-U")	
echo "Les utilisateurs qui n'ont pas réussi à se connecter sont les suivantes:"
zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 4 | uniq # #on utilise la commande "zgrep" pour rechercher toutes les lignes contenant le texte "Invalid user"; la commande "cut" pour extraire l'identifiant de l'utilisateur; et la commande "uniq" pour éliminer les doublons.
echo "En total, le nombre total d'utilisateurs qui n'ont pas réussi à se connecter est:" 
zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 4 | uniq | wc -l #"wc -l" pour compter le nombre total d'utilisateurs uniques ayant réussi à se connecter et affiche ce nombre à l'aide de la commande "echo".
;;

"-i")
echo "La liste des adresses IP des utilisateurs qui ont réussi à se connecter sont les suivantes:"
IP_ACC=$(zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 7 | uniq | sort -u) #"zgrep" pour rechercher toutes les lignes contenant le texte "Accepted publickey for"; "cut" pour extraire l'adresse IP de l'utilisateur à partir de la septième colonne de chaque ligne; "uniq" pour éliminer les doublons, puis triées par ordre croissant à l'aide de la commande "sort".
echo "${IP_ACC}"
;;

"-I")	
echo "La liste des adresses IP des utilisateurs qui n'ont pas réussi à se connecter sont les suivantes:"
IP_REJ=$(zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 6 | uniq | sort -u) #"zgrep" pour rechercher toutes les lignes contenant le texte "Invalid user"; "cut" pour extraire l'adresse IP de l'utilisateur à partir de la sixieme colonne de chaque ligne; "uniq" pour éliminer les doublons, puis triées par ordre croissant à l'aide de la commande "sort".
echo "${IP_REJ}"
;;

"-b")	
echo "La liste des adresses IP des utilisateurs qui étaient bloqués est la suivante:"
IP_BLOCK=$(zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d " " -f 3 | tr -d '"' | cut -d "/" -f 1 | uniq | sort -u ) # "zgrep" pour rechercher toutes les lignes contenant le texte "Blocking"; "cut" pour extraire l'adresse IP à partir de la troisième colonne de chaque ligne; tr pour supprimer les guillemets doubles qui peuvent être présents dans certaines adresses IP, puis la commande cut pour extraire la partie de l'adresse IP avant le slash.
# Les adresses IP sont ensuite filtrées à l'aide de la commande "uniq" pour éliminer les doublons, puis triées par ordre croissant à l'aide de la commande "sort".
echo "${IP_BLOCK}"
echo "Le nombre total des utilisateurs qui étaient bloqués est:"
zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d " " -f 3 | tr -d '"' | cut -d "/" -f 1 | uniq | wc -l
#this command is a good option to obtain the total number of blocked users because it searches for a specific keyword related to blocking, extracts the necessary information, removes unnecessary characters, and counts the number of unique IP addresses, providing an accurate and concise summary of the number of blocked users.
;;

"-B")	#Cette commande permet d'obtenir une liste des adresses IP qui ont été bloquées, suivie de leur durée totale de blocage en secondes. Elle recherche d'abord le mot-clé "Blocage" dans le fichier journal spécifié par le deuxième argument ($2). Elle utilise ensuite une série de commandes de manipulation de chaînes de caractères pour extraire les informations nécessaires, telles que l'adresse IP et la durée totale de blocage.
#La commande utilise ensuite la commande "awk" pour séparer l'adresse IP du temps de blocage total et additionne le temps de blocage pour chaque adresse IP unique. Enfin, la commande utilise les commandes "sort" et "tr" pour trier et formater les résultats de manière conviviale.
echo "La liste des adresses IP des utilisateurs qui étaient bloquées, ainsi que leur temps de blocage (en secondes) est la suivante:"
zgrep "Blocking" $2 | cut -d "]" -f 2 | cut -d "(" -f 1 | cut -d ":" -f 2 | awk '
{ split($2,ip,"/"); total[ip[1]]+=$4 } END {for (i in total) print i, " time blocked: ", total[i], " secs"}'| tr -d '"' | sort -u
;;

"-n")	#Cette commande est une bonne option pour obtenir cette liste car elle permet de filtrer les adresses IP des utilisateurs qui ont été bloqués, afin de ne garder que ceux qui ont été rejetés mais qui n'ont pas été bloqués. La commande "comm" est particulièrement utile pour cela car elle permet de comparer les deux fichiers et de récupérer les lignes qui n'apparaissent pas dans les deux fichiers.
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
"-D")	#La commande suivante utilise la commande date pour extraire la date et l'heure de chaque ligne du fichier "execD.txt", qui contient tous les attacks provenant de l'adresse IP donnée. La première ligne du résultat (la plus ancienne) correspond à la date de début des attaques, tandis que la dernière ligne (la plus récente) correspond à la date de fin des attaques.
zgrep "Attack from" $2 | zgrep $3 | cut -d ':' -f 2- | cut -d '[' -f 1 | cut -d "m" -f 1 > execD.txt
echo "La date de début des attaques de l'adresse $3 est:"
date +"%D %T" --file=execD.txt | sort -n | head -1
echo "  "
echo "La date de fin des attaques de l'adresse $3 est:"
date +"%D %T" --file=execD.txt | sort -n | tail -1

;;
"-f")	

zgrep "Accepted publickey for" $2 | cut -d ':' -f 2- | cut -d '[' -f 1 | cut -d "m" -f 1 > execf.txt

date +"%W" --file=execf.txt | uniq -c | sed 's/..$//' | tr -d " " | awk '{ total += $1; count++ } END { print total/count }'

;;

"-F")

zgrep "Invalid user"  $2 | cut -d ':' -f 2- | cut -d '[' -f 1 | cut -d "m" -f 1 | sed -e 's/\(.\{6\}\).*/\1/' | uniq -c | sed 's/.......$//' | tr -d " " | awk '{ total += $1; count++ } END { print total/count }'

;;


"-c")

zgrep "Accepted publickey for" $2 | cut -d ':' -f 2- | cut -d '[' -f 1 | cut -d "m" -f 1 > cdate.txt
date +"%s" --file=cdate.txt > cts.txt
zgrep "Accepted publickey for" $2 | cut -d "[" -f 2| cut -d "]" -f 1 > cserveur.txt
zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 5  > cip.txt
zgrep "Accepted publickey for" $2 | cut -d "]" -f 2 | cut -d " " -f 7  > cuser.txt

echo "date;ts;serveur;ip;user" > output.csv
paste cdate.txt cts.txt cserveur.txt cip.txt cuser.txt | awk -F '\t' '{print $1";"$2";"$3";"$4";"$5";"$6}' >> output.csv

;;

"-C")	

zgrep "Invalid user" $2 | cut -d ':' -f 2- | cut -d '[' -f 1 | cut -d "m" -f 1 > cdate2.txt
date +"%s" --file=cdate2.txt > cts2.txt
zgrep "Invalid user" $2 | cut -d "[" -f 2| cut -d "]" -f 1 > cserveur2.txt
zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 6  > cip2.txt
zgrep "Invalid user" $2 | cut -d "]" -f 2 | cut -d " " -f 4  > cuser2.txt

echo "date;ts;serveur;ip;user" > output2.csv
paste cdate2.txt cts2.txt cserveur2.txt cip2.txt cuser2.txt | awk -F '\t' '{print $1";"$2";"$3";"$4";"$5";"$6}' >> output2.csv



;;



esac
