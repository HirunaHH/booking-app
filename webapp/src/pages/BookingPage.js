import { Box, Container, CssBaseline } from "@mui/material"
import TopNav from "../components/navigation/TopNav"
import FormCard from "../components/FormComponents/FormCard"


export default function Booking({mode}){

    return(
        <>
            <TopNav/>
            <Box
            sx={{
                display: 'flex',
                height: `calc(100vh - 120px)`,
                alignItems:"center"
            }}>
                <Container maxWidth="sm" sx={{ display:"flex", alignItems:"center"}}>
                    <CssBaseline />
                    <FormCard 
                    type={"Booking"} 
                    mode={mode} 
                    title={mode==="add"?"Add Your New Booking":"Edit the Booking"} 
                    />
                </Container>
            </Box>
        </>
    )
}