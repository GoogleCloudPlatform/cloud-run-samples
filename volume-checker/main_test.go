package main

import (
	"fmt"
	"io"
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
			message:    "Hello World!",
			statusCode: 200,
		},
	} {
		req := httptest.NewRequest(http.MethodGet, test.endpoint, nil)
		w := httptest.NewRecorder()
		healthCheck(w, req)
		res := w.Result()
		defer res.Body.Close()
		data, err := io.ReadAll(res.Body)
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
		data, err := io.ReadAll(res.Body)
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
