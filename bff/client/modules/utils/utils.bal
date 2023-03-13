import ballerina/time;

// Date & Time Helper Functions

# function to get today or tommorow date according to the hour of the day
# + hourCheckValue - hour of the day that the check should be performef
# + return - object with the date and it's type:whether it's today or tommorow
public function getTodayOrTommorow(int hourCheckValue) returns record {|time:Civil date; string DayType;|}{
    time:Civil today = time:utcToCivil(time:utcNow());
    time:Civil tommorow = time:utcToCivil(time:utcAddSeconds(time:utcNow(),86400));
    if(today.hour<hourCheckValue){
        return {
            date:today,
            DayType: "Today"
        };
    }else{
        return {
            date:tommorow,
            DayType: "Tommorow"
        };
    }
}

# function to convert a Date type variable to string witht the format of "YYYY-MM-DD"
# + date - Date object
# + return - formatted DateString
public function dateToDateString(time:Date date) returns string{
    record {|string year; string month; string day;|} strDateRecord = {
        year:date.year.toString(),
        month:date.month.toString(),
        day:date.day.toString()
    };

    if date.month <10{
        strDateRecord.month = "0"+date.month.toString();
    }

    if date.day<10{
        strDateRecord.day = "0"+date.day.toString();
    }

    return strDateRecord.year+"-"+strDateRecord.month+"-"+strDateRecord.day;
}

# Function to convert a Date to a string
# + date - Date
# + return - date string or error
public function dateToDateTimeString(time:Date date) returns string{
    return dateToDateString(date)+dateTimeStrSuffix;
}

# fucntion to convert a Date to Utc
# + date - Date
# + return - Utc value or error
public function dateToUtc(time:Date date) returns time:Utc|error{
    string dateStr = dateToDateTimeString(date);
    return time:utcFromString(dateStr);
}

# function to convert a Date to Civil value
# + date - Date
# + return - Civil value or error
public function dateToCivil(time:Date date) returns time:Civil|error{
    string dateStr = dateToDateTimeString(date);
    return time:civilFromString(dateStr);
}

# function to convert a Civil value to a string in the format of "MM/DD/YYYY HH:MM:SS"
# + civil - Civil value
# + return - date-time string
public function civilToGoogleTimestampString(time:Civil? civil) returns string{
    string dateStr = civil?.month.toString()+"/"+civil?.day.toString()+"/"+civil?.year.toString();
    string timeStr = civil?.hour.toString()+":"+civil?.minute.toString()+":"+civil?.second.toString();
    return dateStr + " " + timeStr;
}

# Description
#
# + d1 - first date 
# + comparison - comparison type string  
# + d2 - second date
# + return - boolean or error
public function compareDates(time:Civil d1, string comparison, time:Civil d2) returns boolean|error{
    d1.utcOffset = {
        hours:0,
        minutes: 0,
        seconds: 0
    };
    d2.utcOffset = {
        hours:0,
        minutes: 0,
        seconds: 0
    };
    
    time:Utc utc1 = check time:utcFromCivil(d1);
    time:Utc utc2 = check time:utcFromCivil(d2);
    match comparison{
        ">="=>{
            if <int>time:utcDiffSeconds(utc1, utc2)>=0{
                return true;
            }else{
                return false;
            }
        }
        "<"=>{
            if <int>time:utcDiffSeconds(utc1, utc2)<0{
                return true;
            }else{
                return false;
            }

        }
        _=>{
            return error("Invalid Instruction");
        }
    }
}
