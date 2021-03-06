package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"gitlab.com/alexanderfalk/utility"
)

type Result struct {
	Values struct {
		X int    `json:"x"`
		Y int    `json:"y"`
	} `json:"values"`
	Operator string `json:"operator"`
}

func calculate(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		next.ServeHTTP(w, r)
		if w.Header().Get("Authorized") == "false" {
			w.Write([]byte("Not Authorized. Check username and password"))
			return
		}
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
	})
}

func serveHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Server", "An Authenticated Calculator")
	w.WriteHeader(200)
}

func main() {
	login_handler := http.HandlerFunc(utility.Loginmw)
	http.Handle("/calculate", calculate(login_handler))
	log.Fatal(http.ListenAndServe(":9001", nil))
}
