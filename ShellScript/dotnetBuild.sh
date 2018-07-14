#!/usr/bin/env bash
projectName=$1
version=$2
env=$3

if [ $# -lt 3 ] ; then
echo 'please enter three params(projectName,version,env)'
exit
else
echo 'parmas:projectName:'${projectName}',version:'${version}',env:'${env}' right?(y/n)'
fi

read choice

if [ ${choice} == 'Y' ] || [ ${choice} == 'y' ] ; then
echo 'contiue...'
else
echo 'abort'
exit
fi



if [ ${env} == 'p' ] || [ ${env} == 'P' ] ; then

path='productEnvironmentIp'

else

path='testEnvironmentIp'

fi
echo 'path:'${path}

dotnet restore
dotnet publish -c Release -o out
docker build -t $projectName .
rm -rf out/
docker tag ${projectName}':latest' 'brian/'${projectName}':'${version}
docker rmi -f ${projectName}':latest'
cd ~/work/DockerBuild
docker save 'brian/'${projectName}':'${version} > ${projectName}.tar
scp -i ~/work/pem/SAC1.pem ${projectName}.tar rancher@${path}:~/
rm ${projectName}.tar
ssh -i ~/work/pem/SAC1.pem rancher@${path} << script
docker load < ${projectName}.tar
rm ${projectName}.tar
script
echo 'task done'
