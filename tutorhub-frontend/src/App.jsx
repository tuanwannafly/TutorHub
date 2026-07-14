import { Routes, Route } from "react-router-dom";
import Layout from "./components/Layout.jsx";
import RequireAuth from "./components/RequireAuth.jsx";

import Home from "./pages/Home.jsx";
import Login from "./pages/Login.jsx";
import Signup from "./pages/Signup.jsx";
import Dashboard from "./pages/Dashboard.jsx";
import TutorsIndex from "./pages/TutorsIndex.jsx";
import TutorProfile from "./pages/TutorProfile.jsx";
import Bookings from "./pages/Bookings.jsx";
import BookingDetail from "./pages/BookingDetail.jsx";
import Availability from "./pages/Availability.jsx";
import Reports from "./pages/Reports.jsx";
import NotFound from "./pages/NotFound.jsx";

export default function App() {
  return (
    <Layout>
      <Routes>
        <Route path="/"                element={<Home />} />
        <Route path="/login"           element={<Login />} />
        <Route path="/signup"          element={<Signup />} />
        <Route path="/tutors"          element={<TutorsIndex />} />
        <Route path="/tutors/:id"      element={<TutorProfile />} />

        <Route path="/dashboard"       element={<RequireAuth><Dashboard /></RequireAuth>} />
        <Route path="/bookings"        element={<RequireAuth><Bookings /></RequireAuth>} />
        <Route path="/bookings/:id"    element={<RequireAuth><BookingDetail /></RequireAuth>} />
        <Route path="/availability"    element={<RequireAuth role="tutor"><Availability /></RequireAuth>} />
        <Route path="/reports"         element={<RequireAuth><Reports /></RequireAuth>} />

        <Route path="*"                element={<NotFound />} />
      </Routes>
    </Layout>
  );
}