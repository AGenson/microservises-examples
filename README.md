# <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR8zQBk4XXZA2hHPhpXEXy6ht2M5E8LrHFJRmxE2x5j-s4XL-NW" width="35" height="35" /> - Microservices examples

The goal of this project is to set an example of **microservices** architecture using 3 different languages to compare them. More espacially, compare general-purposed language against a language based approchoach with [Jolie](https://www.jolie-lang.org/).

We then have chosen the following languages:
- [Golang](https://golang.org/)
- [Node.js](https://nodejs.org/en/) (JavaScript)
- [Jolie](https://www.jolie-lang.org/)

For purpose of this project we create a **calculator** service for the following scenarios of microservices architecture:

- A simple calculator service alone
- An authentification system around the calculator
- The circuit breaker pattern over the calculator service
- An authentification system covering the circuit breaker pattern above
- The circuit breaker pattern over the authenticated system and calculator
