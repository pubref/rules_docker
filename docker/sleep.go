package main

import(
	"os"
	"fmt"
	"time"
	"strconv"
)

func main() {
	if len(os.Args) != 2 {
		panic("Usage: sleep SECONDS")
	}
	seconds := os.Args[1]
	n, err := strconv.Atoi(seconds)
	if err != nil {
		panic("Usage: sleep SECONDS")
	}
	fmt.Println("sleep", seconds)
	time.Sleep(time.Duration(n) * time.Second)
}
