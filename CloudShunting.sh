#!/bin/bash

echo Masukan domain!! 
read domain
mkdir $domain

echo ===ENUMERATION FASE===

subfinder -d $domain -silent | anew $domain/subs.txt
assetfinder -subs-only $domain | anew $domain/subs.txt
amass enum -passive -d $domain | anew $domain/subs.txt

cat $domain/subs.txt | httpx -silent | anew $domain/alive.txt

#Emeration domain JavaScript
cat $domain/alive.txt | katana -jc -o $domain/java.txt
cat $domain/java.txt | grep '\.js' | rush 'python3 ~/Tools/SecretFinder/SecretFinder.py -i {} -o cli' | anew $domain/urlfinder.txt
cat $domain/urlfinder.txt | grep -Eo '(cloudservice_url|amazon_aws_url).*' | anew $domain/urlcloudjs.txt
cat $domain/urlcloudjs.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | anew $domain/alives.txt

#Enumerate cloud service with cloud_enum from key product.txt
#cat $domain/alive.txt | grep -oP "(?<=://)[^./\s]+(?=\.$domain)" | sort -u | anew $domain/product.txt # use this if you don't want to use cloud enum
cat $domain/alive.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | sort -u | anew $domain/alives.txt

#~/Tools/cloud_enum/./cloud_enum.py -kf $domain/product.txt -t 10 -l $domain/cloudenum.txt # use this if you don't want to use cloud enum
#cat $domain/cloudenum.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | sort -u | anew $domain/alive-cloudservices.txt # use this if you don't want to use cloud enum
#cat $domain/cloudenum.txt | grep Open | anew $domain/open-cloudservice.txt # use this if you don't want to use cloud enum
#cat $domain/cloudenum.txt | grep OPEN | anew $domain/open-cloudservice.txt # use this if you don't want to use cloud enum


#Parsing Cloud Service Only

cat $domain/alives.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | ./GoCloud | grep -oP 'Is Cloud Service: true\s*\|\s*Service: [^\s]*\s*\|\s*IP: [^\s]*\s*\|\s*Domain:\s*\K[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+' | anew $domain/alive-cloudservice.txt
cat $domain/alive-cloudservice.txt | sort -u | anew $domain/alive-cloudservices.txt
rm $domain/alive-cloudservice.txt

echo ===Exploit FASE===
# Nuclei Exploit 
nuclei -t ~/nuclei-templates/http/takeovers -t ~/nuclei-templates/http/misconfiguration  ~/nuclei-templates/http/cves ~/nuclei-templates/http/vulnerabilities ~/nuclei-templates/http/miscellaneous -l $domain/alive-cloudservices.txt -es info,unknown -etags ssl,network -o $domain/nucleiresult.txt
