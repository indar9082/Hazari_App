package com.hazari.controller;

import com.hazari.dto.AttendanceInDto;
import com.hazari.dto.AttendanceOutDto;
import com.hazari.dto.LeaveRequestDto;
import com.hazari.entity.Attendance;
import com.hazari.entity.Labour;
import com.hazari.entity.Leave;
import com.hazari.entity.User;
import com.hazari.repository.AttendanceRepository;
import com.hazari.repository.LabourRepository;
import com.hazari.repository.UserRepository;
import com.hazari.service.AttendanceService;
import com.hazari.service.LeaveService;
import org.springframework.http.ResponseEntity;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.*;

import org.springframework.security.crypto.password.PasswordEncoder;

@RestController
@RequestMapping("/api/labour")
@CrossOrigin(origins = "*")
public class LabourController {

    private final LabourRepository labourRepository;
    private final AttendanceService attendanceService;
    private final LeaveService leaveService;
    private final AttendanceRepository attendanceRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    public LabourController(LabourRepository labourRepository,
                            AttendanceService attendanceService,
                            LeaveService leaveService,
                            AttendanceRepository attendanceRepository,
                            UserRepository userRepository,
                            PasswordEncoder passwordEncoder) {
        this.labourRepository = labourRepository;
        this.attendanceService = attendanceService;
        this.leaveService = leaveService;
        this.attendanceRepository = attendanceRepository;
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
    }

    // =========================
    // 0️⃣ ADD NEW LABOUR + CREATE LOGIN ACCOUNT
    // =========================
    @PostMapping("/add")
    public ResponseEntity<?> addLabour(@RequestBody Labour labourRequest) {

        if (labourRequest.getContractorId() == null) {
            return ResponseEntity.badRequest().body("contractorId is required");
        }
        if (labourRequest.getPhone() == null || labourRequest.getPhone().isBlank()) {
            return ResponseEntity.badRequest().body("phone is required");
        }
        if (labourRequest.getName() == null || labourRequest.getName().isBlank()) {
            return ResponseEntity.badRequest().body("name is required");
        }

        // Avoid duplicate phone as user
        if (userRepository.existsByPhone(labourRequest.getPhone())) {
            return ResponseEntity.badRequest().body("Phone already registered as a user");
        }

        // 1️⃣ Create USER (for login)
        String username = labourRequest.getPhone();   // using phone as username
        String rawPassword = "123456";                // default password to give labour
        String encodedPassword = passwordEncoder.encode(rawPassword);

        User user = new User();
        user.setUsername(username);
        user.setPassword(encodedPassword);
        user.setPhone(labourRequest.getPhone());
        user.setRole("LABOUR");                       // for routing/authorization
        userRepository.save(user);

        // 2️⃣ Create LABOUR record linked to this user
        Labour labour = new Labour();
        labour.setName(labourRequest.getName());
        labour.setPhone(labourRequest.getPhone());
        labour.setAadhaarNumber(labourRequest.getAadhaarNumber());

        // default dailyRate if null
        if (labourRequest.getDailyRate() == null) {
            labour.setDailyRate(0.0);
        } else {
            labour.setDailyRate(labourRequest.getDailyRate());
        }

        labour.setContractorId(labourRequest.getContractorId());
        labour.setActive(true);

        // default hireDate = today if null
        if (labourRequest.getHireDate() != null) {
            labour.setHireDate(labourRequest.getHireDate());
        } else {
            labour.setHireDate(LocalDate.now());
        }

        // link user ↔ labour
        labour.setUserId(user.getId());

        Labour savedLabour = labourRepository.save(labour);

        // 3️⃣ Prepare response for Flutter
        Map<String, Object> resp = new HashMap<>();
        resp.put("labour", savedLabour);
        resp.put("username", username);
        resp.put("password", rawPassword); // contractor can share this once

        return ResponseEntity.ok(resp);
    }

    // =========================
    // 1️⃣ LABOUR PROFILE
    // =========================
    @GetMapping("/profile/{labourId}")
    public ResponseEntity<Labour> getLabourProfile(@PathVariable @NonNull Long labourId) {
        Optional<Labour> labour = labourRepository.findById(labourId);
        return labour.map(ResponseEntity::ok)
                     .orElse(ResponseEntity.notFound().build());
    }

    // =========================
    // 2️⃣ CHECK-IN
    // =========================
    @PostMapping("/checkin")
    public ResponseEntity<String> checkIn(@RequestBody AttendanceInDto dto) {
        Attendance attendance = attendanceService.checkIn(dto);
        return ResponseEntity.ok("Check-in successful. ID: " + attendance.getId());
    }

    // =========================
    // 3️⃣ CHECK-OUT
    // =========================
    @PostMapping("/checkout/{labourId}")
    public ResponseEntity<String> checkOut(
            @PathVariable @NonNull Long labourId,
            @RequestBody AttendanceOutDto dto) {

        Attendance attendance = attendanceService.checkOut(labourId, dto);
        return ResponseEntity.ok("Check-out successful. ID: " + attendance.getId());
    }

    // =========================
    // 4️⃣ LEAVE REQUEST
    // =========================
    @PostMapping("/leaves")
    public ResponseEntity<?> createLeaveRequest(@RequestBody Leave incoming) {
        try {
            // If frontend sends startDate/endDate as strings in yyyy-MM-dd, Jackson will bind to LocalDate automatically
            Leave saved = leaveService.createLeaveRequest(incoming);
            return ResponseEntity.ok(saved);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(500).body("Error creating leave request: " + e.getMessage());
        }
    }

    // Optional: get labour leaves
    @GetMapping("/{labourId}/leaves")
    public ResponseEntity<?> getLeavesByLabour(@PathVariable Long labourId) {
        return ResponseEntity.ok(leaveService.getLeavesByLabour(labourId));
    }



    // =========================
    // 5️⃣ DASHBOARD SUMMARY
    // =========================
    @GetMapping("/dashboard/{labourId}")
    public ResponseEntity<Map<String, Object>> getDashboardSummary(@PathVariable @NonNull Long labourId) {
        Optional<Labour> labourOpt = labourRepository.findById(labourId);
        if (labourOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Labour labour = labourOpt.get();
        Map<String, Object> summary = Map.of(
                "name", labour.getName(),
                "phone", labour.getPhone(),
                "dailyRate", labour.getDailyRate(),
                "isActive", labour.isActive(),
                "hireDate", labour.getHireDate()
        );
        return ResponseEntity.ok(summary);
    }

    // =========================
    // 6️⃣ TODAY'S ATTENDANCE STATUS (mock for now)
    // =========================
    @GetMapping("/today-status/{labourId}")
    public ResponseEntity<Map<String, Object>> getTodayStatus(@PathVariable @NonNull Long labourId) {

        Map<String, Object> status = Map.of(
                "labourId", labourId,
                "todayCheckedIn", true,
                "todayCheckedOut", false,
                "hoursWorked", "8.5"
        );
        return ResponseEntity.ok(status);
    }

    // =========================
    // 7️⃣ GET ALL LABOURS UNDER A CONTRACTOR (WITH daysWorked)
    // =========================
    @GetMapping("/by-contractor/{contractorId}")
    public ResponseEntity<List<Labour>> getLaboursByContractor(
            @PathVariable @NonNull Long contractorId) {

        List<Labour> labours = labourRepository.findByContractorId(contractorId);

        // For each labour, compute daysWorked from attendance table
        for (Labour labour : labours) {
            long daysWorked = attendanceRepository
                    .countByLabourIdAndTimeInIsNotNull(labour.getId());
            labour.setDaysWorked(daysWorked);
        }

        return ResponseEntity.ok(labours);
    }
}
