export function checkDate(booking){
    const today = new Date();
    const tomorrow = new Date(today);
    tomorrow.setDate(today.getDate() + 1);

    if(booking.isActive){
        const date = new Date(booking.date);
        
        if (date.toDateString() === today.toDateString() && today.getHours()<15) {
            return {"Today":true};
        }
        
        if (date.toDateString() === tomorrow.toDateString() && today.getHours()>=15) {
            return {"Tomorrow":true}
        }
    
        if (today.getHours()<15){
            return {"Today":false}
        } else{
            return {"Tomorrow":false}
        }
    } else{
        if (today.getHours()<15){
            return {"Today":false}
        } else{
            return {"Tomorrow":false}
        }
       
    }
    
}

export function getMainBooking(bookigList){

    const dateCheck = checkDate(bookigList[0])
    if (Object.values(dateCheck)[0]){
        return {
            "booking":bookigList[0],
            "dateCheck": dateCheck
        }
    } else{
        return {
            "dateCheck":dateCheck
        }
    }
}

export function getNumberSuffix(num){
    if (num % 100 >= 11 && num % 100 <= 13) {
      return num + "th";
    }
    switch (num % 10) {
      case 1:
        return num + "st";
      case 2:
        return num + "nd";
      case 3:
        return num + "rd";
      default:
        return num + "th";
    }
}

