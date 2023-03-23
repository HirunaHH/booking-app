// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/http;
import wso2_office_booking_service.database;
import wso2_office_booking_service.types;
import ballerina/sql;
import wso2_office_booking_service.utils;
import ballerina/time;
// import ballerina/io;

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

    # Get all bookings recorded under the user email
    #
    # + email - User email
    # + return - Array of bookings or error response
    resource function get bookings(string email) returns types:Booking[]|types:AppServerError {
        time:Civil startingDate = time:utcToCivil(time:utcNow());
        if startingDate.hour > utils:SHOW_BOOKINGS_CUTOFF_HOUR {
            startingDate = time:utcToCivil(time:utcAddSeconds(time:utcNow(), 86400));
        }
        types:Booking[]|error result = database:getAllBookings(email, startingDate);
        if result is error {
            return {
                body: {message: utils:CANNOT_RETRIEVE_FROM_DB}
            };
        }
        return result;
    }

    # Get the booking of specific Id
    #
    # + return - Booking record or error responses
    resource function get bookings/[string bookingId]() returns types:Booking|types:AppServerError|types:AppNotFoundError {
        types:Booking|error? result = database:getBookingById(bookingId);
        if result is () {
            return <types:AppNotFoundError>{
                body: {
                    message: utils:ID_NOT_FOUND
                }
            };
        }
        if result is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_RETRIEVE_FROM_DB}
            };
        }
        return result;
    }

    # Delete a booking with a specific Id
    #
    # + email - user email
    # + return - delete confirmation details or error responses
    resource function delete bookings/[string bookingId](string email) returns types:AppSuccess|types:AppServerError|types:AppNotFoundError {
        types:DbOperationSuccessResult|error result = database:deleteBookingById(bookingId, email);
        if result is sql:Error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_DELETE_ENTRY}
            };
        }
        if result is error {
            return <types:AppNotFoundError>{
                body: {message: result.message()}
            };
        }
        return <types:AppSuccess>{
            body: result
        };
    }

    # Add a new booking
    #
    # + booking - new booking to add
    # + return - operation confirmation details or error responses
    resource function post bookings(@http:Payload types:Booking booking) returns types:AppSuccess|types:AppBadRequestError|types:AppServerError {

        time:Civil|error newDate = utils:dateToCivil(booking.date);
        time:Civil today = time:utcToCivil(time:utcNow());
        time:Civil tommorow = time:utcToCivil(time:utcAddSeconds(time:utcNow(), 86400));
        boolean|error isToday = false;
        boolean|error isFutureDate = false;

        if newDate is error {
            return <types:AppBadRequestError>{
                body: {message: utils:INVALID_DATE}
            };
        }

        isToday = utils:compareDates(newDate, "=", today);
        if today.hour <= utils:ADD_BOOKING_CUTOFF_HOUR {
            isFutureDate = utils:compareDates(newDate, ">=", today);
        } else {
            isFutureDate = utils:compareDates(newDate, ">=", tommorow);
        }

        if isFutureDate is error || isToday is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_ADD_ENTRY}
            };
        }

        if isToday {
            return <types:AppBadRequestError>{
                body: {message: utils:TODAY_NOT_ALLOWED}
            };
        }

        if !isFutureDate {
            return <types:AppBadRequestError>{
                body: {message: utils:PREVIOUS_DATE}
            };
        }

        if newDate.dayOfWeek == 0 || newDate.dayOfWeek == 6 {
            return <types:AppBadRequestError>{
                body: {message: utils:WEEKEND_DATE}
            };
        }

        types:Booking|error? dateMatchedResult = database:getBookingByDate(booking.email, utils:dateToDateString(booking.date));
        if dateMatchedResult is types:Booking {
            return <types:AppBadRequestError>{
                body: {message: utils:DATE_ALREADY_EXISTS}
            };
        }
        if dateMatchedResult is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_ADD_ENTRY}
            };
        }

        types:DbOperationSuccessResult|error result = database:addNewBooking(booking);
        if result is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_ADD_ENTRY}
            };
        }
        return <types:AppSuccess>{
            body: result
        };
    }

    # Update an exisiting booking
    #
    # + booking - booking to be updated
    # + return - operation confirmation details or error responses
    resource function patch bookings/[string bookingId](@http:Payload types:Booking booking) returns types:AppSuccess|types:AppBadRequestError|types:AppServerError {

        time:Civil|error newDate = utils:dateToCivil(booking.date);
        time:Civil today = time:utcToCivil(time:utcNow());
        time:Civil tommorow = time:utcToCivil(time:utcAddSeconds(time:utcNow(), 86400));
        boolean|error isToday = false;
        boolean|error isFutureDate = false;

        if newDate is error {
            return <types:AppBadRequestError>{
                body: {message: utils:INVALID_DATE}
            };
        }

        isToday = utils:compareDates(newDate, "=", today);

        if today.hour <= utils:ADD_BOOKING_CUTOFF_HOUR {
            isFutureDate = utils:compareDates(newDate, ">=", today);
        } else {
            isFutureDate = utils:compareDates(newDate, ">=", tommorow);
        }

        if isFutureDate is error || isToday is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_ADD_ENTRY}
            };
        }

        if isToday {
            return <types:AppBadRequestError>{
                body: {message: utils:TODAY_NOT_ALLOWED}
            };
        }

        if !isFutureDate {
            return <types:AppBadRequestError>{
                body: {message: utils:PREVIOUS_DATE}
            };
        }

        if newDate.dayOfWeek == 0 || newDate.dayOfWeek == 6 {
            return <types:AppBadRequestError>{
                body: {message: utils:WEEKEND_DATE}
            };
        }

        types:Booking|error? existingResult = database:getBookingById(bookingId);
        if existingResult is () {
            return <types:AppBadRequestError>{
                body: {message: utils:ID_NOT_FOUND}
            };
        }
        if existingResult is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_EDIT_ENTRY}
            };
        }
        if existingResult.status === utils:BOOKED {
            return <types:AppBadRequestError>{
                body: {message: utils:CANNOT_EDIT_CONFIRMED_BOOKING}
            };
        }

        types:Booking|error? dateMatchedResult = database:getBookingByDate(booking.email, utils:dateToDateString(booking.date), booking.bookingId.toString());
        if dateMatchedResult is types:Booking {
            return <types:AppBadRequestError>{
                body: {message: utils:DATE_ALREADY_EXISTS}
            };
        }
        if dateMatchedResult is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_EDIT_ENTRY}
            };
        }

        types:DbOperationSuccessResult|error result = database:updateBooking(existingResult, booking);
        if result is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_EDIT_ENTRY}
            };
        }
        return <types:AppSuccess>{
            body: result
        };
    }

    # Get all schedules recorded under the user email
    #
    # + email - User email
    # + return - Array of schedules or error response 
    resource function get schedules(string email) returns types:Schedule[]|types:AppServerError {
        types:Schedule[]|error result = database:getAllSchedules(email);
        if result is error {
            return {
                body: {message: utils:CANNOT_RETRIEVE_FROM_DB}
            };
        }
        return result;
    }

    # Get the details of a schedule with the given ID
    #
    # + email - User email
    # + return - Array of schedules or error response
    resource function get schedules/[string scheduleId](string email) returns types:Schedule|types:AppServerError|types:AppNotFoundError? {
        types:Schedule|error? result = database:getScheduleById(scheduleId);
        if result is () {
            return <types:AppNotFoundError>{
                body: {
                    message: utils:ID_NOT_FOUND
                }
            };
        }
        if result is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_RETRIEVE_FROM_DB}
            };
        }
        return result;
    }

    # Delete a schedule with a specific Id
    #
    # + email - user email
    # + return - delete confirmation details or error responses
    resource function delete schedules/[string scheduleId](string email) returns types:AppSuccess|types:AppServerError|types:AppNotFoundError {
        types:DbOperationSuccessResult|error result = database:deleteScheduleById(scheduleId, email);
        if result is sql:Error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_DELETE_ENTRY}
            };
        }
        if result is error {
            return <types:AppNotFoundError>{
                body: {message: utils:ID_NOT_FOUND}
            };
        }
        return <types:AppSuccess>{
            body: result
        };
    }

    # Add a new schedule
    #
    # + schedule - new schedule to add
    # + return - operation confirmation details or error responses
    resource function post schedules(@http:Payload types:Schedule schedule) returns types:AppSuccess|types:AppBadRequestError|types:AppServerError {

        int|error scheduleCount = database:getSchedulesCount(schedule.email);
        if scheduleCount is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_ADD_ENTRY}
            };
        }

        if scheduleCount == 3 {
            return <types:AppBadRequestError>{
                body: {message: utils:NOT_MORE_THAN_3_SCHEDULES}
            };
        }

        types:Schedule|error? nameMatchedResult = database:getScheduleByName(schedule.scheduleName, schedule.email, "none");
        if nameMatchedResult is types:Schedule {
            return <types:AppBadRequestError>{
                body: {message: utils:NAME_ALREADY_EXISTS}
            };
        }
        if nameMatchedResult is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_ADD_ENTRY}
            };
        }

        json preferences = schedule.preferences.cloneReadOnly();
        types:WeeklyPreferences weeklyPreferences = <types:WeeklyPreferences>preferences;
        if weeklyPreferences.keys().length() == 0 {
            return <types:AppBadRequestError>{
                body: {message: utils:PREFERENCE_EMPTY}
            };
        }

        types:DbOperationSuccessResult|error result = database:addNewSchedule(schedule);
        if result is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_ADD_ENTRY}
            };
        }
        return <types:AppSuccess>{
            body: result
        };
    }

    # Update an exisiting schedule
    #
    # + schedule - schedule to be updated
    # + return - operation confirmation details or error responses
    resource function patch schedules/[string scheduleId](@http:Payload types:Schedule schedule) returns types:AppSuccess|types:AppBadRequestError|types:AppServerError? {

        types:Schedule|error? existingResult = database:getScheduleById(scheduleId);
        if existingResult is () {
            return <types:AppBadRequestError>{
                body: {message: utils:ID_NOT_FOUND}
            };
        }
        if existingResult is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_EDIT_ENTRY}
            };
        }
        if existingResult.isActive === true {
            return <types:AppBadRequestError>{
                body: {message: utils:CANNOT_EDIT_ACTIVE_SCHEDULE}
            };
        }

        types:Schedule|error? nameMatchedResult = database:getScheduleByName(schedule.scheduleName, schedule.email, scheduleId.toString());
        if nameMatchedResult is types:Schedule {
            return <types:AppBadRequestError>{
                body: {message: utils:NAME_ALREADY_EXISTS}
            };
        }
        if nameMatchedResult is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_EDIT_ENTRY}
            };
        }

        types:DbOperationSuccessResult|error result = database:updateSchedule(existingResult, schedule);
        if result is error {
            return <types:AppServerError>{
                body: {message: utils:CANNOT_EDIT_ENTRY}
            };
        }
        return <types:AppSuccess>{
            body: result
        };
    }

    resource function post activate\-schedule(string scheduleId, string email) returns types:AppSuccess|types:AppBadRequestError|types:AppServerError {

        types:Schedule|error? activeSchedule = database:getActiveSchedule(email);
        if activeSchedule is error{
            return <types:AppServerError>{
                body: {message: utils:INTERNAL_ERROR}
            };
        }

        if activeSchedule is types:Schedule{
             return <types:AppBadRequestError>{
                body: {message: utils:ACTIVE_SCHEDULE_EXIST}
            };           
        }

        types:Schedule|error? schedule = database:getScheduleById(scheduleId);
        if schedule is error {
            return <types:AppServerError>{
                body: {message: utils:INTERNAL_ERROR}
            };
        }

        if schedule is () {
            return <types:AppBadRequestError>{
                body: {message: utils:ID_NOT_FOUND}
            };
        }

        if schedule.isActive === true{
            return <types:AppBadRequestError>{
                body: {message: utils:SCHEDULE_ACTIVE}
            };
        }

        json preferences = schedule.preferences.cloneReadOnly();
        types:WeeklyPreferences weeklyPreferences = <types:WeeklyPreferences>preferences;
        int? recurringWeeks = utils:RECURRING_WEEKS[schedule.recurringMode];
        if recurringWeeks is () {
            return <types:AppServerError>{
                body: {message: utils:INTERNAL_ERROR}
            };
        }
        types:Booking[] bookings = utils:getBookingListBySchedule(weeklyPreferences, recurringWeeks, email, <int>schedule.scheduleId);

        types:DbOperationSuccessResult|error result = database:activateSchedule(scheduleId, email, bookings);
        if result is error{
            return <types:AppServerError>{
                body:{message:result.message()}
            };
        }    
        return <types:AppSuccess>{
            body:result
        };
    }

    resource function post deactivate\-schedule (string scheduleId, string email) returns types:AppSuccess|types:AppBadRequestError|types:AppServerError {

        types:Schedule|error? schedule = database:getScheduleById(scheduleId);
        if schedule is error {
            return <types:AppServerError>{
                body: {message: utils:INTERNAL_ERROR}
            };
        }

        if schedule is () {
            return <types:AppBadRequestError>{
                body: {message: utils:ID_NOT_FOUND}
            };
        }

        if schedule.isActive === false{
            return <types:AppBadRequestError>{
                body: {message: utils:SCHEDULE_NOT_ACTIVE}
            };
        }

        types:DbOperationSuccessResult|error result = database:deactivateSchedule(scheduleId, email);
        if result is error{
            return <types:AppServerError>{
                body:{message:result.message()}
            };
        }    
        return <types:AppSuccess>{
            body:result
        };
    }
}
