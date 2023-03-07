import {Box, Stack} from "@mui/material"
import LogItem from "./LogItem";
import { useBookingListContext } from "../../hooks/useBookingListContext";
import { useEffect } from "react";
import { useMainBookingContext } from "../../hooks/useMainBookingContext";


export default function LogsList(){

    const {bookingList} = useBookingListContext()
    const {dispatchMainBooking} = useMainBookingContext()

    useEffect(()=>{
        dispatchMainBooking({
            type:"SET",
            payload:bookingList
        })
    },[bookingList])

    return(
        <Box paddingTop={2}>
            <Stack spacing={2}>
                    {bookingList.map((booking,index) => (<LogItem key={index} index={index} booking={booking}/>))}
            </Stack>          
        </Box>
    )
}


