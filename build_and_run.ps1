param(
  [switch]$Push,
  [switch]$Run,
  [string]$Version = 'latest',
  [string]$AppName = 'vcsim',
  [string]$DockerHubUser = 'satak',
  [string]$Folder = '.',
  [int]$InternalPort = 443,
  [int]$externalPort = 443
)

$tag = "$($DockerHubUser)/$($AppName):$($Version)"

docker kill $AppName
docker rm $AppName
docker rmi $AppName
docker build -t $tag $Folder

if ($Push) {
  docker push $tag
}

if ($Run) {
  docker run -it -d --name $appName -p "$($externalPort):$($internalPort)" $tag
}

# delete builder docker image
docker rmi $(docker images --filter "label=builder=true" -q)
