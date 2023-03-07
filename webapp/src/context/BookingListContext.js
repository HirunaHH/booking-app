import { createContext, useReducer, useEffect } from "react";

export const BookingListContext = createContext();
export const bookingListReducer = (state, action) => {
  switch (action.type) {
    case "LOAD":
      return action.payload;
    
    case "REMOVE":
      return state.filter((booking)=>booking.date!==action.payload)
      
    case "UPDATE":
      return state.map((booking)=>{
        if(booking.date===action.payload.date){
          return (
            {
              ...booking,
              ...action.payload
            }
          )
        } else{
          return booking
        }
      })
    default:
      return state;
  }
};

export const BookingListContextProvider = ({ children }) => {
  const [BookingList, dispatchBookingList] = useReducer(bookingListReducer, null, () => {
    const bookingList = JSON.parse(localStorage.getItem("bookingList"));
    return bookingList;
  });

  useEffect(() => {
    localStorage.setItem("bookingList", JSON.stringify(BookingList));
  }, [BookingList]);

  return (
    <BookingListContext.Provider value={{ bookingList:BookingList, dispatchBookingList }}>
      {children}
    </BookingListContext.Provider>
  );
};