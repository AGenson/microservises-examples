package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

type Result struct {
	Values struct {
		X int    `json:"x"`
		Y int    `json:"y"`
	} `json:"values"`
	Operator string `json:"operator"`
}

func calculate(w http.ResponseWriter, r *http.Request) {
	var result Result
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		panic(err)
	}
	
	err = json.Unmarshal(body, &result)
	if err != nil {
		// fmt.Println("Format is incorrect")
		log.Fatal("Format is incorrect")
	}
	fmt.Println("x = ", result.Values.X, " y = ", result.Values.Y)
	var responseResult float32 = 0.0
	if result.Operator == "+" {
		responseResult = float32(result.Values.X) + float32(result.Values.Y)
	} else if result.Operator == "-" {
		responseResult = float32(result.Values.X) - float32(result.Values.Y)
	} else if result.Operator == "*" {
		responseResult = float32(result.Values.X) * float32(result.Values.Y)
	} else if result.Operator == "/" {
		responseResult = float32(result.Values.X) / float32(result.Values.Y)
	}

	s := fmt.Sprintf("%f", responseResult)
	w.Write([]byte(s))
}

func serveHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Server", "A Go Web Server")
	w.WriteHeader(200)
}

func main() {
	http.HandleFunc("/calculate", calculate)
	log.Fatal(http.ListenAndServe(":9001", nil))
}
