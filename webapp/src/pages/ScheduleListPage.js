import { Container, Box, CssBaseline } from "@mui/material";
import BottomNav from "../components/navigation/BottomNav";
import TopNav from "../components/navigation/TopNav"
import SchedulesList from "../components/ScheduleLogsComponents/SchedulesList"
import ButtonGroupAdd from "../components/ButtonComponents/ButtonGroup-add";
import { useNavigate } from "react-router-dom";

export default function SchedulesPage(){

    const navigate = useNavigate()
    return(
        <>
            <TopNav/>
            <Container maxWidth="sm" sx={{paddingBottom:"60px"}}>
                <CssBaseline />
                <Box sx={{paddingX:"10px"}}>
                    <SchedulesList/>
                </Box>
                <ButtonGroupAdd addAction={()=>{navigate("/Schedules/AddSchedule")}}/>
            </Container>
            <BottomNav/>
        </>
    )
}