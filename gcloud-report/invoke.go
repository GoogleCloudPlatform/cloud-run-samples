// Copyright 2020 Google LLC
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

// [START cloudrun_report_server]

// Service gcloud-report is a Cloud Run shell-script-as-a-service.
package main

import (
	"log"
	"net/http"
	"os"
	"os/exec"
	"regexp"
)

func main() {
	http.HandleFunc("/", scriptHandler)

	// Determine port for HTTP service.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
		log.Printf("defaulting to port %s", port)
	}

	// Start HTTP server.
	log.Printf("listening on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func scriptHandler(w http.ResponseWriter, r *http.Request) {
	search := r.URL.Query().Get("search")
	re := regexp.MustCompile(`^[a-z]+[a-z0-9\-]*$`)
	if !re.MatchString(search) {
		log.Printf("invalid search criteria %q, using default", search)
		search = "."
	}

	cmd := exec.CommandContext(r.Context(), "/bin/bash", "script.sh", search)
	cmd.Stderr = os.Stderr
	out, err := cmd.Output()
	if err != nil {
		log.Printf("Command.Output: %v", err)
		http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
		return
	}
	w.Write(out)
}

// [END cloudrun_report_server]
