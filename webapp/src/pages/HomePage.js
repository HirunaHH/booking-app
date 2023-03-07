import Drawer from "../components/HomeComponents/Drawer"
import { Box, Typography, Grid, IconButton } from "@mui/material"
import LogoutIcon from '@mui/icons-material/Logout';
import { useBookingListContext } from "../hooks/useBookingListContext";
import {loadBookings} from "../helpers/ApiCallFunctions"
import { useEffect } from "react";
import { useMainBookingContext } from "../hooks/useMainBookingContext";


export default function Home(){

    const {bookingList, dispatchBookingList} = useBookingListContext()
    const {dispatchMainBooking} = useMainBookingContext()
    useEffect(()=>{
        const response = loadBookings()
        if (response){
            dispatchBookingList({
                type:"LOAD",
                payload:response
            })
            dispatchMainBooking({
                type:"SET",
                payload:bookingList
            })
        }
        
    },[])

    useEffect(()=>{
        dispatchMainBooking({
            type:"SET",
            payload:bookingList
        })
    },[bookingList])

    return(
        <Box sx={{display:"flex", justifyContent:"center"}}>
            <Grid maxWidth="md" container sx={{height:"100vh"}}>

                <Grid item xs={12} sx={{marginTop:"10px", display:"flex", justifyContent:"end", marginRight:"10px"}}>
                    <IconButton size="large">
                            <LogoutIcon sx={{color:"#FBFBFB"}}/>
                    </IconButton>
                </Grid>

                <Grid 
                item 
                xs={12}
                sx={{
                    display:"flex",
                    justifyContent:"center"
                }}>
                    <div>
                        <Box>
                            <Typography variant="h4" component="h1" color={"white"} fontWeight={"bold"}>WSO2 Booking App</Typography>
                        </Box>
                    </div>
                </Grid>

                <Grid 
                item 
                xs={12}>
                    <img 
                    style={{
                        width:"100%",
                        height:"100%",
                        objectFit:"cover"
                        }} 
                    src="TitleImage.png"/>
                </Grid>

                <Grid item xs={12}>
                    <Drawer/>
                </Grid>

            </Grid>
        </Box>
    )
}