package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

// Tests that volume_checker responds with status code 200 to
// health check requests.
func TestHealthCheck(t *testing.T) {
	for _, test := range []struct {
		endpoint   string
		message    string
		statusCode int
	}{
		{
			endpoint:   "/",
			message:    "Servers?? Who needs 'em!",
			statusCode: 200,
		},
	} {
		req := httptest.NewRequest(http.MethodGet, test.endpoint, nil)
		w := httptest.NewRecorder()
		healthCheck(w, req)
		res := w.Result()
		defer res.Body.Close()
		data, err := ioutil.ReadAll(res.Body)
		if err != nil {
			t.Errorf("expected error to be nil got %v", err)
		}
		if string(data) != test.message {
			t.Errorf("want '%s' got '%s'", test.message, string(data))
		}
		if res.StatusCode != test.statusCode {
			t.Errorf("want '%d' got '%d'", test.statusCode, res.StatusCode)
		}
	}
}

// Tests that volume_checker can send an http request to a passed
// URL, for the purpose of checking vpc connectivity.
func TestAddressPing(t *testing.T) {
	expected := "hello world"
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		fmt.Fprintf(w, expected)
	}))
	for _, test := range []struct {
		endpoint   string
		message    string
		statusCode int
	}{
		// Tests that volume_checker can send a request to the passed url
		{
			endpoint:   "/ping",
			message:    "'url' query parameter not set",
			statusCode: 200,
		},
		{
			endpoint:   "/ping?url=foo",
			message:    "GET request to foo yielded error: Get \"foo\": unsupported protocol scheme \"\"",
			statusCode: 500,
		},
		{
			endpoint:   fmt.Sprintf("/ping?url=%s", server.URL),
			message:    fmt.Sprintf("GET request to %s successful. Got response:\n hello world", server.URL),
			statusCode: 200,
		},
	} {
		req := httptest.NewRequest(http.MethodGet, test.endpoint, nil)
		w := httptest.NewRecorder()
		pingAddress(w, req)
		res := w.Result()
		defer res.Body.Close()
		data, err := ioutil.ReadAll(res.Body)
		if err != nil {
			t.Errorf("expected error to be nil got %v", err)
		}
		if string(data) != test.message {
			t.Errorf("want '%s' got '%s'", test.message, string(data))
		}
		if res.StatusCode != test.statusCode {
			t.Errorf("want '%d' got '%d'", test.statusCode, res.StatusCode)
		}
	}
}

// Tests that volume_checker can perform a read on a passed directory,
// and return the files in the directory. This functionality is used
// to allow the user to verify that files populated via a volume
// mount are indeed present in the container at runtime.
func TestReadDir(t *testing.T) {
	path, err := os.Getwd()
	if err != nil {
		t.Errorf("could not get current directory: %v", err)
	}
	targetPath := filepath.Join(path, "testdata")
	targetFile := filepath.Join(path, "testdata", "volume_file.txt")

	for _, test := range []struct {
		endpoint   string
		message    string
		statusCode int
	}{
		{
			endpoint:   "/read",
			message:    "'dir' query parameter not set",
			statusCode: 200,
		},
		{
			endpoint:   "/read?dir=/foo",
			message:    "error reading directory '/foo' within container: open /foo: no such file or directory",
			statusCode: 500,
		},
		{
			endpoint:   fmt.Sprintf("/read?dir=%s", targetPath),
			message:    fmt.Sprintf("entries in '%s':\n\n%s\n", targetPath, targetFile),
			statusCode: 200,
		},
	} {
		req := httptest.NewRequest(http.MethodGet, test.endpoint, nil)
		w := httptest.NewRecorder()
		readDir(w, req)
		res := w.Result()
		defer res.Body.Close()
		data, err := ioutil.ReadAll(res.Body)
		if err != nil {
			t.Errorf("expected error to be nil got %v", err)
		}
		if string(data) != test.message {
			t.Errorf("want '%s' got '%s'", test.message, string(data))
		}
		if res.StatusCode != test.statusCode {
			t.Errorf("want '%d' got '%d'", test.statusCode, res.StatusCode)
		}
	}
}
