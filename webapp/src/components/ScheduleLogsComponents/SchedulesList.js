import {Box, Stack} from "@mui/material"
import Schedules from "../../json-files/schedules.json"
import ScheduleItem from "./ScheduleItem";
import { useState } from "react";

const getSchedules=() =>{
    const arr = Schedules.schedules
    const activeIndex = arr.findIndex(obj => obj.status === 'Active');
    if (activeIndex !== -1) {
        const activeObj = arr.splice(activeIndex, 1)[0];
        arr.unshift(activeObj);
    }
    return arr;
}

export default function SchedulesList(){

    const [schedules, setSchedules] = useState(()=>(getSchedules()))
    return(
        <Box padding={"30px 15px 10px 15px"}>
            <Stack spacing={2}>
                {schedules.map((schedule) => (<ScheduleItem key={schedule.id} schedule={schedule}/>))}
            </Stack>          
        </Box>
    )
}


