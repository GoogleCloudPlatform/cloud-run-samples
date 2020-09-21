package main

import (
	"context"
	"flag"
	"fmt"
	"log"

	"google.golang.org/api/idtoken"
)

func main() {
	target := flag.String("target", "", "Specify the target audience URL")
	flag.Parse()
	if *target == "" {
		log.Fatal("No target specified.")
	}

	ctx := context.Background()
	tokenSource, err := idtoken.NewTokenSource(ctx, *target)
	if err != nil {
		log.Fatalf("idtoken.NewTokenSource: %v", err)
	}
	token, err := tokenSource.Token()
	if err != nil {
		log.Fatalf("idtoken.TokenSource.NewTokenSource: %v", err)
	}

	fmt.Println(token.AccessToken)
}
