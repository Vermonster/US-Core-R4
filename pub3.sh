#!/bin/bash
# exit when any command fails
set -e
path1=/Users/ehaas/Downloads/org.hl7.fhir.igpublisher.jar
path2=/Users/ehaas/Downloads/org.hl7.fhir.igpublisher-old.jar
path3=/Users/ehaas/Documents/FHIR/IG-tools/
while getopts ds:tonp option
do
 case "${option}"
 in
 d) DEFN=1;;
 s) SOURCE=${OPTARG};;
 t) NA='N/A';;
 o) PUB=1;;
 n) USEDEF=1;;
 p) UPDATE=1;;
 esac
done
echo "================================================================="
echo === Publish $SOURCE IG!!! $(date -u) ===
echo see 'local workflow.md' file for how to use
echo "Optional Parameters"
echo '-d parameter = create definitions files  = ' $DEFN
echo '-n parameter = use definitions source directory definition files  = ' $USEDEF
echo '-s parameter = source directory = ' $SOURCE
echo '-t parameter for no terminology server (run faster and offline)= ' $NA
echo '-o parameter for running previous version of the igpublisher= ' $PUB
echo '-p parameter for downloading latest version of the igpublisher from source = ' $UPDATE
echo ' current directory =' $PWD
echo "================================================================="
echo getting rid of .DS_Store files since they gum up the igpublisher....
find . -name '.DS_Store' -type f -delete
sleep 1
# git status
if [[ $UPDATE ]]; then
echo "================================================================="
echo === get the latest ig-pub file ===
echo "================================================================="
#mv /Users/ehaas/Downloads/org.hl7.fhir.igpublisher.jar /Users/ehaas/Downloads/org.hl7.fhir.igpublisher-old.jar

curl 'https://oss.sonatype.org/service/local/artifact/maven/redirect?r=snapshots&g=org.hl7.fhir.publisher&a=org.hl7.fhir.publisher.cli&v=LATEST&e=jar' -H 'authority: oss.sonatype.org' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' -H 'referer: http://build.fhir.org/downloads.html' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9' --compressed ;
curl 'https://oss.sonatype.org/service/local/repositories/snapshots/content/org/hl7/fhir/publisher/org.hl7.fhir.publisher.cli/0.9.4-SNAPSHOT/org.hl7.fhir.publisher.cli-0.9.4-20190425.204650-1.jar' -H 'authority: oss.sonatype.org' -H 'upgrade-insecure-requests: 1' -H 'user-agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.103 Safari/537.36' -H 'accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3' -H 'referer: http://build.fhir.org/downloads.html' -H 'accept-encoding: gzip, deflate, br' -H 'accept-language: en-US,en;q=0.9' --compressed -o /Users/ehaas/Downloads/org.hl7.fhir.igpublisher.jar
sleep 3
fi

if [[ $DEFN ]]; then
  echo "================================================================="
  echo === run definitions maker with optional source directory name as first argument ===
  echo === create ig.json and ig.xml in $PWD and ../$SOURCE ===
  echo "================================================================="
  python3.5 ${path3}definitions.py $SOURCE
  sleep 3
  git status
fi

if [[ $USEDEF ]]; then

  echo "================================================================="
  echo === use definition files from relative path ../$SOURCE ===
  echo "================================================================="
  cp ../$SOURCE/ig.json $PWD/ig.json
  sed -i "" "s|source/pages|../$SOURCE/source/pages|g" ${PWD}/ig.json
  sed -i "" "s|source/resources|../$SOURCE/source/resources|g" ${PWD}/ig.json
  sed -i "" "s|source/examples|../$SOURCE/source/examples|g" ${PWD}/ig.json
  sleep 3
  git status
fi

if [[ $PUB ]]; then
  echo "================================================================="
  echo === run last known good version of the igpublisherrun most recent version of the igpublisher ===
  echo "================================================================="
  java -jar ${path2} -ig ig.json -watch -tx $NA
else
  echo "================================================================="
  echo ===run most recent version of the igpublisher ===
  echo "================================================================="
  java -jar ${path1} -ig ig.json -watch -tx $NA
fi
