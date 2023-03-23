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
import wso2_office_booking_service.types;
import wso2_office_booking_service.utils;

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
public function getAllBookings(string email, time:Civil startingDate) returns types:Booking[]|error {
    types:Booking[] bookings = [];
    stream<types:Booking, error?> resultStream = dbClient->query(getAllBookingsQuery(email, utils:dateToDateString(startingDate)));

    _ = check resultStream.forEach(function(types:Booking booking) {
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
public function getBookingById(string bookingId) returns types:Booking|error? {
    types:Booking|error result = dbClient->queryRow(getBookingByIdQuery(bookingId));
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
public function getBookingByDate(string email, string date, string bookingId = "none") returns types:Booking|error? {
    stream<types:Booking, error?> resultStream = dbClient->query(getBookingByDateQuery(email, date, bookingId));
    types:Booking[] result = check from var booking in resultStream
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
public function getTodaysBookings() returns types:Booking[]|error {
    time:Civil today = time:utcToCivil(time:utcNow());
    string date = utils:dateToDateString(today);
    types:Booking[] bookings = [];
    stream<types:Booking, error?> resultStream = dbClient->query(getTodaysBookingsQuery(date));
    _ = check resultStream.forEach(function(types:Booking booking) {
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
public function addNewBooking(types:Booking booking) returns types:DbOperationSuccessResult|error {
    sql:ExecutionResult result = check dbClient->execute(addNewBookingQuery(booking));
    return result.cloneWithType(types:DbOperationSuccessResult);
}

# Edit an existing booking
#
# + existingBooking - Already present booking 
# + newBookingDetails - New Details to be updated
# + return - Success result or error
public function updateBooking(types:Booking existingBooking,types:Booking newBookingDetails) returns types:DbOperationSuccessResult|error {
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
public function getAllSchedules(string email) returns types:Schedule[]|error{
    types:Schedule[] schedules = [];
    stream<types:Schedule,error?> resultStream = dbClient->query(getAllSchedulesQuery(email));
    _ = check resultStream.forEach(function(types:Schedule schedule){
        schedules.push(schedule);
    });

    check resultStream.close();
    return schedules;
}

# Get details of the schedule with the given email and the scheduleId
# 
# + scheduleId - Schedule ID
# + return - Schedule with the given ID or error record
public function getScheduleById(string scheduleId) returns types:Schedule|error? {
    types:Schedule|error result = dbClient->queryRow(getScheduleByIdQuery(scheduleId));
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
public function getScheduleByName(string scheduleName, string email, string scheduleId) returns types:Schedule|error?{
    types:Schedule|error result = dbClient->queryRow(getScheduleByNameQuery(scheduleName, email, scheduleId));
    if result is sql:NoRowsError{
        return ();
    }
    return result;
}

# Get details of the currently active schedule under the given user
#
# + email - User email
# + return - active schedule or error
public function getActiveSchedule(string email) returns types:Schedule|error?{
    types:Schedule|error result = dbClient->queryRow(getActiveScheduleQuery(email));
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
public function addNewSchedule(types:Schedule schedule) returns types:DbOperationSuccessResult|error {
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
public function updateSchedule(types:Schedule existingSchedule,types:Schedule newScheduleDetails) returns types:DbOperationSuccessResult|error {
    newScheduleDetails.keys().forEach(function(string key) {
        existingSchedule[key] = newScheduleDetails[key];
    });

    sql:ExecutionResult result = check dbClient->execute(updateScheduleQuery(existingSchedule));
    return result.cloneWithType(types:DbOperationSuccessResult);
}

# Add multiple bookings from a schedule
#
# + bookings - bookings array
# + return - success result or error
public function addBookingsFromSchedule(types:Booking[] bookings) returns types:DbOperationSuccessResult|error{
    sql:ExecutionResult[] _ = check dbClient->batchExecute(addBookingsFromScheduleQuery(bookings));
    return {
        affectedRowCount:bookings.length()
    };
}

# Delete multiple bookings from a schedule
#
# + scheduleId - bookings array
# + email - user email
# + return - success result or error
public function deleteBookingsByScheduleId(string scheduleId, string email) returns types:DbOperationSuccessResult|error{
    sql:ExecutionResult result = check dbClient->execute(deleteBookingByScheduleIdQuery(scheduleId, email));
    return result.cloneWithType(types:DbOperationSuccessResult);
}


# Activate a schedule and add bookings accordingly
#
# + scheduleId - ID of the schedule  
# + email - User email  
# + bookings - Bookings to be added
# + return - Success result or erro
public function activateSchedule(string scheduleId, string email, types:Booking[] bookings) returns types:DbOperationSuccessResult|error{
    transaction {        
        types:DbOperationSuccessResult|error addBookingResult = addBookingsFromSchedule(bookings);
        sql:ExecutionResult|error scheduleActivationResult = dbClient->execute(activateScheduleQuery(scheduleId, email));
        if addBookingResult is error || scheduleActivationResult is error{
            rollback;
            return error(utils:DATABASE_ERROR);
        } else{
            check commit;
            return addBookingResult;
        }
    }
}

public function deactivateSchedule(string scheduleId, string email) returns types:DbOperationSuccessResult|error{
    transaction {
        types:DbOperationSuccessResult|error deleteBookingResult = deleteBookingsByScheduleId(scheduleId, email);
        sql:ExecutionResult|error scheduleDeactivationResult = dbClient->execute(deactivateScheduleQuery(scheduleId, email));
        if deleteBookingResult is error || scheduleDeactivationResult is error{
            rollback;
            return error(utils:DATABASE_ERROR);
        } else{
            check commit;
            return deleteBookingResult;
        }
    }
}



