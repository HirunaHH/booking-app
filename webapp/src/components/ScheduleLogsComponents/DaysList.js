import * as React from 'react';
import {Box, Paper, Grid, Typography} from '@mui/material';

export default function DaysList({preferences}) {
  return (
    <Box >
      <Grid container sx={{display:"flex", justifyContent:"center", paddingY:"20px", paddingX:"10px"}} spacing={{ xs: 2}} columns={{ xs:6, sm:9}}>
        {Object.keys(preferences).map((day) => (
          <Grid item xs={2} key={day}>
            <Paper sx={{borderRadius:"10px"}}>
                <Grid container >
                    <Grid item xs={12} backgroundColor="#FF7300" color={"white"} sx={{display:"flex", justifyContent:"center", p:"5px", borderRadius:"10px 10px 0px 0px"}}>
                        <Typography variant="body2" fontWeight={"bold"}>{day}</Typography>
                    </Grid>
                    {preferences[day]==="None"?
                    <Grid item xs={12} sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                        <Typography variant="caption">None</Typography>
                    </Grid>:
                    Object.keys(preferences[day]).map((meal)=>(
                        <Grid item xs={12} sx={{display:"flex", justifyContent:"center", alignItems:"center"}}>
                            <Typography variant="caption" paddingBottom={"4px"}>
                                {meal[0]} - {preferences[day][meal]}
                            </Typography>
                        </Grid>
                    ))}
                </Grid>
            </Paper>
          </Grid>
        ))}
      </Grid>
    </Box>
  );
}