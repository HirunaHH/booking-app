import { Stack,IconButton } from "@mui/material"

export default function BtnGroup({btn1, btn2}){
    return(
        <Stack direction="row" spacing={1}>
            <IconButton sx={{color:btn1.color}} onClick={()=>{btn1.action()}}>
                {btn1.content}
            </IconButton>
            <IconButton sx={{color:btn2.color}} onClick={()=>{btn2.action()}}>
                {btn2.content}
            </IconButton>
        </Stack>
    )
}