import * as React from 'react';
import {Box, Grid, IconButton} from '@mui/material';
import AddCircleOutlineOutlinedIcon from '@mui/icons-material/AddCircleOutlineOutlined';

export default function({addAction}){
    return (
        <Box mt={1}>
            <Grid container>
                <Grid item xs={10}></Grid>
                <Grid item xs={2} sx={{display:"flex", justifyContent:"end"}}>
                    <IconButton aria-label="edit" sx={{color:"#030000"}} size="small" onClick={addAction}>
                        <AddCircleOutlineOutlinedIcon fontSize='large' style={{color:'white'}}/>
                    </IconButton>
                </Grid>
            </Grid>
        </Box>
    )
}