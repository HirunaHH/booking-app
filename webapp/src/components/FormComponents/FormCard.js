import * as React from 'react';
import { Divider, Box, CardContent, Card, Typography} from '@mui/material';
import BookingForm from './BookingForm';
import ScheduleForm from "./ScheduleForm"

export default function FormCard({title, type, mode}) {

  return (
    <Card sx={{ maxWidth: 500, flexDirection:"row", flexGrow:1, borderRadius:"20px"}}>

      <CardContent>
        <Box padding={"10px"}>
          <Typography gutterBottom variant="h5" component="div" sx={{color:"#B34663", fontWeight:"bold"}}>
                  {title}
          </Typography>
          <Divider/>
          <br/>
          {type==="Booking"&&<BookingForm mode={mode}/>}
          {type==="Schedule"&&<ScheduleForm/>}
        </Box>

      </CardContent>
    </Card>
  );
}