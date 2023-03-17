// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/http;
import wso2_office_booking.database;
import wso2_office_booking.types;
import ballerina/sql;
import wso2_office_booking.utils;
import ballerina/time;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["*"],
        allowMethods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
        allowHeaders: ["jwtassertion", "Authorization", "Content-Type", "apikey", "jwt", "Content-Type", "Accept"],
        allowCredentials: false,
        maxAge: 84900
    }
}

service / on new http:Listener(9090) {

    // TODO : don't return nil -- DONE
    # Get all bookings recorded under the user email
    #
    # + email - User email
    # + return - Array of bookings or error response
    resource function get bookings(string email) returns database:Booking[]|types:OfficeBookingAppServerError {
        time:Civil startingDate = time:utcToCivil(time:utcNow());
        if startingDate.hour > utils:SHOW_BOOKINGS_CUTOFF_HOUR {
            startingDate = time:utcToCivil(time:utcAddSeconds(time:utcNow(), 86400));
        }
        database:Booking[]|error result = database:getAllBookings(email, startingDate);
        if result is error {
            return {
                body: {message: "Cannot retrieve booking list from the database"}
            };
        }
        return result;
    }

    // TODO : Change accordingly to the db_function changes -- DONE
    # Get the booking of specific Id
    #
    # + email - User email
    # + return - Booking record or error responses
    resource function get bookings/[string bookingId](string email) returns database:Booking|types:OfficeBookingAppServerError|types:OfficeBookingAppNotFoundError? {
        database:Booking|error? result = database:getBookingById(bookingId);
        if result is () {
            return <types:OfficeBookingAppNotFoundError>{
                body: {
                    message: "Booking ID does not exist"
                }
            };
        }
        if result is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not retrieve booking details"}
            };
        }
        return result;
    }

    # Delete a booking with a specific Id
    #
    # + email - user email
    # + return - delete confirmation details or error responses
    resource function delete bookings/[string bookingId](string email) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppServerError|types:OfficeBookingAppNotFoundError {
        types:DbOperationSuccessResult|error result = database:deleteBookingById(bookingId, email);
        if result is sql:Error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not delete the booking"}
            };
        }
        if result is error {
            return <types:OfficeBookingAppNotFoundError>{
                body: {message: result.message()}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body: result
        };
    }

    // validate the date inside the resource function. 
    # Add a new booking
    #
    # + booking - new booking to add
    # + return - operation confirmation details or error responses
    resource function post bookings(@http:Payload database:Booking booking) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppBadRequestError|types:OfficeBookingAppServerError {
        string validateStatus = utils:checkBookingDateValidity(booking.date);
        match validateStatus {
            utils:INVALID_DATE => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "Entered date is invalid"}
                };
            }
            utils:WEEKEND_DATE => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "Cannot add bookings for weekends"}
                };
            }
            utils:INTERNAL_ERROR => {
                return <types:OfficeBookingAppServerError>{
                    body: {message: "Could not add the booking"}
                };
            }
            utils:PREVIOUS_DATE => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "Cannot add a booking for a previous date"}
                };
            }
            utils:TODAY_NOT_ALLOWED => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "A booking cannot be made for today at this time"}
                };
            }
        }

        database:Booking|error? dateMatchedResult = database:getBookingByDate(booking.email, utils:dateToDateString(booking.date));
        if dateMatchedResult is database:Booking {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "A booking already exists for the given date"}
            };
        }
        if dateMatchedResult is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not add the booking"}
            };
        }

        types:DbOperationSuccessResult|error result = database:addNewBooking(booking);
        if result is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not add the booking"}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body: result
        };
    }

    # Update an exisiting booking
    #
    # + booking - booking to be updated
    # + return - operation confirmation details or error responses
    resource function patch bookings/[string bookingId](@http:Payload database:Booking booking) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppBadRequestError|types:OfficeBookingAppServerError {

        string validateStatus = utils:checkBookingDateValidity(booking.date);
        match validateStatus {
            utils:INVALID_DATE => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "Entered date is invalid"}
                };
            }
            utils:WEEKEND_DATE => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "Cannot add bookings for weekends"}
                };
            }
            utils:INTERNAL_ERROR => {
                return <types:OfficeBookingAppServerError>{
                    body: {message: "Could not edit the booking"}
                };
            }
            utils:PREVIOUS_DATE => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "Cannot change the date to a previous date"}
                };
            }
            utils:TODAY_NOT_ALLOWED => {
                return <types:OfficeBookingAppBadRequestError>{
                    body: {message: "A booking cannot be made for today at this time"}
                };
            }
        }

        database:Booking|error? existingResult = database:getBookingById(bookingId);
        if existingResult is () {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "Cannot find booking ID"}
            };
        }
        if existingResult is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not edit the booking"}
            };
        }
        if existingResult.status === utils:BOOKED {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "Cannot edit an already confirmed booking"}
            };
        }

        database:Booking|error? dateMatchedResult = database:getBookingByDate(booking.email, utils:dateToDateString(booking.date), booking.bookingId.toString());
        if dateMatchedResult is database:Booking {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "A booking already exists for the given date"}
            };
        }
        if dateMatchedResult is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not edit the booking"}
            };
        }

        types:DbOperationSuccessResult|error result = database:updateBooking(existingResult, booking);
        if result is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not edit the booking"}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body: result
        };
    }

    # Get all schedules recorded under the user email
    #
    # + email - User email
    # + return - Array of schedules or error response 
    resource function get schedules(string email) returns database:Schedule[]|types:OfficeBookingAppServerError {
        database:Schedule[]|error result = database:getAllSchedules(email);
        if result is error {
            return {
                body: {message: result.message()}
            };
        }
        return result;
    }

    # Get the details of a schedule with the given ID
    #
    # + email - User email
    # + return - Array of schedules or error response
    resource function get schedules/[string scheduleId](string email) returns database:Schedule|types:OfficeBookingAppServerError|types:OfficeBookingAppNotFoundError? {
        database:Schedule|error? result = database:getScheduleById(scheduleId);
        if result is () {
            return <types:OfficeBookingAppNotFoundError>{
                body: {
                    message: "Schedule ID does not exist"
                }
            };
        }
        if result is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: result.message()}
            };
        }
        return result;
    }

    # Delete a schedule with a specific Id
    #
    # + email - user email
    # + return - delete confirmation details or error responses
    resource function delete schedules/[string scheduleId](string email) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppServerError|types:OfficeBookingAppNotFoundError {
        types:DbOperationSuccessResult|error result = database:deleteScheduleById(scheduleId, email);
        if result is sql:Error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not delete schedule"}
            };
        }
        if result is error {
            return <types:OfficeBookingAppNotFoundError>{
                body: {message: result.message()}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body: result
        };
    }

    # Add a new schedule
    #
    # + schedule - new schedule to add
    # + return - operation confirmation details or error responses
    resource function post schedules(@http:Payload database:Schedule schedule) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppBadRequestError|types:OfficeBookingAppServerError {

        int|error scheduleCount = database:getSchedulesCount(schedule.email);
        if scheduleCount is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: scheduleCount.message()}
            };
        }

        if scheduleCount == 3 {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "Cannot save more than 3 schedules at a time. Try deleting a schedule before adding new one"}
            };
        }

        database:Schedule|error? nameMatchedResult = database:getScheduleByName(schedule.scheduleName, schedule.email, "none");
        if nameMatchedResult is database:Schedule {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "A schedule already exists for the given name"}
            };
        }
        if nameMatchedResult is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: nameMatchedResult.message()}
            };
        }

        types:DbOperationSuccessResult|error result = database:addNewSchedule(schedule);
        if result is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: result.message()}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body: result
        };
    }

    # Update an exisiting schedule
    #
    # + schedule - schedule to be updated
    # + return - operation confirmation details or error responses
    resource function patch schedules/[string scheduleId](@http:Payload database:Schedule schedule) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppBadRequestError|types:OfficeBookingAppServerError {

        database:Schedule|error? existingResult = database:getScheduleById(scheduleId);
        if existingResult is () {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "Cannot find schedule ID"}
            };
        }
        if existingResult is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not edit the schedule"}
            };
        }
        if existingResult.isActive === true {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "Cannot edit an active schedule. Please deactivate before editing"}
            };
        }

        database:Schedule|error? nameMatchedResult = database:getScheduleByName(schedule.scheduleName, schedule.email, scheduleId.toString());
        if nameMatchedResult is database:Schedule {
            return <types:OfficeBookingAppBadRequestError>{
                body: {message: "A schedule already exists for the given name"}
            };
        }
        if nameMatchedResult is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not edit the schedule"}
            };
        }

        types:DbOperationSuccessResult|error result = database:updateSchedule(existingResult, schedule);
        if result is error {
            return <types:OfficeBookingAppServerError>{
                body: {message: "Could not edit the schedule"}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body: result
        };
    }
}
