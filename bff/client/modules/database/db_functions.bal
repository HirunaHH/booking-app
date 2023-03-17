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
# + startingDate - date from which onwards the booking will be shown
# + return - Return an array of all the bookings
public function getAllBookings(string email, time:Civil startingDate) returns Booking[]|error {
    Booking[] bookings = [];
    stream<Booking, error?> resultStream = dbClient->query(getAllBookingsQuery(email, utils:dateToDateString(startingDate)));

    _ = check resultStream.forEach(function(Booking booking) {
        bookings.push(booking);
    });

    check resultStream.close();
    return bookings;
}

// TODO : use queryRow() istead of query() -- Done
# Get details of the booking with the given email and the bookingId
# 
# + bookingId - Booking ID
# + return - Booking with the given ID or error record
public function getBookingById(string bookingId) returns Booking|error? {
    Booking|error result = dbClient->queryRow(getBookingByIdQuery(bookingId));
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

# Delete the booking with the given email and bookingId
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
public function updateBooking(Booking existingBooking,Booking newBookingDetails) returns types:DbOperationSuccessResult|error {
    newBookingDetails.keys().forEach(function(string key) {
        existingBooking[key] = newBookingDetails[key];
    });

    sql:ExecutionResult result = check dbClient->execute(updateBookingQuery(existingBooking));
    return result.cloneWithType(types:DbOperationSuccessResult);
}

# Get all the schedules under the given user email
#
# + email - User email
# + return - Array of schedules or error
public function getAllSchedules(string email) returns Schedule[]|error{
    Schedule[] schedules = [];
    stream<Schedule,error?> resultStream = dbClient->query(getAllSchedulesQuery(email));
    _ = check resultStream.forEach(function(Schedule schedule){
        schedules.push(schedule);
    });

    check resultStream.close();
    return schedules;
}

# Get details of the schedule with the given email and the scheduleId
# 
# + scheduleId - Schedule ID
# + return - Schedule with the given ID or error record
public function getScheduleById(string scheduleId) returns Schedule|error? {
    Schedule|error result = dbClient->queryRow(getScheduleByIdQuery(scheduleId));
    if result is sql:NoRowsError{
        return ();
    }
    return result;
}

# Get details of the schedule with the given name
#
# + scheduleName - Name of the schedule 
# + email - User email
# + scheduleId - scheduleId
# + return - Schedule with the given name or error
public function getScheduleByName(string scheduleName, string email, string scheduleId) returns Schedule|error?{
    Schedule|error result = dbClient->queryRow(getScheduleByNameQuery(scheduleName, email, scheduleId));
    if result is sql:NoRowsError{
        return ();
    }
    return result;
}

# Get the count of not deleted scheduls under a given email
#
# + email - Email
# + return - count or error
public function getSchedulesCount(string email) returns int|error{
    int|error result = dbClient->queryRow(getScheduleCountQuery(email));
    return result;
}

# Add new scheduke
# 
# + schedule - The new schedule
# + return - Success result 
public function addNewSchedule(Schedule schedule) returns types:DbOperationSuccessResult|error {
    sql:ExecutionResult result = check dbClient->execute(addNewScheduleQuery(schedule));
    return result.cloneWithType(types:DbOperationSuccessResult);
}

# Delete the schedule with the given email and scheduleId
# 
# + scheduleId - schedule ID
# + email - Email
# + return - Operation success results or error records
public function deleteScheduleById(string scheduleId, string email) returns types:DbOperationSuccessResult|error {
    sql:ExecutionResult result = check dbClient->execute(deleteScheduleByIdQuery(scheduleId));

    if result.affectedRowCount <= 0 {
        return error("Could not find the schedule Id : " + scheduleId);
    }
    return result.cloneWithType(types:DbOperationSuccessResult);
}

# Edit an existing schedule
#
# + existingSchedule - Already present schedule 
# + newScheduleDetails - New Details to be updated
# + return - Success result or error
public function updateSchedule(Schedule existingSchedule,Schedule newScheduleDetails) returns types:DbOperationSuccessResult|error {
    newScheduleDetails.keys().forEach(function(string key) {
        existingSchedule[key] = newScheduleDetails[key];
    });

    sql:ExecutionResult result = check dbClient->execute(updateScheduleQuery(existingSchedule));
    return result.cloneWithType(types:DbOperationSuccessResult);
}




