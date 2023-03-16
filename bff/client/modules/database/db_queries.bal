// Copyright (c) 2023, WSO2 Inc. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 Inc. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerina/sql;
import wso2_office_booking.utils;

# Query to retrieve all bookings with a specific email
# 
# + email - Email
# + date - Date
# + return - sql parameterized query
function getAllBookingsQuery(string email, string date) returns sql:ParameterizedQuery{
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
function getBookingByIdQuery(string bookingId) returns sql:ParameterizedQuery{
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
# + date -  Date
# + bookingId - Booking ID
# + return - sql parameterized query
function getBookingByDateQuery(string email, string date, string bookingId) returns sql:ParameterizedQuery{
    if bookingId==="none"{
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
    }else{
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
function deleteBookingByIdQuery(string bookingId, string email) returns sql:ParameterizedQuery{
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

# Query to add a new booking
# 
# + booking - new booking
# + return - sql parameterized query
function addNewBookingQuery(Booking booking) returns sql:ParameterizedQuery{
    return `
    INSERT INTO 
        booking
        (date, email, preferences, status, active, schedule_id)
        VALUES (${utils:dateToDateString(booking.date)}, ${booking.email}, ${booking.preferences.toJsonString()}, 'Upcoming', true, ${booking?.scheduleId})
    `;
}

# Query to delete the booking with a specific email and bookingId
# 
# + booking - booking
# + return - sql parameterized query
function editBookingQuery(Booking booking) returns sql:ParameterizedQuery{
    return `
    UPDATE 
        booking
    SET 
        date = ${utils:dateToDateString(booking.date)}, email = ${booking.email}, preferences = ${booking.preferences.toJsonString()}, status=${booking?.status}, active=${booking?.isActive}, schedule_id=${booking?.scheduleId===null?null:booking?.scheduleId.toString()}
    WHERE 
        booking_id = ${booking.bookingId.toString()};
    `;
}

# Query to delete the booking with a specific email and booking_id
# 
# + date - Date
# + return - sql parameterized query
function getTodaysBookingsQuery(string date) returns sql:ParameterizedQuery{
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