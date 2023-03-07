import * as React from 'react';
import {Table, Box, TableBody, TableCell, TableContainer, TableHead, TableRow, Typography} from '@mui/material';

export default function PreferencesTable({preferences}) {
  return (
    <Box padding={"20px"} >

        <TableContainer sx={{backgroundColor:"#FFF1E5"}}>
          <Table sx={{ minWidth: 200}} aria-label="customized table" size="small">
              <TableHead>
                <TableRow>
                    <TableCell>
                      <Typography variant='body' fontWeight={"bold"}>Day</Typography>
                      </TableCell>
                    <TableCell align="right">
                      <Typography variant='body' fontWeight={"bold"}>Lunch</Typography>
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant='body' fontWeight={"bold"}>Breakfast</Typography>
                    </TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
              {Object.keys(preferences).map((day,index) => (
                  <TableRow 
                  key={index}
                  sx={{ '&:last-child td, &:last-child th': { border: 0 } }}
                  >
                    <TableCell component="th" scope="row">
                      <Typography variant="body2">
                        {day}
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="body2">
                        {preferences[day].Lunch}
                      </Typography>
                    </TableCell>
                    <TableCell align="right">
                      <Typography variant="body2">
                        {preferences[day].Breakfast}
                      </Typography>
                    </TableCell>
                  </TableRow>
              ))}
              </TableBody>
          </Table>
        </TableContainer>
    </Box>
  );
}