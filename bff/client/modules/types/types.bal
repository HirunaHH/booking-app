import ballerina/http;

# type to define errors with a message
# + message - error message
public type OfficeBookingAppError record {|
    string message;
|};

# type to define results retrieved after a successfull database operation
# + affectedRowCount - Rows affected by the operation  
# + lastInsertId - Inserted id by the operation
public type DbOperationSuccessResult record {|
    int? affectedRowCount;
    string|int? lastInsertId?;
|};

//Types defining different response types

# 404 Not Found response type
# + body - error message
public type OfficeBookingAppNotFoundError record {|
    *http:NotFound;
    OfficeBookingAppError body;
|};

# 500 Internal Server Error response type
# + body - error message
public type OfficeBookingAppServerError record {|
    *http:InternalServerError;
    OfficeBookingAppError body;
|};

# 200 OK response type
# + body - payload with success details
public type OfficeBookingAppSuccess record {|
    *http:Ok;
    DbOperationSuccessResult body;
|};
 