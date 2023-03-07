import * as React from 'react';
import {AppBar, Box, Toolbar, Typography, IconButton, Button} from '@mui/material';
import AccountCircleOutlinedIcon from '@mui/icons-material/AccountCircleOutlined';
import LogoutIcon from '@mui/icons-material/Logout';
import { useNavigate } from 'react-router-dom';

export default function MenuAppBar() {

    const navigate = useNavigate()
    const handleProfileClick = ()=>{
        return
    }

    const hanldeLogoutClick = ()=>{
        return
    }

    return (
        <Box sx={{ flexGrow: 1 }} id="top-nav">
        
        <AppBar position="fixed" style={{backgroundColor:"black"}}>
            <Toolbar>
                <Typography variant="subtitle" component="div" sx={{ flexGrow: 1, fontWeight:"bold" }}>
                    Office-Booking App
                </Typography>
                <Box display={"flex"} alignItems={"center"}> 
                    <Box className='top-nav-btn'>
                        <Button
                        sx={{color:"white"}}
                        onClick={()=>{navigate("/Bookings")}}
                        >
                            Bookings
                        </Button> 
                        <Button
                        sx={{color:"white"}}
                        onClick={()=>{navigate("/Home")}}
                        >
                            Home
                        </Button> 
                        <Button
                        sx={{color:"white"}}
                        onClick={()=>{navigate("/Schedules")}}
                        >
                            Schedules
                        </Button> 
                    </Box>
                    <Box>
                        <IconButton
                        size="large"
                        aria-label="account of current user"
                        aria-controls="menu-appbar"
                        aria-haspopup="true"
                        onClick={handleProfileClick}
                        color="inherit"
                        >
                            <AccountCircleOutlinedIcon />
                        </IconButton>
                        <IconButton
                        size="large"
                        aria-label="account of current user"
                        aria-controls="menu-appbar"
                        aria-haspopup="true"
                        onClick={hanldeLogoutClick}
                        color="inherit"
                        >
                            <LogoutIcon />
                        </IconButton>
                    </Box>
                </Box>
            </Toolbar>    
        </AppBar>
        <Toolbar/>
        </Box>
    );
}
