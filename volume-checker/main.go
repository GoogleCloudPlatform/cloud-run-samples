// Copyright 2023 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
