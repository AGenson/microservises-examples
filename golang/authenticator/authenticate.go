package main

import (
	"encoding/json"
	"fmt"
	"github.com/dgrijalva/jwt-go"
	"log"
	"net/http"
	"time"
)

// Create the JWT key used to create the signature
var jwtKey = []byte("microservices")

var users = map[string]string{
	"user1": "password1",
	"user2": "password2",
}

type Credentials struct {
	Password string `json:"password"`
	Username string `json:"username"`
}

// Struct to encode the JWT
type Claims struct {
	Username string `json:"username"`
	jwt.StandardClaims
}

func Signin(w http.ResponseWriter, r *http.Request) {
	var creds Credentials
	// Get json body and decode into credentials
	err := json.NewDecoder(r.Body).Decode(&creds)
	if err != nil {
		// Bad request? Return error
		w.WriteHeader(http.StatusBadRequest)
		return
	}
	fmt.Println("Username: ", creds.Username, " - Password: ", creds.Password)

	// Expected password from map
	expectedPassword, ok := users[creds.Username]
	// If a password exists AND password is equal to existing
	if !ok || expectedPassword != creds.Password {
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	expirationTime := time.Now().Add(5 * time.Minute)
	claims := &Claims{
		Username: creds.Username,
		StandardClaims: jwt.StandardClaims{
			// Time expressed in UNIX timestamp
			ExpiresAt: expirationTime.Unix(),
		},
	}

	// Desclare the token with the algorithm used for signing, and the claims
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	// Create the JWT string
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	// We set the client cookie for "token" for the JWT generated. Also setting an expiration time
	http.SetCookie(w, &http.Cookie{
		Name: "token",
		Value: tokenString,
		Expires: expirationTime,
	})
}

func CheckLogin(w http.ResponseWriter, r *http.Request) {
	c, err := r.Cookie("token")
	if err != nil {
		if err == http.ErrNoCookie {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		w.WriteHeader(http.StatusBadRequest)
	}

	// Get the JWT String from the cookie
	tknStr := c.Value

	// Initialize a new instance of claims
	claims := &Claims{}
	
	// Parse the JWT string. Store the result in claims
	tkn, err := jwt.ParseWithClaims(tknStr, claims, func(token *jwt.Token)(interface{}, error) {
		return jwtKey, nil
	})
	if !tkn.Valid {
		w.WriteHeader(http.StatusUnauthorized)
		return
	}
	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			w.WriteHeader(http.StatusUnauthorized)
			return
		}
		w.WriteHeader(http.StatusBadRequest)
		return
	}

	w.WriteHeader(http.StatusContinue) // The user is fine
}

func serveHTTP(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Server", "A Go Authentication Web Server")
	w.WriteHeader(200)
}

func main() {
	http.HandleFunc("/auth/login", Signin)
	http.HandleFunc("/auth/check", CheckLogin)
	log.Fatal(http.ListenAndServe(":9002", nil))
}
