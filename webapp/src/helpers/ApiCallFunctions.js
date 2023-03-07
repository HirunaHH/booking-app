import Logs from "../json-files/data.json";

export function loadBookings(){
    return Logs.logs // API call to load all bookings
}