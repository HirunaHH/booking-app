import ballerina/sql;

# funtion to get the query to retrieve all bookings with a specific email
# + email - Email
# + date - Date
# + return - sql parameterized query
isolated function getAllBookingsQuery(string email, string date) returns sql:ParameterizedQuery{
    return `
    SELECT 
        * 
    FROM 
        booking 
    WHERE
        email=${email}
        AND date>=${date}
    ORDER BY 
        date ASC
    `;
}

# function to get the query to retrieve the booking details with a specific email and booking_id
# + email - Email
# + booking_id - Bookind ID
# + return - sql parameterized query
isolated function getBookingByIdQuery(string email, string booking_id) returns sql:ParameterizedQuery{
    return `
    SELECT 
        *
    FROM
        booking
    WHERE
        email=${email}
        AND booking_id=${booking_id}
    LIMIT
        1
    `;
}

# function to get the query to delete the booking with a specific email and booking_id
# + email - Email
# + booking_id - Bookind ID
# + return - sql parameterized query
isolated function deleteBookingByIdQuery(string email, string booking_id) returns sql:ParameterizedQuery{
    return `
    DELETE 
    FROM
        booking
    WHERE 
        email=${email} 
        AND booking_id=${booking_id}
    `;
}