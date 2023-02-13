// Package main checks to make sure the nfs volume has mounted properly
package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", healthCheck)
	http.HandleFunc("/read", readDir)
	http.HandleFunc("/ping", pingAddress)

	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal(err)
	}
}

func healthCheck(w http.ResponseWriter, r *http.Request) {
	w.WriteHeader(200)
	fmt.Fprintf(w, "Servers?? Who needs 'em!")
}

func pingAddress(w http.ResponseWriter, r *http.Request) {
	url := r.URL.Query().Get("url")

	if url == "" {
		fmt.Fprintf(w, "'url' query parameter not set")
		w.WriteHeader(http.StatusOK)
		return
	}

	resp, err := http.Get(url)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "GET request to %s yielded error: %v", url, err)
		return
	}
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		fmt.Fprintf(w, "error parsing response body: %v", err)
		return
	}
	sb := string(body)
	w.WriteHeader(http.StatusOK)
	fmt.Fprintf(w, "GET request to %s successful. Got response:\n %s", url, sb)
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
