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
	os.Unsetenv("GCLOUD_REPORT_BUCKET")

	req := httptest.NewRequest("GET", "/", nil)
	rr := httptest.NewRecorder()
	scriptHandler(rr, req)

	want := "gcloud-report: 'GCLOUD_REPORT_BUCKET' not found"
	if got := rr.Body.String(); !strings.Contains(got, want) {
		t.Errorf("body: got %q, want %q", got, want)
	}

	if got, want := rr.Result().StatusCode, http.StatusInternalServerError; got != want {
		t.Errorf("status code: got %q, want %q", got, want)
	}
}

func TestService(t *testing.T) {
	req, err := http.NewRequest("GET", "/", nil)
	if err != nil {
		t.Fatalf("http.NewRequest: %v", err)
	}

	res, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatalf("http.DefaultClient.Do: %v", err)
	}
	defer res.Body.Close()

	out, err := ioutil.ReadAll(res.Body)
	if err != nil {
		t.Fatalf("ioutil.ReadAll: %v", err)
	}

	want := fmt.Sprintf("Wrote the report to gs://%s/report-", os.Getenv("GCLOUD_REPORT_BUCKET"))
	if got := string(out); !strings.Contains(got, want) {
		t.Errorf("got %q, want %q", got, want)
	}
}

func TestServiceSearch(t *testing.T) {
	tests := []struct {
		input string
		want  string
	}{
		{
			// Test a valid name string can be used.
			input: "name",
			want:  fmt.Sprintf("Wrote the report to gs://%s/report-name-", os.Getenv("GCLOUD_REPORT_BUCKET")),
		},
		{
			// Test that default value can be explicitly passed.
			input: ".",
			want:  fmt.Sprintf("Wrote the report to gs://%s/report-.-", os.Getenv("GCLOUD_REPORT_BUCKET")),
		},
		{
			// Test that invalid characters are defaulted to wildcard.
			input: ";",
			want:  fmt.Sprintf("Wrote the report to gs://%s/report-.-", os.Getenv("GCLOUD_REPORT_BUCKET")),
		},
	}

	for _, test := range tests {
		req, err := http.NewRequest("GET", "/", nil)
		if err != nil {
			t.Fatalf("http.NewRequest: %v", err)
		}
		q := req.URL.Query()
		q.Add("search", test.input)
		req.URL.RawQuery = q.Encode()

		res, err := http.DefaultClient.Do(req)
		if err != nil {
			t.Fatalf("http.DefaultClient.Do: %v", err)
		}
		defer res.Body.Close()

		out, err := ioutil.ReadAll(res.Body)
		if err != nil {
			t.Fatalf("ioutil.ReadAll: %v", err)
		}

		if got := string(out); !strings.Contains(got, test.want) {
			t.Errorf("%s: got %q, want %q", test.input, got, test.want)
		}
	}
}
