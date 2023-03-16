import { createContext, useReducer, useEffect } from "react";
import { getMainBooking } from "../helpers/HelperFunctions";
import { loadBookings } from "../helpers/ApiCallFunctions";

export const MainBookingContext = createContext();
export const mainBookingReducer = (state, action) => {
  switch (action.type) {
    case "SET":
      return getMainBooking(action.payload);

    default:
      return state;
  }
};

export const MainBookingContextProvider = ({ children }) => {
  const [MainBooking, dispatchMainBooking] = useReducer(mainBookingReducer, getMainBooking(loadBookings()));

  return (
    <MainBookingContext.Provider value={{ mainBooking:MainBooking, dispatchMainBooking }}>
      {children}
    </MainBookingContext.Provider>
  );
};