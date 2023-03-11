import ballerina/http;
import wso2_office_booking.database;
import wso2_office_booking.types;

// creating the listner object
listener http:Listener listenerObj = new (9090);

// service for resources related to bookings
service /bookings on listenerObj {

    # A resource to get all the bookings recorded under the user email
    # + email - user email
    # + return - array of bookings or error response
    resource function get .(string email) returns database:Booking[]|types:OfficeBookingAppServerError? {
        database:Booking[]|error? result = database:getAllBookings(email);
        if result is error{
            return <types:OfficeBookingAppServerError>{
                body:{ message:"Cannot retrieve booking list from the database" }
            };
        }else{
            return result;
        }
    }

    # A resource to get the booking of specific Id
    # + email - user email
    # + return - Booking record or error responses
    resource function get [string booking_id](string email) returns database:Booking|types:OfficeBookingAppError|types:OfficeBookingAppServerError|types:OfficeBookingAppNotFoundError?{
        database:Booking|database:CannotFindIdError|error? result = database:getBookingByID(email, booking_id);
        if result is error{
            return <types:OfficeBookingAppServerError>{
                body : { message: "Cannot retrieve booking details" }
            };
        }else if result is database:CannotFindIdError{
            return <types:OfficeBookingAppNotFoundError>{
                body : result
            };
        } else {
            return result;
        }
    }

    # A resource to delete a booking with a specific Id
    # + email - user email
    # + return - delete confirmation details or error responses
    resource function delete [string booking_id](string email) returns types:OfficeBookingAppSuccess|types:OfficeBookingAppServerError|types:OfficeBookingAppNotFoundError{
        types:DbOperationSuccessResult|database:CannotFindIdError|error result = database:deleteBookingByID(email, booking_id);
        if result is error{
            return <types:OfficeBookingAppServerError> {
                body : { message:"Cannot delete the booking" }
            };
        } else if result is database:CannotFindIdError{
            return <types:OfficeBookingAppNotFoundError>{
                body : result
            };
        } else if result is types:DbOperationSuccessResult{
            return <types:OfficeBookingAppSuccess>{
                body : result
            };
        }
    }
}
