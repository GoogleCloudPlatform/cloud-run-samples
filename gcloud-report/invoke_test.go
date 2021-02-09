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

package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
)

func TestScriptHanlderErrorsNoBucket(t *testing.T) {
	original := os.Getenv("GCLOUD_REPORT_BUCKET")
	os.Unsetenv("GCLOUD_REPORT_BUCKET")
	defer os.Setenv("GCLOUD_REPORT_BUCKET", original)

	req := httptest.NewRequest("GET", "/", nil)
	rr := httptest.NewRecorder()
	logBytes := callHandler(scriptHandler, rr, req, t)

	want := "gcloud-report: 'GCLOUD_REPORT_BUCKET' not found"
	if got := string(logBytes); !strings.Contains(got, want) {
		t.Errorf("logs: got %q, want %q", got, want)
	}

	if got, want := rr.Result().StatusCode, http.StatusInternalServerError; got != want {
		t.Errorf("status code: got %q, want %q", got, want)
	}
}

func TestScriptHandler(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{
			// Test empty search parameter can be used.
			input: "",
			want:  fmt.Sprintf("Wrote report to gs://%s/report-.-", os.Getenv("GCLOUD_REPORT_BUCKET")),
		},
		{
			// Test a valid name string can be used.
			input: "name",
			want:  fmt.Sprintf("Wrote report to gs://%s/report-name-", os.Getenv("GCLOUD_REPORT_BUCKET")),
		},
		{
			// Test that default value can be explicitly passed.
			input: ".",
			want:  fmt.Sprintf("Wrote report to gs://%s/report-.-", os.Getenv("GCLOUD_REPORT_BUCKET")),
		},
		{
			// Test that invalid characters are defaulted to wildcard.
			input: ";",
			want:  fmt.Sprintf("Wrote report to gs://%s/report-.-", os.Getenv("GCLOUD_REPORT_BUCKET")),
		},
	}

	for _, test := range tests {
		req := httptest.NewRequest("GET", "/", nil)
		q := req.URL.Query()
		q.Add("search", test.input)
		req.URL.RawQuery = q.Encode()
		rr := httptest.NewRecorder()

		scriptHandler(rr, req)

		if got := rr.Body.String(); !strings.Contains(got, test.want) {
			t.Errorf("Search(%s): got %q, want %q", test.input, got, test.want)
		}
	}
}

// callHandler calls an HTTP handler with the provided request and returns the log output.
func callHandler(h func(w http.ResponseWriter, r *http.Request), rr http.ResponseWriter, req *http.Request, t *testing.T) []byte {
	t.Helper()

	// Rewrite stdout and stderr to an io.ReadCloser.
	// Allows capturing both golang and shell log output.
	r, scriptWriter, _ := os.Pipe()
	originalStderr := os.Stderr
	originalStdout := os.Stdout
	os.Stderr = scriptWriter
	os.Stdout = scriptWriter
	defer func() {
		os.Stderr = originalStderr
		os.Stdout = originalStdout
	}()

	h(rr, req)
	scriptWriter.Close()

	out, err := ioutil.ReadAll(r)
	if err != nil {
		t.Fatalf("ioutil.ReadAll: %v", err)
	}

	return out
}
