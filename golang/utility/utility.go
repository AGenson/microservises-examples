package utility

import (
	"bytes"
	"encoding/json"
	"net/http"
	"io/ioutil"
	"io"
	"fmt"
	"log"
)

type Location struct {
	CalculatorLocation string
	AuthenticatorLocation string
}

func Get_location(location string) string {
	//filename is the path to the json config file
	var conf_location Location
	file, err := ioutil.ReadFile("locations.json") 
	if err != nil {  
		panic(err)
	}  
	
	err = json.Unmarshal(file, &conf_location)
	if err != nil {  
		panic(err)
	}
	if location == "CalculatorLocation" {
		return conf_location.CalculatorLocation
	}
	if location == "AuthenticatorLocation" {
		return conf_location.AuthenticatorLocation
	}
	return ""
}

type MyResponseWriter struct {
    http.ResponseWriter
    buf *bytes.Buffer
}

func (mrw *MyResponseWriter) Write(p []byte) (int, error) {
    return mrw.buf.Write(p)
}

func CheckIfLoggedIn(w http.ResponseWriter, r *http.Request) { 
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading body: %v", err)
		http.Error(w, "can't read body", http.StatusBadRequest)
		return
	}

	// Work / inspect body. You may even modify it!
	r.Host = Get_location("AuthenticatorLocation")
	
	request, err := http.NewRequest("GET", r.Host+"/auth/check", r.Body)
	if err != nil {
		return
	}
	
	client := &http.Client{}
	resp, err := client.Do(request)
	if err != nil {
		return
	}
	defer resp.Body.Close()
	if resp.StatusCode == 200 {
		return
	}

	// And now set a new body, which will simulate the same data we read:
	r.Body = ioutil.NopCloser(bytes.NewBuffer(body))
	

	// Create a response wrapper:
	mrw := &MyResponseWriter{
		ResponseWriter: w,
		buf:            &bytes.Buffer{},
	}

	// Now inspect response, and finally send it out:
	// (You can also modify it before sending it out!)
	if _, err := io.Copy(w, mrw.buf); err != nil {
		log.Printf("Failed to send out response: %v", err)
	}
}

func Loginmw(w http.ResponseWriter, r *http.Request) {
	body, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("Error reading body: %v", err)
		http.Error(w, "can't read body", http.StatusBadRequest)
		return
	}

	// Work / inspect body. You may even modify it!
	r.Host = Get_location("AuthenticatorLocation")
	req, err := http.NewRequest("POST", r.Host+"/auth/login", bytes.NewBuffer(body))
	if err != nil {
		return
	}
	fmt.Println(r.Host+"/auth/login")
	client := &http.Client{}
	resp, err := client.Do(req)
	
	if err != nil {
		fmt.Println(err)
	}
	defer resp.Body.Close()
	fmt.Println(resp.StatusCode)

	// And now set a new body, which will simulate the same data we read:
	r.Body = ioutil.NopCloser(bytes.NewBuffer(body))
	

	// Create a response wrapper:
	mrw := &MyResponseWriter{
		ResponseWriter: w,
		buf:            &bytes.Buffer{},
	}

	// If credentials are true, the user gets a token, and we can continue
	if resp.StatusCode == 200 {
		fmt.Println("Logged in")
	} else {
		mrw.WriteHeader(http.StatusUnauthorized)
		w.Header().Set("Authorized", "false")
	}

	// Now inspect response, and finally send it out:
	// (You can also modify it before sending it out!)
	if _, err := io.Copy(w, mrw.buf); err != nil {
		log.Printf("Failed to send out response: %v", err)
	}
}