import './App.css';
import {BrowserRouter, Routes, Route} from "react-router-dom"
import BookingLogsPage from "./pages/BookingListPage"
import ScheduleLogsPage from "./pages/ScheduleListPage"
import HomePage from "./pages/HomePage"
import BookingPage from './pages/BookingPage';
import SchedulePage from './pages/SchedulePage';
import BottomNav from './components/navigation/BottomNav';
import { BookingListContextProvider } from './context/BookingListContext';
import { MainBookingContextProvider } from './context/MainBookingContext';


function App() {

  // showConfirmAlert("Hi", "Hi", "confirm", "cancel",()=>{},()=>{},()=>{});
  return (
    <BrowserRouter>
      <BookingListContextProvider>
        <MainBookingContextProvider>
          <Routes>
            <Route path="/Home" element={<HomePage/>}/>
            <Route path="/Bookings" element={<BookingLogsPage/>}/>
            <Route path="/Bookings/AddBooking" element={<BookingPage mode={"add"}/>}/>
            <Route path="/Bookings/EditBooking/:id" element={<BookingPage mode={"edit"}/>}/>
            <Route path="/Schedules" element={<ScheduleLogsPage/>}/>
            <Route path="/Schedules/AddSchedule" element={<SchedulePage/>}/>
          </Routes>
        </MainBookingContextProvider>
      </BookingListContextProvider>
      <BottomNav id="bottom-nav"/>
    </BrowserRouter>
  );
}

export default App;
