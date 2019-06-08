package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"time"
	"gitlab.com/alexanderfalk/utility"
)

type State uint8

const (
	Closed State = 0
	Open State = 1
	Half_Open State = 2
)

var g_state State = 0


type RollingWindow struct  {
	Timestamp int64
	State bool
}

var rolling_window[] RollingWindow 


const response_threshold time.Duration = 5;
const error_rate = 5; // 5 errors over a 60 seconds period
var g_errors int = 0 // Tracking global errors 

// timeout the client request after 20 seconds without a response from the server
func callTO(w http.ResponseWriter, r *http.Request) {
	start := time.Now().Round(time.Second)
	if r.URL.Path == "/calculate" {
		r.Host = utility.Get_location("CalculatorLocation")
	}

	request, err := http.NewRequest(r.Method, "http://localhost:9001"+r.URL.Path, r.Body) // Hard coded, because r.Host doesn't give anything in return
	if err != nil {
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte(err.Error()))
		return
	}
	
    request.Header.Set("X-Forwarded-For", r.RemoteAddr)
	client := &http.Client{}
	resp, err := client.Do(request)
	if err != nil {
		rolling_window = append(rolling_window, RollingWindow{time.Now().Unix(), false})
		fmt.Println(err)
		w.WriteHeader(http.StatusBadRequest)
		w.Write([]byte("Something went wrong during the request. Check if the body is correct"))
		return
	}
	defer resp.Body.Close()
	calc_body, err := ioutil.ReadAll(resp.Body)
	// time.Sleep(6 * time.Second) // Testing if timeout works
	duration := time.Since(start)
	if duration.Round(time.Second) >= response_threshold {
		w.WriteHeader(http.StatusRequestTimeout)
		w.Write([]byte("408 - Request timeout. More than 20 seconds have passed!"))
		g_state = Open
		return
		// Problem occurred
	}
	rolling_window = append(rolling_window, RollingWindow{time.Now().Unix(), true})
	fmt.Println("Success")
	w.Write([]byte(calc_body))
}

// monitor errors over a rolling window of 60 seconds
func rollingWindow() {
	for index, element := range rolling_window {
		if element.Timestamp < (time.Now().Unix() - 1 * 5 * 1000) {
			continue
		} else {
			rolling_window = rolling_window[index:] // Remove everything before the timestamp
			break
		}
	}

	var false_counter int = 0
	var true_counter int = 0
	
	for _, element := range rolling_window {
		if element.State == false {
			false_counter++
		} else {
			true_counter++
		}
	}
	// TripThreshold breached?
	if false_counter != 0 && true_counter != 0 {
		g_errors = false_counter / true_counter * 100
	}
	fmt.Println(len(rolling_window))
}

func circuitbreaker(w http.ResponseWriter, r *http.Request) {
	rollingWindow() // Check if the error rate is too high
	if g_state == Open {
		// Try to ping and see if it is alive
		w.WriteHeader(http.StatusServiceUnavailable)
		w.Write([]byte("503 - Service is unavailable"))
		g_state = Half_Open
		return
	} 
	if g_state == Half_Open {
		callTO(w,r)
		g_state = Closed	
	}
	
	if g_errors >= error_rate {
		fmt.Println("Errors are above 5%. Changing Cycle State...")
		g_state = Open
	} else {
		callTO(w,r)
	}
	// Else we fine. Don't do anything. Just be a happy camper
}

func serveCB(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Server", "Circuit Breaker Go Lang Web Server. Forwarding requests")
	w.WriteHeader(200)
}

func main() {
	http.HandleFunc("/", serveCB)
	http.HandleFunc("/calculate", circuitbreaker)
	log.Fatal(http.ListenAndServe(":9000", nil))
}
