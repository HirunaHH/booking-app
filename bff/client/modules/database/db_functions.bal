// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/time;
import wso2_office_booking.types;
import wso2_office_booking.utils;

configurable readonly & DatabaseConfig databaseConfig = ?;

// create the database client with configureable credentials
final mysql:Client dbClient = check new (
    host = databaseConfig.host, user = databaseConfig.user, password = databaseConfig.password, port = databaseConfig.port, database = databaseConfig.name
);

# Get all the bookings with the given email
# 
# + email - Email
# + return - Return an array of all the bookings
public function getAllBookings(string email) returns Booking[]|error {
    Booking[] bookings = [];
    stream<Booking, error?> resultStream = dbClient->query(getAllBookingsQuery(email, utils:dateToDateString(utils:getTodayOrTommorow(utils:SHOW_BOOKINGS_CUTOFF_HOUR).date)));

    _ = check resultStream.forEach(function(Booking booking) {
        bookings.push(booking);
    });

    check resultStream.close();
    return bookings;
}

// TODO : use queryRow() istead of query() -- Done
# Get details of the booking with the given email and the booking_id
# 
# + booking_id - Booking ID
# + return - Booking with the given ID or error record
public function getBookingById(string booking_id) returns Booking|error? {
    Booking|error result = dbClient->queryRow(getBookingByIdQuery(booking_id));

    if result is sql:NoRowsError{
        return ();
    }
    return result;
}

# Get details of the booking with the given email and the date
# 
# + email - Email 
# + date - Date
# + bookingId - Booking ID
# + return - Booking with the given ID or error record
public function getBookingByDate(string email, string date, string bookingId = "none") returns Booking|error? {
    stream<Booking, error?> resultStream = dbClient->query(getBookingByDateQuery(email, date, bookingId));
    Booking[] result = check from var booking in resultStream
        select booking;
    if result.length() > 0 {
        return result[0];
    } else {
        return ();
    }
}

# Get the active booking list on current date
# 
# + return - active booking list with the date matching to current date or error
public function getTodaysBookings() returns Booking[]|error {
    time:Civil today = time:utcToCivil(time:utcNow());
    string date = utils:dateToDateString(today);
    Booking[] bookings = [];
    stream<Booking, error?> resultStream = dbClient->query(getTodaysBookingsQuery(date));
    _ = check resultStream.forEach(function(Booking booking) {
        bookings.push(booking);
    });

    check resultStream.close();
    return bookings;
}

# Delete the booking with the given email and booking_id
# 
# + bookingId - Booking ID
# + email - Email
# + return - Operation success results or error records
public function deleteBookingById(string bookingId, string email) returns types:DbOperationSuccessResult|error {
    sql:ExecutionResult result = check dbClient->execute(deleteBookingByIdQuery(bookingId,email));

    // TODO : handle the nil value -- Done
    if result.affectedRowCount <= 0 {
        return error("Could not find the booking Id : " + bookingId);
    }
    return result.cloneWithType(types:DbOperationSuccessResult);
}


# Add new booking
# 
# + booking - The new booking
# + return - Success result 
public function addNewBooking(Booking booking) returns types:DbOperationSuccessResult|error {
    sql:ExecutionResult result = check dbClient->execute(addNewBookingQuery(booking));
    return result.cloneWithType(types:DbOperationSuccessResult);
}

# Edit an existing booking
#
# + existingBooking - Already present booking 
# + newBookingDetails - New Details to be updated
# + return - Success result or error
public function editBooking(Booking existingBooking,Booking newBookingDetails) returns types:DbOperationSuccessResult|error {
    newBookingDetails.keys().forEach(function(string key) {
        existingBooking[key] = newBookingDetails[key];
    });

    sql:ExecutionResult result = check dbClient->execute(editBookingQuery(existingBooking));
    return result.cloneWithType(types:DbOperationSuccessResult);
}

