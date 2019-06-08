package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"time"
)

func main() {

	requestBody, err := json.Marshal(map[string]interface{}{
		"x":        5,
		"y":        8,
		"operator": "+",
	})

	if err != nil {
		panic(err)
	}

	timeout := time.Duration(5 * time.Second)
	client := http.Client{
		Timeout: timeout,
	}

	request, err := http.NewRequest("POST", "http://localhost:8080/calculate", bytes.NewBuffer(requestBody))
	request.Header.Set("Content-Type", "application/json")

	if err != nil {
		panic(err)
	}

	resp, err := client.Do(request)
	if err != nil {
		panic(err)
	}

	defer resp.Body.Close()
	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	fmt.Println("Response: ", string(body))
}
