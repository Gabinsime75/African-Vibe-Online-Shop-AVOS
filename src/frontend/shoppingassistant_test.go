package main

import (
	"encoding/base64"
	"testing"
)

func TestDecodeImageDataURL(t *testing.T) {
	payload := []byte("avos-image")
	dataURL := "data:image/png;base64," + base64.StdEncoding.EncodeToString(payload)

	image, mediaType, err := decodeImageDataURL(dataURL)
	if err != nil {
		t.Fatalf("decodeImageDataURL returned an error: %v", err)
	}
	if string(image) != string(payload) {
		t.Fatalf("decoded image = %q, want %q", image, payload)
	}
	if mediaType != "image/png" {
		t.Fatalf("media type = %q, want image/png", mediaType)
	}
}

func TestDecodeImageDataURLRejectsUnsupportedMediaType(t *testing.T) {
	_, _, err := decodeImageDataURL("data:text/plain;base64,YXZvcw==")
	if err == nil {
		t.Fatal("decodeImageDataURL accepted a non-image media type")
	}
}
