import { createContext, useReducer, useEffect } from "react";
import { loadBookings } from "../helpers/ApiCallFunctions";

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
  const [BookingList, dispatchBookingList] = useReducer(bookingListReducer, loadBookings());

  return (
    <BookingListContext.Provider value={{ bookingList:BookingList, dispatchBookingList }}>
      {children}
    </BookingListContext.Provider>
  );
};