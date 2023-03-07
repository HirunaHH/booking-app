import { Paper, Box, Typography, Stack, Button, Divider} from "@mui/material";
import BackspaceOutlinedIcon from '@mui/icons-material/BackspaceOutlined';
import CreateOutlinedIcon from '@mui/icons-material/CreateOutlined';
import { createTheme, ThemeProvider } from '@mui/material/styles';
import { useNavigate } from "react-router-dom";
import { useBookingListContext } from "../../hooks/useBookingListContext";
import { useMainBookingContext } from "../../hooks/useMainBookingContext";
import { getNumberSuffix } from "../../helpers/HelperFunctions";

const theme = createTheme({
    palette: {
      dark: {
        main: '#000000',
      },
    },
  });


const TitleMessage = ({mainBooking})=>{
    return(
        <Box sx={{marginBottom:"50px", marginTop:"50px"}}>
            <Box>
                <Typography variant={"h5"} sx={{fontWeight:"bold"}}>You have {mainBooking.booking?"a":"no"} booking for</Typography>
            </Box>
            <Box sx={{display:"flex",justifyContent:"center"}}>
                <Typography variant={"h5"} sx={{fontWeight:"bold"}}>{Object.keys(mainBooking.dateCheck)}</Typography>
            </Box>
        </Box>
    )
}

const MainBooking = ({mainBookingDetails})=>{
    const months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"]
    const days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    return(
        <>
            <Divider/>
            <Box sx={{marginBottom:"15px", marginTop:"15px"}}>
                <Box sx={{display:"flex",justifyContent:"center", marginBottom:"10px"}}>
                    <Typography variant={"body1"} sx={{fontWeight:"bold"}}>{getNumberSuffix((new Date(mainBookingDetails.date)).getDate()) + " "+ months[(new Date(mainBookingDetails.date)).getMonth()]} - {days[(new Date(mainBookingDetails.date)).getDay()]}</Typography>
                </Box>
                {mainBookingDetails.preferences === "None" ? 
                <Box sx={{display:"flex",justifyContent:"center"}}>
                    <Typography>Meal Not Requested !</Typography>
                </Box>:
                Object.keys(mainBookingDetails.preferences).map((meal,index)=>(
                        <Box key={index} sx={{display:"flex",justifyContent:"center"}}>
                            <Typography variant={"body2"}>{meal} - {mainBookingDetails.preferences[meal]}</Typography>
                        </Box>
                ))}
            </Box>
            <Divider/>
        </>
    )
}

const ButtonGroup = ({mainBooking, removeAction, editAction})=>{
    const navigate = useNavigate()
    return(
        <ThemeProvider theme={theme}>
            <Box sx={{display:"flex", justifyContent:"center", alignItems:"center",padding:"34px"}}>
                <Stack direction="row" spacing={2}>
                    {mainBooking.booking?.status==="Booked"&&<Typography variant="h6" sx={{color:"#FF7300", fontWeight:"bold"}}>Booked!</Typography>}
                    {mainBooking.booking?.status==="Upcoming"&&
                    <>
                        <Button variant="contained" color="dark" sx={{borderRadius:"10px", marginRight:"50px"}} onClick={editAction}>
                            <CreateOutlinedIcon sx={{color:"#FBFBFB"}}/>
                        </Button>
                        <Button variant="contained" color="warning" sx={{borderRadius:"10px", marginLeft:"50px"}} onClick={removeAction}>
                            <BackspaceOutlinedIcon sx={{color:"#FBFBFB"}}/>
                        </Button>
                    </>}
                    {!mainBooking.booking&&<Button variant="contained" color="warning" onClick={()=>{navigate("/Bookings/AddBooking")}} sx={{borderRadius:"20px",fontWeight:"bold", padding:"15px"}}>
                        Create Booking
                    </Button>}
                </Stack>
            </Box>
        </ThemeProvider>
    )
}

export default function Drawer(){
    const {dispatchBookingList} = useBookingListContext()
    const {mainBooking} = useMainBookingContext()
    const navigate = useNavigate()
    
    const removeBooking = ()=>{
        dispatchBookingList({type:"REMOVE", payload:mainBooking.booking.date})
    }

    const editBooking = ()=>{
        navigate(`/Bookings/EditBooking/${mainBooking.booking.id}`)
    }

    return(
        
            <Paper 
            elevation={10} 
            sx={{
                height:"100%",
                paddingBottom:"60px",
                boxShadow: "2px -11px 9px -6px rgba(137,137,137,0.58)",
                borderRadius:"20px 20px 00px 0px",
                display:"flex",
                alignItems:"center",
                justifyContent:"center"
            }}>   
                <Box>
                    <TitleMessage mainBooking={mainBooking}/>
                    {mainBooking.booking&&<MainBooking mainBookingDetails={mainBooking.booking}/>}
                    <ButtonGroup mainBooking={mainBooking} removeAction={removeBooking} editAction={editBooking}/>
                </Box>
            </Paper>
        
    )
}