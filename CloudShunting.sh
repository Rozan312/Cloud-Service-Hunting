#!/bin/bash

echo "Enter the main domain. Example: vulnweb.com!!!"
read domain

# Checking the last status
if [ -f $domain/.status.txt ]; then
  status=$(cat $domain/.status.txt)
else
  status=0
fi

# Checking if the cloud service permutation phase has been previously chosen
if [ -f $domain/.cloud_permutation.txt ]; then
  cloud_permutation=$(cat $domain/.cloud_permutation.txt)
else
  cloud_permutation=0
fi

# ENUMERATION PHASE

if [ $status -le 0 ]; then
  if [ ! -d $domain ]; then
    mkdir $domain

    # Cloud service permutation option
    if [ $cloud_permutation -eq 0 ]; then
      echo "Choose the cloud service permutation option:"
      echo "1. Use cloud_enum (It will take a significant amount of time during the enumeration phase)"
      echo "2. Without using cloud_enum"
      read option

      if [ $option -eq 1 ]; then
        cloud_permutation=1
      elif [ $option -eq 2 ]; then
        cloud_permutation=2
      fi

      echo $cloud_permutation > $domain/.cloud_permutation.txt
    fi
  fi

  # Dorking phase
  echo "===== Fase Dorking ====="
  echo "site:.s3.amazonaws.com | site:.storage.googleapis.com | site:.blob.core.windows.net | site:.amazonaws.com | site:.digitaloceanspaces.com" "$domain" | anew $domain/Dorking-Cloud.txt
  echo 1 > $domain/.status.txt
fi

if [ $status -le 1 ]; then
  echo "===== Fase Enumeration SubDomain ====="
  subfinder -d $domain -silent | anew $domain/subs.txt
  assetfinder -subs-only $domain | anew $domain/subs.txt
  amass enum -passive -d $domain | anew $domain/subs.txt
  echo 2 > $domain/.status.txt
fi

if [ $status -le 2 ]; then
  cat $domain/subs.txt | httpx -silent | anew $domain/alive.txt
  echo 3 > $domain/.status.txt
fi

# Additional phase after status 2
if [ $status -le 3 ]; then
  echo "===== Fase Crawling JS ====="
  cat $domain/alive.txt | katana -jc -o $domain/java.txt
  echo 4 > $domain/.status.txt
fi

# JavaScript-based cloud domain enumeration phase
if [ $status -le 4 ]; then
  echo "===== Fase Enumeration Cloud From JS ====="
  cat $domain/java.txt | grep -oP '(https?://\S+?\.js\b)' | rush 'python3 ~/Tools/SecretFinder/SecretFinder.py -i {} -o cli' | anew $domain/urlfinder.txt
  cat $domain/urlfinder.txt | grep -Eo '(cloudservice_url|amazon_aws_url).*' | anew $domain/urlcloudjs.txt
  cat $domain/urlcloudjs.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | anew $domain/alives.txt
  cat $domain/alive.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | sort -u | anew $domain/alives.txt
  echo 5 > $domain/.status.txt
fi

# Cloud service permutation with or without cloud_enum
if [ $status -le 5 ]; then
  if [ $cloud_permutation -eq 1 ]; then
    echo "===== Fase Permutation Cloud Service ====="
    cat $domain/alive.txt | grep -oP "(?<=://)[^./\s]+(?=\.$domain)" | sort -u | anew $domain/product.txt
    ~/Tools/cloud_enum/./cloud_enum.py -kf $domain/product.txt -t 10 -l $domain/cloudenum.txt
    cat $domain/cloudenum.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | sort -u | anew $domain/alive-cloudservices.txt
    cat $domain/cloudenum.txt | grep Open | anew $domain/open-cloudservice.txt
    cat $domain/cloudenum.txt | grep OPEN | anew $domain/open-cloudservice.txt
    echo 6 > $domain/.status.txt
  fi
fi

# Go Cloud parsing phase
if [ $status -le 6 ]; then
  echo "===== Parsing Only Cloud Services ====="
  cat $domain/alives.txt | grep -o -E '\b([a-zA-Z0-9-]+\.)+[a-zA-Z0-9-]+(:[0-9]+)?(/[\S]*)?\b' | ./GoCloud | grep -oP 'Is Cloud Service: true\s*\|\s*Service: [^\s]*\s*\|\s*IP: [^\s]*\s*\|\s*Domain:\s*\K[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+' | anew $domain/alive-cloudservice.txt
  cat $domain/alive-cloudservice.txt | sort -u | anew $domain/alive-cloudservices.txt
  rm $domain/alive-cloudservice.txt
  echo 7 > $domain/.status.txt
fi

# EXPLOITATION PHASE
if [ $status -le 7 ]; then
  echo "===== Fase Exploitation ====="
  nuclei -t ~/nuclei-templates/http/takeovers -t ~/nuclei-templates/http/misconfiguration -t ~/nuclei-templates/http/cves -t ~/nuclei-templates/http/vulnerabilities -t ~/nuclei-templates/http/miscellaneous -l $domain/alive-cloudservices.txt -es info,unknown -etags ssl,network -o $domain/nucleiresult.txt
  echo 8 > $domain/.status.txt
fi

# Removing the status file
rm $domain/.status.txt
