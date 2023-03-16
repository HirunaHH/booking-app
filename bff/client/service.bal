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
        database:Booking[]|error result = database:getAllBookings(email);
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
        if result is (){
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
        types:DbOperationSuccessResult|error result = database:deleteBookingById(bookingId,email);
        if result is sql:Error {
            return <types:OfficeBookingAppServerError>{
                body: {message: result.detail().toString()}
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
        match validateStatus{
            utils:INVALID_DATE =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "Entered date is invalid"}
                };
            }
            utils:WEEKEND_DATE =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "Cannot add bookings for weekends"}
                };
            }
            utils:INTERNAL_ERROR =>{
                return <types:OfficeBookingAppServerError>{
                    body:{message:"Could not add the booking"}
                };
            }
            utils:PREVIOUS_DATE =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "Cannot add a booking for a previous date"}
                };
            }
            utils:TODAY_NOT_ALLOWED =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "A booking cannot be made for today at this time"}
                };
            }
        }

        time:Civil|error newDate = utils:dateToCivil(booking.date);
        if newDate is error {
            return <types:OfficeBookingAppBadRequestError>{
                body:{message: "Entered date is invalid"}
            };
        }
        if newDate.dayOfWeek == 0 || newDate.dayOfWeek == 6 {
            return <types:OfficeBookingAppBadRequestError>{
                body:{message: "Cannot add bookings for weekends"}
            };
        }

        boolean|error dateOkayResult = utils:compareDates(newDate, ">=", utils:getTodayOrTommorow(utils:ADD_BOOKING_CUTOFF_HOUR).date);
        if dateOkayResult is error {
            return <types:OfficeBookingAppServerError>{
                body:{message:"Could not add the booking"}
            };
        }
        if !dateOkayResult {
            return <types:OfficeBookingAppBadRequestError>{
                body:{message: "Cannot add a booking for a previous date"}
            };
        }

        types:DbOperationSuccessResult|error result = database:addNewBooking(booking);
        if result is error{
            return <types:OfficeBookingAppServerError>{
                body:{message:"Could not add the booking"}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body:result
        };
    }

    # Update an exisiting booking
    # 
    # + booking - booking to be updated
    # + return - operation confirmation details or error responses
    resource function patch bookings/[string bookingId](@http:Payload database:Booking booking) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppBadRequestError|types:OfficeBookingAppServerError {

        string validateStatus = utils:checkBookingDateValidity(booking.date);
        match validateStatus{
            utils:INVALID_DATE =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "Entered date is invalid"}
                };
            }
            utils:WEEKEND_DATE =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "Cannot add bookings for weekends"}
                };
            }
            utils:INTERNAL_ERROR =>{
                return <types:OfficeBookingAppServerError>{
                    body:{message:"Could not edit the booking"}
                };
            }
            utils:PREVIOUS_DATE =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "Cannot change the date to a previous date"}
                };
            }
            utils:TODAY_NOT_ALLOWED =>{
                return <types:OfficeBookingAppBadRequestError>{
                    body:{message: "A booking cannot be made for today at this time"}
                };
            }
        }

        database:Booking|error? existingResult =  database:getBookingById(booking.bookingId.toString());
        if existingResult is (){
            return <types:OfficeBookingAppBadRequestError>{
                body:{message:"Cannot find booking ID"}
            };
        }
        if existingResult is error{
            return <types:OfficeBookingAppServerError>{
                body:{message:"Could not edit the booking"}
            };
        }
        if existingResult.status === utils:BOOKED{
            return <types:OfficeBookingAppBadRequestError>{
                body:{message: "Cannot edit an already confirmed booking"}
            };
        }

        database:Booking|error? dateMatchedResult = database:getBookingByDate(booking.email, utils:dateToDateString(booking.date), booking.bookingId.toString());
        if dateMatchedResult is database:Booking {
            return <types:OfficeBookingAppBadRequestError>{
                body:{message: "A booking already exists for the given date"}
            };
        }
        if dateMatchedResult is error{
            return <types:OfficeBookingAppServerError>{
                body:{message:"Could not edit the booking"}
            };
        }

        types:DbOperationSuccessResult|error result = database:editBooking(existingResult,booking);
        if result is error{
            return <types:OfficeBookingAppServerError>{
                body:{message:"Could not edit the booking"}
            };
        }
        return <types:OfficeBookingAppSuccess>{
            body:result
        };
    }
}