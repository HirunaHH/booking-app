import { createContext, useReducer, useEffect } from "react";
import { getMainBooking } from "../helpers/HelperFunctions";

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
  const [MainBooking, dispatchMainBooking] = useReducer(mainBookingReducer, null, () => {
    const mainBooking = JSON.parse(localStorage.getItem("mainBooking"));
    return mainBooking;
  });

  useEffect(() => {
    localStorage.setItem("mainBooking", JSON.stringify(MainBooking));
  }, [MainBooking]);

  return (
    <MainBookingContext.Provider value={{ mainBooking:MainBooking, dispatchMainBooking }}>
      {children}
    </MainBookingContext.Provider>
  );
};