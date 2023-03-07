import * as React from 'react';
import { Container, Box, CssBaseline} from '@mui/material';
import LogsList from '../components/BookingLogsComponents/LogsList'
import TopNav from "../components/navigation/TopNav"
import ButtonGroupAdd from "../components/ButtonComponents/ButtonGroup-add"
import { useNavigate } from "react-router-dom";


export default function Logs() {


    const navigate = useNavigate()
    const addBooking = ()=>{
        navigate("/Bookings/AddBooking")
    }

  return (

    <Box >
        <TopNav/>
        <Container maxWidth="sm" sx={{paddingBottom:"60px"}}>
            <CssBaseline />
            <LogsList />
            <ButtonGroupAdd hidden={false} addAction={addBooking}/>
        </Container>
    </Box>
  );
}
