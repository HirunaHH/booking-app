import ballerina/time;

# Database configuration.
# + host - Database Host 
# + user - Database User  
# + password - Database Password
# + name - Database Name 
# + port - Database Port
public type DatabaseConfig record {
    string host;
    string user;
    string password;
    string name;
    int port;
};

# Booking Type
# + booking_id - id of the booking  
# + date - date which the booking is made 
# + email - email of the user who made the booking 
# + preferences - json object with the meal preferences for the booking 
# + status - status of the booking (Booked, Upcoming)  
# + is_active - flag to identify whether the booking is active or not  
# + schedule_id - id of the schedule if it is added from a schedule
# + created_at - date and time the booking is created
# + last_updated - most recent date and time the booking is updated
public type Booking record {|
    int booking_id?;
    time:Date date;
    string email;
    json preferences;
    string status;
    boolean is_active;
    time:Civil created_at;
    time:Civil last_updated;
    int? schedule_id;
|};

# Schedule Type
# + schedule_id - id of the schedule 
# + email - email of the user who created the schedule  
# + schedule_name - name of the schedule 
# + recurring_mode - recurring mode of the schedule  
# + is_active - flag to identify whether the schedule is active or not  
# + is_deleted - flag to identify whether the schedule is deleted or not  
# + preferences - json object with the meal preferences for all the days selected in thw schedule
public type Schedule record {|
    int schedule_id?;
    string email;
    string schedule_name;
    string recurring_mode;
    boolean is_active;
    boolean is_deleted;
    json preferences;
|};

# Error defined to indicate unavailable IDs
# + message - Message to be passed 
public type CannotFindIdError record {|
    string message;
|};