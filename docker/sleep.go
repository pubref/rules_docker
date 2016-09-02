package main

import(
	"os"
	"time"
	"strconv"
)

func main() {
	// Using panic for smaller code size. Not idiomatic.
	if len(os.Args) != 2 {
		panic("Usage: sleep SECONDS")
	}
	seconds := os.Args[1]
	n, err := strconv.Atoi(seconds)
	if err != nil {
		panic("Usage: sleep SECONDS")
	}
	time.Sleep(time.Duration(n) * time.Second)
}
