import * as React from 'react';
import { useTheme } from '@mui/material/styles';
import {Select, MenuItem, InputLabel, Box, MobileStepper, Typography, Button, FormControl, TextField, Stack, IconButton, Grid } from '@mui/material'
import { useState } from 'react';
import {Table, TableBody, TableCell, TableContainer, TableHead, TableRow} from '@mui/material';
import KeyboardArrowLeft from '@mui/icons-material/KeyboardArrowLeft';
import KeyboardArrowRight from '@mui/icons-material/KeyboardArrowRight';
import CloseIcon from '@mui/icons-material/Close';
import AddTaskIcon from '@mui/icons-material/AddTask';


const FormView1 = ({scheduleName, setScheduleName, recurringMode, setRecurringMode})=>{


    return(
        <Box minHeight={350} display={"flex"} alignItems={"center"} justifyContent={"center"}>
            <Stack spacing={5}>
                <FormControl>
                    <TextField
                    required
                    id="outlined-required"
                    label="Schedule Name"
                    variant='outlined'
                    value={scheduleName}
                    onChange={(event)=>{setScheduleName(event.target.value)}}
                    color={"warning"}
                    />
                </FormControl>
                <FormControl>
                    <InputLabel id="demo-simple-select-label" color='warning'>Recurring Mode</InputLabel>
                    <Select
                    labelId="demo-simple-select-label"
                    id="demo-simple-select"
                    label="Recurring Mode"
                    value={recurringMode}
                    onChange={(event)=>{setRecurringMode(event.target.value)}}
                    color={"warning"}
                    >
                        <MenuItem value={"1 Week"}>1 Week</MenuItem>
                        <MenuItem value={"2 Weeks"}>2 Weeks</MenuItem>
                        <MenuItem value={"3 Weeks"}>3 Weeks</MenuItem>
                        <MenuItem value={"4 Weeks"}>4 Weeks</MenuItem>
                    </Select>
                </FormControl>
            </Stack>      
        </Box>
    )
}

const FormView2 = ({rows, deleteRow, addRow, changePreference, handleSubmit})=>{

    const days=["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
    return(
        <Box>
            <TableContainer>
                <Table size="small" >
                    <TableHead>
                        <TableRow>
                            <TableCell align='center'></TableCell>
                            <TableCell align='center'>Day</TableCell>
                            <TableCell align='center'>Lunch</TableCell>
                            <TableCell align='center'>Breakfast</TableCell>
                        </TableRow>
                    </TableHead>
                    <TableBody>
                        {days.filter(day=>Object.keys(rows).includes(day)).map((day,index)=>{
                            return (<TableRow 
                            key={day}
                            sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                            >
                            <TableCell component="th" scope="row">
                                <IconButton aria-label="delete" color="warning" onClick={()=>{deleteRow(day)}}>
                                    <CloseIcon fontSize="small" />
                                </IconButton>
                            </TableCell>
                            <TableCell align="center">
                                <Typography variant="body2">
                                {day}
                                </Typography>
                            </TableCell>
                            <TableCell align="center">
                                <FormControl variant="standard" sx={{ m: 1, minWidth: 50 }}>
                                    <Select
                                    id="demo-simple-select-standard"
                                    value={rows[day].Lunch}
                                    name={"Lunch"}
                                    onChange={(event)=>{changePreference(day,event.target.name,event.target.value)}}
                                    >
                                    <MenuItem value="None"><Typography variant="body2">None</Typography></MenuItem>
                                    <MenuItem value="Fish"><Typography variant="body2">Fish</Typography></MenuItem>
                                    <MenuItem value="Chicken"><Typography variant="body2">Chicken</Typography></MenuItem>
                                    <MenuItem value="Veg"><Typography variant="body2">Veg</Typography></MenuItem>
                                    </Select>
                                </FormControl>
                            </TableCell>
                            <TableCell align="center">
                                <FormControl variant="standard" sx={{ m: 1, minWidth: 50 }}>
                                    <Select
                                    id="demo-simple-select-standard"
                                    value={rows[day].Breakfast}
                                    name={"Breakfast"}
                                    onChange={(event)=>{changePreference(day,event.target.name,event.target.value)}}
                                    >
                                    <MenuItem value="None"><Typography variant="body2">None</Typography></MenuItem>
                                    <MenuItem value="Fish"><Typography variant="body2">Fish</Typography></MenuItem>
                                    <MenuItem value="Chicken"><Typography variant="body2">Chicken</Typography></MenuItem>
                                    <MenuItem value="Veg"><Typography variant="body2">Veg</Typography></MenuItem>
                                    </Select>
                                </FormControl>
                            </TableCell>
                            </TableRow>)
                        })}
                    </TableBody>
                </Table>
            </TableContainer>
            <Grid container spacing={{xs:1}} columns={{xs:8, md:10, lg:10}} padding={2}>
                {days.filter(day=>!Object.keys(rows).includes(day)).map((day,index)=>{
                    return(
                    <Grid item xs={2} key={index}>
                        <Button variant="outlined" color="warning" size='small' sx={{borderRadius:"10px", fontWeight:"bold"}} onClick={()=>{addRow(day)}}>+ {day.substring(0,3)}</Button>
                    </Grid>) 
                })}
            </Grid>
            <Box sx={{display:"flex", justifyContent:"center"}}>
                <Button variant="contained" color="warning" size="medium" onClick={handleSubmit}>Save <AddTaskIcon sx={{padding:"2px"}}/></Button>
            </Box>
        </Box>
    )
}
function SwipeableTextMobileStepper() {
    const [rows, setRows] = useState({
        "Monday":{"Lunch":"None", "Breakfast":"None"},
        "Tuesday":{"Lunch":"None", "Breakfast":"None"},
        "Wednesday":{"Lunch":"None", "Breakfast":"None"},
        "Thursday":{"Lunch":"None", "Breakfast":"None"},
        "Friday":{"Lunch":"None", "Breakfast":"None"},
    })

    const deleteRow = (day)=>{
        const newRows = {...rows}
        delete newRows[day]
        setRows(newRows)
    }

    const addRow = (day)=>{
        const newRows = {
            ...rows,
            [day]:{"Lunch":"None","Breakfast":"None"},
        }
        setRows(newRows)
    }

    const changePreference = (day, meal, preference) =>{
        setRows((prevRows)=>{
            return {
                ...prevRows,
                [day]:{
                    ...prevRows[day],
                    [meal]:preference
                }
            }
        }) 
    }

    const handleSubmit = ()=>{
        console.log({
            "name":scheduleName,
            "mode":recurringMode,
            "schedule":rows
        })
    }

    const [scheduleName, setScheduleName] = useState("")
    const [recurringMode, setRecurringMode] = useState("")

    const theme = useTheme();
    const [activeStep, setActiveStep] = React.useState(0);
    const [swipeableViews, setViews]= useState([<FormView1 scheduleName={scheduleName} setScheduleName={setScheduleName} recurringMode={recurringMode} setRecurringMode={setRecurringMode}/>,<FormView2 rows={rows} deleteRow={deleteRow}/>])
    const maxSteps = swipeableViews.length;

    const handleNext = () => {
        setActiveStep((prevActiveStep) => prevActiveStep + 1);
    };

    const handleBack = () => {
        setActiveStep((prevActiveStep) => prevActiveStep - 1);
    };

    const handleStepChange = (step) => {
        setActiveStep(step);
    };

    return (
        <Box sx={{flexGrow: 1 }}>
        
        <Box>
            {swipeableViews[activeStep]}
        </Box>
        <MobileStepper
            steps={maxSteps}
            position="static"
            activeStep={activeStep}
            nextButton={
            <Button
                size="small"
                onClick={handleNext}
                disabled={activeStep === maxSteps - 1}
                color={"warning"}
            >
                Next
                {theme.direction === 'rtl' ? (
                <KeyboardArrowLeft />
                ) : (
                <KeyboardArrowRight />
                )}
            </Button> 
            }
            backButton={
            <Button size="small" onClick={handleBack} disabled={activeStep === 0} color={"warning"}>
                {theme.direction === 'rtl' ? (
                <KeyboardArrowRight />
                ) : (
                <KeyboardArrowLeft />
                )}
                Back
            </Button>
            }
        />
        </Box>
    );
}

export default SwipeableTextMobileStepper;