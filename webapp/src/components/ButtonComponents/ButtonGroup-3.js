import { Grid, Button } from "@mui/material"
import BtnGroup2 from "./ButtonGroup-2"

export default function ButtonGroup({btn1, btn2, btn3}){
    return(
        <Grid container padding={"10px"}>
            <Grid item xs={6} sx={{display:"flex", alignItems:"center", justifyContent:"start"}}>
                <Button className="btn1" variant="contained" color={btn1.color} size="small">{btn1.content}</Button>
            </Grid>
            <Grid item xs={6} sx={{display:"flex", alignItems:"center", justifyContent:"end"}}>
                <BtnGroup2 btn1={btn2} btn2={btn3}/>
            </Grid>

        </Grid>
    )
}