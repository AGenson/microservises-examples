# Microservice Development with Golang

This test of creating microservices with Golang comes with different scenarios to check the ease of use.  
Six scenarios have been tested:  
1.	Calculator as a standalone service
2.	Authenticator as a standalone service
3.	Authenticated Calculator, where authentication intercept / becomes middleware
4.	Circuit Breaker on Calculator
5.	Authenticated Circuit Breaker on Calculator
6.	Circuit Breaker on Authenticated Calculator
  
Every executable is stored in the 'bin' folder, which is where you have to look if you want to test out different scenarios.  
In the Calculator folder, you have the Calculator standalone service, which can be run by executing "calculator.exe". The Authenticator standalone service can be run by executing "authenticator.exe". The Circuit Breaker standalone service can be run by executing "circuit_breaker.exe".  
If you want to test out the different scenarios, executables have been provided for testing. The "authcalculator.exe" provides the authentication mechanism in front of the Calculator, where the "authcircuitbreaker.exe" provides authentication in front of the Circuit Breaker. To test out the differet scenarios, you have to do the following:  
  
1. Start the calculator.exe and execute a request against "http://localhost:9001/calculate"
2. Start the authenticator.exe and execute a request against "http://localhost:9002/auth/login" or "http://localhost:9002/auth/check" with the username "user1" and password "password1", which have to be a part of a JSON body. 
3. Start authcalculator.exe and execute against "http://localhost:9001/calculate. Use the following JSON body: 

    `{
        "values": {
            "x": 5,
            "y": 20
        },
        "operator": "*",
        "username":"user1",
        "password":"password1"
    }`
    
    You are receiving a HTTP Statuscode 401 if you are unauthorized and 200 if you get logged in and the result of the calculation. 
4. Start the circuitbreaker.exe and calculator.exe. Execute a request against "http://localhost:9000/calculate", which is an endpoint of the Circuit Breaker and is going to proxy the request to the Calculator, but checks for errors and timeouts during the request. 
5. Start authcircuitbreaker.exe and do the exact same as 4. The only difference is, you have to use the body of item 3. 
6. Start circuitbreaker.exe and authcalculator.exe. Do the exact same as 4 and use the body of item 3. 


