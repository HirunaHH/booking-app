import { BookingListContext } from "../context/BookingListContext";
import { useContext } from "react";

export const useBookingListContext = ()=>{
    const context = useContext(BookingListContext)

    if(!context){
        throw Error("useBookingListContext can be used only in a BookingListContext Wrapper")
    }

    return context
}