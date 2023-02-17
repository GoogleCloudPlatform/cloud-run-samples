// Package main checks to make sure cloud run volumes have mounted properly
package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", healthCheck)
	http.HandleFunc("/read", readDir)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}

	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "Hello World!")
}

func readDir(w http.ResponseWriter, r *http.Request) {
	dir := r.URL.Query().Get("dir")

	if dir == "" {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, "'dir' query parameter not set")
		return
	}

	entries, err := os.ReadDir(dir)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "error reading directory '%s' within container: %v", dir, err)
		return
	}

	fmt.Fprintf(w, "entries in '%s':\n\n", dir)

	for _, e := range entries {
		fmt.Fprintf(w, "%s/%s\n", dir, e.Name())
	}
}
