// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/sql;
import wso2_office_booking_service.utils;
import wso2_office_booking_service.types;

# Query to retrieve all bookings with a specific email
#
# + email - Email
# + date - Date
# + return - sql parameterized query
function getAllBookingsQuery(string email, string date) returns sql:ParameterizedQuery {
    return `
    SELECT 
        * 
    FROM 
        booking 
    WHERE
        email=${email}
        AND active=true
        AND date>=${date}
    ORDER BY 
        date ASC
    `;
}

# Query to retrieve the booking details with a specific email and bookingId
#
# + bookingId - Bookind ID
# + return - sql parameterized query
function getBookingByIdQuery(string bookingId) returns sql:ParameterizedQuery {
    return `
    SELECT 
        *
    FROM
        booking
    WHERE
        active=true
        AND booking_id=${bookingId}
    LIMIT
        1
    `;
}

# Query to retrieve the booking details with a specific email and date
#
# + email - Email
# + date - Date
# + bookingId - Booking ID
# + return - sql parameterized query
function getBookingByDateQuery(string email, string date, string bookingId) returns sql:ParameterizedQuery {
    if bookingId === "none" {
        return `
        SELECT 
            *
        FROM
            booking
        WHERE
            email=${email}
            AND date=${date}
        LIMIT
            1
        `;
    } else {
        return `
        SELECT 
            *
        FROM
            booking
        WHERE
            email=${email}
            AND booking_id!=${bookingId}
            AND date=${date}
        LIMIT
            1
        `;
    }
}

# Query to delete the booking with a specific email and bookingId
#
# + bookingId - Bookind ID
# + email - Email
# + return - sql parameterized query
function deleteBookingByIdQuery(string bookingId, string email) returns sql:ParameterizedQuery {
    return `
    DELETE
    FROM
        booking
    WHERE 
        active=true
        AND booking_id=${bookingId}
        AND email=${email}
    `;
}

# Query to delete the booking with a specific email and bookingId
#
# + scheduleId - schedule ID
# + email - Email
# + return - sql parameterized query
function deleteBookingByScheduleIdQuery(string scheduleId, string email) returns sql:ParameterizedQuery {
    return `
    DELETE
    FROM
        booking
    WHERE 
        schedule_id=${scheduleId}
        AND email=${email}
        AND status=${utils:UPCOMING}
    `;
}

# Query to add a new booking
#
# + booking - new booking
# + return - sql parameterized query
function addNewBookingQuery(types:Booking booking) returns sql:ParameterizedQuery {
    return `
    INSERT INTO 
        booking
        (date, email, preferences, schedule_id)
        VALUES (${utils:dateToDateString(booking.date)}, ${booking.email}, ${booking.preferences.toJsonString()}, ${booking?.scheduleId.toString()})
    `;
}

# Query to delete the booking with a specific email and bookingId
#
# + booking - booking
# + return - sql parameterized query
function updateBookingQuery(types:Booking booking) returns sql:ParameterizedQuery {
    return `
    UPDATE 
        booking
    SET 
        date = ${utils:dateToDateString(booking.date)}, email = ${booking.email}, preferences = ${booking.preferences.toJsonString()}, status=${booking?.status}, active=${booking?.isActive}, schedule_id=${booking?.scheduleId === null ? null : booking?.scheduleId.toString()}
    WHERE 
        booking_id = ${booking.bookingId.toString()};
    `;
}

# Query to delete the booking with a specific email and booking_id
#
# + date - Date
# + return - sql parameterized query
function getTodaysBookingsQuery(string date) returns sql:ParameterizedQuery {
    return `
    SELECT
        booking_id, date, email, preferences, last_updated_at
    FROM
        booking
    WHERE
        date=${date}
        AND active=true
        AND status!=${utils:BOOKED}
    ORDER BY
        date DESC
    `;
}

# Query tp get all the schedules under the given user email
#
# + email - Email
# + return - sql parameterizer query
public function getAllSchedulesQuery(string email) returns sql:ParameterizedQuery {
    return `
    SELECT 
        *  
    FROM 
        schedule 
    WHERE 
        email=${email} 
        AND deleted=false 
    ORDER BY 
        active DESC
    `;
}

# Query to retrieve the schedule details with a specific email and bookingId
#
# + scheduleId - Schedule ID
# + return - sql parameterized query
function getScheduleByIdQuery(string scheduleId) returns sql:ParameterizedQuery {
    return `
    SELECT 
        *
    FROM
        schedule
    WHERE
        deleted=false
        AND schedule_id=${scheduleId}
    LIMIT
        1
    `;
}

# Query to retrieve the schedule details with a specific email and schedule_name
#
# + scheduleName - Schedule name
# + email - email
# + scheduleId - schedule ID
# + return - sql parameterized query
function getScheduleByNameQuery(string scheduleName, string email, string scheduleId = "none") returns sql:ParameterizedQuery {
    if scheduleId == "none" {
        return `
        SELECT 
            *
        FROM
            schedule
        WHERE
            deleted=false
            AND schedule_name=${scheduleName}
            AND email=${email}
        LIMIT
            1
        `;
    } else {
        return `
        SELECT 
            *
        FROM
            schedule
        WHERE
            deleted=false
            AND schedule_name=${scheduleName}
            AND email=${email}
            AND schedule_id!=${scheduleId}
        LIMIT
            1
        `;
    }
}

# Query to retrieve the schedule details with a specific email and schedule_name
#
# + email - email
# + return - sql parameterized query
function getActiveScheduleQuery(string email) returns sql:ParameterizedQuery {
    return `
    SELECT 
        *
    FROM
        schedule
    WHERE
        deleted=false
        AND active=true
        AND email=${email}
    LIMIT
        1
    `;
}

function getScheduleCountQuery(string email) returns sql:ParameterizedQuery {
    return `
    SELECT
        COUNT(*) as count
    FROM 
        schedule
    WHERE 
        deleted=false
        AND email=${email}  
    `;
}

function addNewScheduleQuery(types:Schedule schedule) returns sql:ParameterizedQuery {
    return `
    INSERT INTO 
        schedule
        (email, schedule_name, recurring_mode, preferences)
        VALUES (${schedule.email}, ${schedule.scheduleName}, ${schedule.recurringMode}, ${schedule.preferences.toJsonString()})
    `;
}

function deleteScheduleByIdQuery(string scheduleId) returns sql:ParameterizedQuery {
    return `
    UPDATE
        schedule
    SET
        deleted = true
    WHERE
        schedule_id=${scheduleId}
    `;
}

# Query to update a schedule
#
# + schedule - detaisl of the schedule to be updated
# + return - sql parameterized query
function updateScheduleQuery(types:Schedule schedule) returns sql:ParameterizedQuery {
    return `
    UPDATE 
        schedule
    SET 
        schedule_name = ${schedule.scheduleName}, recurring_mode = ${schedule.recurringMode}, active=${schedule.isActive}, preferences = ${schedule.preferences.toJsonString()}
    WHERE 
        schedule_id = ${schedule.scheduleId}
        AND deleted = false
    `;
}

function addBookingsFromScheduleQuery(types:Booking[] bookings) returns sql:ParameterizedQuery[] {
    return from var booking in bookings
        select addNewBookingQuery(booking);
}

function activateScheduleQuery(string scheduleId, string email) returns sql:ParameterizedQuery {
    return `
    UPDATE
        schedule
    SET
        active = true
    WHERE
        schedule_id = ${scheduleId}
        AND email = ${email}
        AND deleted = false
    `;
}

function deactivateScheduleQuery(string scheduleId, string email) returns sql:ParameterizedQuery {
    return `
    UPDATE
        schedule
    SET
        active = false
    WHERE
        schedule_id = ${scheduleId}
        AND email = ${email}
        AND deleted = false
    `;
}

