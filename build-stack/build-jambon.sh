#!/usr/bin/env bash

export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
cd ../jambon/

go mod download
platforms=("linux/386" "linux/amd64")

for platform in "${platforms[@]}"
do
	platform_split=(${platform//\// })
	GOOS=${platform_split[0]}
	GOARCH=${platform_split[1]}
	output_name='jambon-'$GOOS'-'$GOARCH
	if [ $GOOS = "windows" ]; then
		output_name+='.exe'
	fi	

	env GOOS=$GOOS GOARCH=$GOARCH go build -v -o ../build-stack/built-binaries/jambon/$output_name cmd/jambon/main.go
done