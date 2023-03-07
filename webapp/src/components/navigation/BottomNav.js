import * as React from 'react';
import {CssBaseline, BottomNavigation, BottomNavigationAction, Paper} from '@mui/material';
import HomeOutlinedIcon from '@mui/icons-material/HomeOutlined';
import CalendarMonthOutlinedIcon from '@mui/icons-material/CalendarMonthOutlined';
import GridViewOutlinedIcon from '@mui/icons-material/GridViewOutlined';
import { useNavigate } from "react-router-dom";
import "./NavStyles.css"

export default function BottomNav() {

    const [value, setValue] = React.useState(()=>{
        switch(window.location.pathname.split("/")[1]){
            case "Bookings":
                return 0
            case "Home":
                return 1
            case "Schedules":
                return 2
            default:
                return
        }
    });
    const navigate = useNavigate()
    return (
        <>
            <CssBaseline />
            <Paper className='bottomNav' sx={{ position: 'fixed', bottom: 0, left: 0, right: 0}} elevation={3}>
                <BottomNavigation
                    showLabels
                    value={value}
                    onChange={(event, newValue) => {
                        setValue(newValue);
                        switch (newValue){
                            case 0:
                                navigate("/Bookings") 
                                break
                            case 1:
                                navigate("/Home")
                                break
                            case 2:
                                navigate("/Schedules")
                                break
                            default:
                                return
                        }
                    }}
                    sx={{
                        backgroundColor:"#EBEBEB"
                    }}
                >
                    <BottomNavigationAction label="Logs" icon={<GridViewOutlinedIcon />} />
                    <BottomNavigationAction label="Home" icon={<HomeOutlinedIcon />} />
                    <BottomNavigationAction label="Schedules" icon={<CalendarMonthOutlinedIcon />} />
                </BottomNavigation>
            </Paper>
        </>
    );
  }
  