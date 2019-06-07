module.exports = {
    Config: {
        CallTimeout: 20, // seconds
        ResetTimeout: 30, // seconds
        TripThreshold: 5, // percentage
        RollingWindow: 60 // seconds
    },

    State: {
        Closed: "Closed",
        HalfOpen: "Half Open",
        Open: "Open"
    }
}
