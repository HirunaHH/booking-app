import {Paper, Grid, Typography, Box, Divider, FormGroup, FormControlLabel, Switch} from '@mui/material'
import BackspaceOutlinedIcon from '@mui/icons-material/BackspaceOutlined';
import CreateOutlinedIcon from '@mui/icons-material/CreateOutlined';
import BtnGroup2 from "../ButtonComponents/ButtonGroup-2";
import { useEffect, useState } from "react";
import { useBookingListContext } from "../../hooks/useBookingListContext";
import { useNavigate } from "react-router-dom";
import { useMainBookingContext } from "../../hooks/useMainBookingContext";

const textColor = {
    "Booked":"#00AF1C",
    "Upcoming":"#DA6200"
} 

export default function LogItem({index,booking}){
    
    const [isActive, setIsActive] = useState(booking.isActive==="true" || booking.isActive===true)

    const {bookingList, dispatchBookingList} = useBookingListContext()
    const {mainBooking, dispatchMainBooking} = useMainBookingContext()
    
    const {status, preferences, date} = booking
    const dateArray = (new Date(date)).toDateString().split(" ").slice(0,3).reverse()
    const navigate = useNavigate()

    useEffect(()=>{
        setIsActive(booking.isActive==="true" || booking.isActive===true)
        dispatchMainBooking({
            type:"SET",
            payload:bookingList
        })
    },[bookingList])

    
    const removeBooking = ()=>{
        dispatchBookingList({type:"REMOVE", payload:date})
    }

    const editBooking = ()=>{
        navigate(`/Bookings/EditBooking/${booking.id}`)
    }

    const handleSwitch = ()=>{
        dispatchBookingList({
            type:"UPDATE", 
            payload:{
                date:date,
                isActive:!isActive
            }})
    }

    return(
        <Paper sx={{borderRadius:6}} elevation={10}>
            <Grid 
                container
                sx={{
                    backgroundColor:()=>{            
                        if(index===0 && Object.values(mainBooking.dateCheck)[0]){
                            return "#FFAF6D"
                        } else if(!isActive){
                            return "#ADA8A49E";
                        } else{
                            return "#FFF1E5"
                        }
                    },
                    borderRadius:"23px"
                }}
            >
                <Grid 
                    item 
                    xs={3}
                    sx={{
                        backgroundColor:()=>{
                            if(index===0 && Object.values(mainBooking.dateCheck)[0]){
                                return "#AB4F04"
                            } else if(!isActive){
                                return "#A39F9F"
                            } else{
                                return "#8E7D70"
                            }
                        },
                        borderRadius:"23px 0px 0px 23px",
                        display:"flex",
                        alignItems:"center",
                        justifyContent:"center",
                        color:"white"
                    }}
                >
                    <div>
                        <Box>
                            <Typography sx={{fontWeight:"bold"}}>{(dateArray.slice(0,2)).join(" ")}</Typography>
                        </Box>
                        <Box sx={{display:"flex",justifyContent:"center"}}>
                            <Typography sx={{fontWeight:"bold"}}>{dateArray[2]}</Typography>
                        </Box>
                    </div>
                </Grid>

                <Grid 
                    item 
                    xs={9} 
                    sx={{
                        padding:"5px 15px 5px 15px",
                        marginY:1
                    }}
                >
                    <Grid container paddingRight={1}>
                        <Grid item xs={8} md={9}>
                            <Typography sx={{fontWeight:"bold"}} color={textColor[status]}>
                                {status}
                            </Typography>
                        </Grid>
                        <Grid item xs={4} md={3} display="flex" alignItems="end">
                            {status!=="Booked"&&
                            <FormGroup>
                                <FormControlLabel control={<Switch checked={isActive} size="small" color="warning" onChange={handleSwitch}/>} label={isActive?<Typography variant="caption">Active</Typography>:<Typography variant="caption">Inactive</Typography>}/>
                            </FormGroup>}
                        </Grid>
                    </Grid>

                    
                    <Divider variant="middle" sx={{m:1}}/>
                    <Grid container paddingRight={1}>
                        <Grid item xs={8} md={9}>
                            {preferences === "None" ? <Typography variant="body2">Meal Not Requested</Typography>: 
                            Object.keys(preferences).map((meal)=>(
                            <Typography variant="body2" key={meal}>{meal} - {preferences[meal]}</Typography>
                            ))}
                        </Grid>
                        <Grid item xs={4} md={3} display="flex" alignItems="end">
                            {status!=="Booked"&&<Box 
                                sx={{
                                    display:"flex",
                                    justifyContent:"right",
                                    paddingRight:"4px"
                                }}
                            >
                                <BtnGroup2 
                                btn1={{
                                    "color":"#030000",
                                    "content":<CreateOutlinedIcon fontSize="small"/>,
                                    "action":editBooking
                                }}
                                btn2={{
                                    "color":"#FF7300",
                                    "content":<BackspaceOutlinedIcon fontSize="small"/>,
                                    "action":removeBooking
                                }}/>
                            </Box>}
                        </Grid>
                    </Grid>
                    
                    
                </Grid>
            </Grid>                
        </Paper>
    )
}
