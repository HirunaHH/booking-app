import * as React from 'react';
import {FormGroup, TextField, Box, Button, Typography, InputLabel, MenuItem, FormControl, Select} from '@mui/material';
import { AdapterDayjs } from '@mui/x-date-pickers/AdapterDayjs';
import { LocalizationProvider } from '@mui/x-date-pickers/LocalizationProvider';
import { MobileDatePicker } from '@mui/x-date-pickers/MobileDatePicker';
import Options from "../../json-files/options.json"
import { useState, useEffect } from 'react';
import { useNavigate, useParams } from 'react-router-dom';
import { useBookingListContext } from '../../hooks/useBookingListContext';
import { useMainBookingContext } from '../../hooks/useMainBookingContext';

const getOptions = ()=>{
    return Options.options
}

export default function BookingForm({mode}){
    const [date, setDate] = useState(new Date());
    const [preferences, setPreferences] = useState({});
    const {bookingList, dispatchBookingList} = useBookingListContext()
    const{dispatchMainBooking} = useMainBookingContext()
    const {id} = useParams()
    const navigate = useNavigate()

    useEffect(()=>{
        if (mode==="edit"){
            const booking = bookingList.filter((booking)=>booking.id===id)[0]
            console.log(booking)
            setDate(new Date(booking.date))
            setPreferences(booking.preferences)
        }
    },[])

    useEffect(()=>{
        dispatchMainBooking({
            type:"SET",
            payload:bookingList
        })
    },[bookingList])


    const handleChange = (event) => {
        setPreferences((prevPreferences)=>{
            return {
                    ...prevPreferences,
                    [event.target.name]:event.target.value,
                    }
        })
      };

    const handleSubmit = ()=>{
        if(mode=="add"){
            console.log({date,preferences})
        } else{
            const booking = bookingList.filter((booking)=>booking.id===id)[0]
            dispatchBookingList({
                type:"UPDATE",
                payload:{
                    ...booking,
                    preferences
                }
            })

        }
        navigate("/Bookings")
    }

    return(
        <>
            <Box padding={"10px"}>
                <FormGroup>
                    <FormControl size="small" >
                        <LocalizationProvider dateAdapter={AdapterDayjs}>
                            <MobileDatePicker
                            label="Select the Date"
                            value={date}
                            onChange={(newDate) => {
                                setDate(newDate);
                            }}
                            renderInput={(params) => <TextField {...params} />}
                            disabled={mode==="edit"?true:false}
                            />
                        </LocalizationProvider>
                    </FormControl>
                    <Typography gutterBottom variant="h6" component="div" sx={{color:"#A74921", margin:2}}>
                        Meal Preference
                    </Typography>
                    {Object.keys(getOptions()).map((meal)=>(
                        <FormControl key={meal} sx={{ m: 1, minWidth: 120 }} size="small">
                            <InputLabel >{meal}</InputLabel>
                            <Select
                                name={meal}
                                labelId="demo-select-small"
                                id="demo-select-small"
                                value={preferences[meal]?preferences[meal]:""}
                                label={meal}
                                onChange={handleChange}
                            >
                                {getOptions()[meal].map((option)=>(
                                        <MenuItem key={option} value={option}>{option}</MenuItem>
                                )   
                                )}
                            </Select>
                        </FormControl>

                    ))}
                </FormGroup>
            </Box>
            <Box sx={{display:"flex", justifyContent:"center", alignItems:"center", paddingBottom:"10px", paddingTop:"10px"}}>
                <Button variant="contained" color="warning" size="medium" onClick={handleSubmit}>{mode==="edit"?"Save":"Add"}</Button>
            </Box>
        </>

    )
}