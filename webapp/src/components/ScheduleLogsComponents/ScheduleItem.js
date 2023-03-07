import { Paper, Typography, Grid, Divider} from "@mui/material";
import BackspaceOutlinedIcon from '@mui/icons-material/BackspaceOutlined';
import CreateOutlinedIcon from '@mui/icons-material/CreateOutlined';
import DaysTable from "./DaysTable"
import BtnGroup3 from "../ButtonComponents/ButtonGroup-3"


export default function ScheduleItem({schedule}){
    return(
        <Paper elevation={15} sx={{padding:"15px", backgroundColor:"#FFF1E5", borderRadius:"20px", border:schedule.status==="Active"?"3px solid green":"none"}}>
                <Grid container paddingBottom={"10px"} >
                    <Grid item xs={9} sx={{display:"flex", alignItems:"center"}}>
                        <Typography variant="h6" component="h3" sx={{color:"#FF7300", fontWeight:"bold"}}>{schedule.name}</Typography>
                    </Grid>
                    {schedule.status==="Active"&&<Grid item xs={3} sx={{display:"flex", alignItems:"center",justifyContent:"end"}}>
                        <Typography variant="subtitle2" component="h3" sx={{color:"#00AF1C", fontWeight:"bold"}}>{schedule.status}</Typography>
                    </Grid>}
                </Grid>
                <Divider/>
                    <DaysTable preferences={schedule.preferences}/>
                    {/* <DaysList preferences={schedule.preferences}/> */}
                <Divider/>
                <Typography variant="body2" component="h6" sx={{fontWeight:"bold", color:"#CD2323", padding:"10px"}}>Recurring - {schedule.recurring}</Typography>
                <BtnGroup3
                btn1={{
                    "color":schedule.status==="Active"?"error":"success",
                    "content":schedule.status==="Active"?"Deactivate":"Activate"
                    }}
                btn2={{
                    "color":"#030000",
                    "content":<CreateOutlinedIcon fontSize="medium"/>
                }}
                btn3={{
                    "color":"#FF7300",
                    "content":<BackspaceOutlinedIcon fontSize="medium"/>
                }}
                />

        </Paper>
    )
}