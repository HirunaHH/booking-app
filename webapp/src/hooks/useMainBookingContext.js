import { MainBookingContext } from "../context/MainBookingContext";
import { useContext } from "react";

export const useMainBookingContext = ()=>{
    const context = useContext(MainBookingContext)

    if(!context){
        throw Error("useMainBookingContext can be used only in a MainBookingContext Wrapper")
    }

    return context
}