# Build a cross-compiled sleep binary as dummy entrypoint for the
# docker run command.
sleep:
	env GOOS=linux GOARCH=386 GOPATH=/Users/pcj/gocode \
        go build -ldflags "-w -d" sleep.go \
        && upx sleep
