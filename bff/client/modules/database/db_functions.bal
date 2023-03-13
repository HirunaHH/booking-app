import ballerinax/mysql;
import ballerinax/mysql.driver as _;
import ballerina/sql;
import ballerina/time;
import wso2_office_booking.types;
import wso2_office_booking.utils;

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
    stream<Booking,error?> resultStream = dbClient->query(getAllBookingsQuery(email,utils:dateToDateString(utils:getTodayOrTommorow(11).date)));

    _= check resultStream.forEach(function(Booking booking){ 
        bookings.push(booking);
    });

    check resultStream.close();
    return bookings;
}

# function to get details of the booking with the given email and the booking_id
# + booking_id - Booking ID
# + return - Booking with the given ID or error record
public function getBookingByID(string booking_id) returns Booking|CannotFindIdError|error{
    stream<Booking,error?> resultStream = dbClient->query(getBookingByIdQuery(booking_id));
    Booking[] result = check from var booking in resultStream select booking;
    if result.length()>0 {
        return result[0];
    }else{
        return {
            message: "Could not find the booking Id : "+booking_id
        };
    } 
}

# function to get details of the booking with the given email and the date
# + email - Email 
# + date - Date
# + booking_id - Booking ID
# + return - Booking with the given ID or error record
public function getBookingByDate(string email, string date, string booking_id="none") returns Booking|types:OfficeBookingAppError|error{
    stream<Booking,error?> resultStream = dbClient->query(getBookingByDateQuery(email, date, booking_id));
    Booking[] result = check from var booking in resultStream select booking;
    if result.length()>0 {
        return result[0];
    }else{
        return {
            message: "Could not find a booking with the date : "+date
        };
    } 
}

# functin to get the active booking list on current date
# + return - active booking list with the date matching to current date or error
public function getTodaysBookings() returns Booking[]|error{
    time:Civil today = time:utcToCivil(time:utcNow());
    string date = utils:dateToDateString(today);
    Booking[] bookings=[];
    stream<Booking,error?> resultStream = dbClient->query(getTodaysBookingsQuery(date));
    _= check resultStream.forEach(function(Booking booking){ 
        bookings.push(booking);
    });

    check resultStream.close();
    return bookings;
}

# function to delete the booking with the given email and booking_id
# + booking_id - Booking ID
# + return - Operation success results or error records
public function deleteBookingByID(string booking_id) returns types:DbOperationSuccessResult|CannotFindIdError|error{
    sql:ExecutionResult result = check dbClient->execute(deleteBookingByIdQuery(booking_id));

    int? affectedRowCount = result.affectedRowCount;
    if affectedRowCount==0{
        return {
            message: "Could not find the booking Id : "+booking_id
        };
    }else{
        
        return result.cloneWithType(types:DbOperationSuccessResult);
    }    
}

# Description
#
# + booking - The new booking
# + return - Success result 
public function addNewBooking(Booking booking) returns types:DbOperationSuccessResult|types:OfficeBookingAppError|error{

    time:Date date = booking.date;
    Booking|types:OfficeBookingAppError existingResult = check getBookingByDate(booking.email, utils:dateToDateString(date));
    if existingResult is Booking{
        return {
            message: "A Booking already exists for the entered date. Plz edit it or delete it before adding a new one"
        };
    }

    time:Civil|error civilDate = utils:dateToCivil(date);

    if civilDate is error{
        return {
            message: "Entered date is invalid"
        };
    } 

    if civilDate.dayOfWeek ==0 || civilDate.dayOfWeek==6{
        return {
            message: "Cannot add bookings for weekends"
        };
    }

    boolean|error dateOkayResult = utils:compareDates(civilDate, ">=", utils:getTodayOrTommorow(9).date);

    if dateOkayResult is error{
        return error("Could not add the booking");
    }

    if !dateOkayResult{
        return {
            message: "Cannot add a booking for a previous date"
        };
    }

    sql:ExecutionResult result = check dbClient->execute(addNewBookingQuery(booking));
    return result.cloneWithType(types:DbOperationSuccessResult);
    
}

# Description
#
# + booking - The booking to edit
# + return - Success Result
public function editBooking(Booking booking) returns types:DbOperationSuccessResult|types:OfficeBookingAppError|error{
    Booking|CannotFindIdError existingResult = check getBookingByID(booking.booking_id.toString());

    if existingResult is CannotFindIdError{
        return {
            message:existingResult.message
        };
    }

    if existingResult.status==="Booked"{
        return {
            message: "Cannot edit an already confirmed booking"
        };
    }

    Booking|types:OfficeBookingAppError|error dateMatchedResult = check getBookingByDate(booking.email, utils:dateToDateString(booking.date), booking.booking_id.toString());


    if dateMatchedResult is Booking{
        return {
            message: "A booking already exists for the given date"
        };
    }

    if dateMatchedResult is error{
        return error(dateMatchedResult.message());
    }

    time:Civil|error civilDate = utils:dateToCivil(booking.date);

    if civilDate is error{
        return {
            message: "Entered date is invalid"
        };
    } 

    if civilDate.dayOfWeek ==0 || civilDate.dayOfWeek==6{
        return {
            message: "Cannot add bookings for weekends"
        };
    }

    boolean|error dateOkayResult = utils:compareDates(civilDate, ">=", utils:getTodayOrTommorow(9).date);

    if dateOkayResult is error{
        return error(dateOkayResult.message());
    }

    if !dateOkayResult{
        return {
            message: "Cannot add a booking for a previous date"
        };
    }

    booking.keys().forEach(function(string key){
        existingResult[key] = booking[key];
    });

    sql:ExecutionResult result = check dbClient->execute(editBookingQuery(existingResult));
    return result.cloneWithType(types:DbOperationSuccessResult);
}

