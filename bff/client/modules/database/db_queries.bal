import ballerina/sql;
import wso2_office_booking.utils;

# funtion to get the query to retrieve all bookings with a specific email
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
        AND is_active=true
        AND date>=${date}
    ORDER BY 
        date ASC
    `;
}

# function to get the query to retrieve the booking details with a specific email and booking_id
# + booking_id - Bookind ID
# + return - sql parameterized query
function getBookingByIdQuery(string booking_id) returns sql:ParameterizedQuery{
    return `
    SELECT 
        *
    FROM
        booking
    WHERE
        is_active=true
        AND booking_id=${booking_id}
    LIMIT
        1
    `;
}

# function to get the query to retrieve the booking details with a specific email and date
# + email - Email
# + date -  Date
# + booking_id - Booking ID
# + return - sql parameterized query
function getBookingByDateQuery(string email, string date, string booking_id) returns sql:ParameterizedQuery{
    if booking_id==="none"{
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
            AND booking_id!=${booking_id}
            AND date=${date}
        LIMIT
            1
        `;
    }
}

# function to get the query to delete the booking with a specific email and booking_id
# + booking_id - Bookind ID
# + return - sql parameterized query
function deleteBookingByIdQuery(string booking_id) returns sql:ParameterizedQuery{
    return `
    DELETE 
    FROM
        booking
    WHERE 
        is_active=true
        AND booking_id=${booking_id}
    `;
}

# function to get the query to delete the booking with a specific email and booking_id
# + booking - new booking
# + return - sql parameterized query
function addNewBookingQuery(Booking booking) returns sql:ParameterizedQuery{
    return `
    INSERT INTO 
        booking
        (date, email, preferences, status, is_active, schedule_id)
        VALUES (${utils:dateToDateString(booking.date)}, ${booking.email}, ${booking.preferences.toJsonString()}, 'Upcoming', true, ${booking?.schedule_id})
    `;
}

# function to get the query to delete the booking with a specific email and booking_id
# + booking - booking
# + return - sql parameterized query
function editBookingQuery(Booking booking) returns sql:ParameterizedQuery{
    return `
    UPDATE 
        booking
    SET 
        date = ${utils:dateToDateString(booking.date)}, email = ${booking.email}, preferences = ${booking.preferences.toJsonString()}, status=${booking?.status}, is_active=${booking?.is_active}, schedule_id=${booking?.schedule_id===null?null:booking?.schedule_id.toString()}
    WHERE 
        booking_id = ${booking.booking_id.toString()};
    `;
}

# function to get the query to delete the booking with a specific email and booking_id
# + date - Date
# + return - sql parameterized query
function getTodaysBookingsQuery(string date) returns sql:ParameterizedQuery{
    return `
    SELECT
        booking_id, date, email, preferences, last_updated
    FROM
        booking
    WHERE
        date=${date}
        AND is_active=true
        AND status!="Booked"
    ORDER BY
        date DESC
    `;
}