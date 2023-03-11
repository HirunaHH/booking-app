import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import wso2_office_booking.types;

configurable readonly & DatabaseConfig databaseConfig = ?;

// create the database client with configureable credentials
final mysql:Client dbClient = check new(
    host=databaseConfig.host, user = databaseConfig.user, password = databaseConfig.password, port=databaseConfig.port, database = databaseConfig.name
);

# function to get all the bookings with the given email
# + email - Email
# + return - Return an array of all the bookings
public function getAllBookings(string email) returns Booking[]|error?{
    Booking[] bookings=[];
    stream<Booking,error?> resultStream = dbClient->query(getAllBookingsQuery(email,"2023-03-10"));

    _= check resultStream.forEach(function(Booking booking){ 
        bookings.push(booking);
    });

    check resultStream.close();
    return bookings;
}

# function to get details of the booking with the given email and the booking_id
# + email - Email 
# + booking_id - Booking ID
# + return - Booking with the given ID or error record
public function getBookingByID(string email, string booking_id) returns Booking|CannotFindIdError|error?{
    stream<Booking,error?> resultStream = dbClient->query(getBookingByIdQuery(email, booking_id));
    Booking[] result = check from var booking in resultStream select booking;
    if result.length()>0 {
        return result[0];
    }else{
        return {
            message: "Could not find the booking Id : "+booking_id
        };
    } 
}

# function to felete the booking with the given email and booking_id
# + email - Email
# + booking_id - Booking ID
# + return - Operation success results or error records
public function deleteBookingByID(string email, string booking_id) returns types:DbOperationSuccessResult|CannotFindIdError|error{
    sql:ExecutionResult result = check dbClient->execute(deleteBookingByIdQuery(email, booking_id));

    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount==0{
        return {
            message: "Could not find the booking Id : "+booking_id
        };
    }else{
        
        return result.cloneWithType(types:DbOperationSuccessResult);
    }    
}

