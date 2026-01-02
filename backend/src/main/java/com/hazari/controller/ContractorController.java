package com.hazari.controller;

import com.hazari.dto.PaymentSummaryDto;
import com.hazari.dto.TodayAttendanceDto;
import com.hazari.dto.ContractorProfileDto;
import com.hazari.entity.Contractor;
import com.hazari.entity.Leave;
import com.hazari.repository.ContractorRepository;
import com.hazari.service.LeaveService;
import com.hazari.service.ContractorService;
import com.hazari.service.PaymentService;
import com.hazari.service.AttendanceService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/api/contractor")
@CrossOrigin(origins = "*")
public class ContractorController {

    private final ContractorRepository contractorRepository;
    private final AttendanceService attendanceService;
    private final LeaveService leaveService;
    private final PaymentService paymentService;
    private final ContractorService contractorService;

    public ContractorController(ContractorRepository contractorRepository,
                                LeaveService leaveService,
                                PaymentService paymentService,
                                AttendanceService attendanceService,
                                ContractorService contractorService) {
        this.contractorRepository = contractorRepository;
        this.leaveService = leaveService;
        this.paymentService = paymentService;
        this.attendanceService = attendanceService;
        this.contractorService = contractorService;
    }

    // ------------------------------------------------------------------
    // PROFILE: GET /api/contractor/profile/{userId}
    // Here contractorId == userId from login in your current design
    // ------------------------------------------------------------------
    @GetMapping("/profile/{userId}")
    public ResponseEntity<ContractorProfileDto> getContractorProfile(
            @PathVariable Long userId) {
        ContractorProfileDto dto = contractorService.getProfile(userId);
        return ResponseEntity.ok(dto);
    }

    // ------------------------------------------------------------------
    // PENDING LEAVES (Approve/Reject)
    // ------------------------------------------------------------------
  @GetMapping("/leaves/pending")
public ResponseEntity<List<Leave>> getPendingLeaves(@RequestParam(name = "contractorId", required = false) Long contractorId) {
    if (contractorId != null) {
        return ResponseEntity.ok(leaveService.getPendingLeavesForContractor(contractorId));
    } else {
        return ResponseEntity.ok(leaveService.getPendingLeaves());
    }
}


    @PutMapping("/leaves/{leaveId}/approve")
    public ResponseEntity<String> approveLeave(@PathVariable Long leaveId) {
       leaveService.updateLeaveStatus(leaveId, "APPROVED");
       return ResponseEntity.ok("Leave approved successfully");}

   @PutMapping("/leaves/{leaveId}/reject")
    public ResponseEntity<String> rejectLeave(@PathVariable Long leaveId,
    @RequestParam(name = "reason", required = false) String reason) {
       leaveService.updateLeaveStatus(leaveId, "REJECTED"); String msg = "Leave rejected";
       if (reason != null && !reason.isEmpty()) {
           msg += ": " + reason;
     }
     return ResponseEntity.ok(msg);}

    // ------------------------------------------------------------------
    // PAYMENT SUMMARY
    // GET /api/contractor/payment-summary/{userId}
    // ------------------------------------------------------------------
    @GetMapping("/payment-summary/{userId}")
    public ResponseEntity<PaymentSummaryDto> getPaymentSummary(@PathVariable Long userId) {
        return ResponseEntity.ok(paymentService.getPaymentSummary(userId));
    }

    // ------------------------------------------------------------------
    // CONTRACTOR DASHBOARD
    // GET /api/contractor/dashboard/{contractorId}
    // ------------------------------------------------------------------
    @GetMapping("/dashboard/{contractorId}")
    public ResponseEntity<?> getContractorDashboard(@PathVariable Long contractorId) {
        Contractor contractor = contractorRepository.findById(contractorId).orElse(null);
        if (contractor == null) {
            return ResponseEntity.notFound().build();
        }

        Map<String, Object> response = new HashMap<>();
        response.put("name", contractor.getName());
        response.put("company", contractor.getCompanyName());
        response.put("totalBudget", contractor.getTotalBudget());
        response.put("active", contractor.isActive());

        return ResponseEntity.ok(response);
    }

    // ----------------------------------------------------------------------
    // TODAY'S ATTENDANCE FOR CONTRACTOR DASHBOARD - PATH STYLE
    // GET /api/contractor/{contractorId}/today-attendance
    // (Used by ApiService.getContractorTodayAttendance)
    // ----------------------------------------------------------------------
    @GetMapping("/{contractorId}/today-attendance")
    public ResponseEntity<List<TodayAttendanceDto>> getTodayAttendanceForContractorPath(
            @PathVariable("contractorId") Long contractorId) {
        List<TodayAttendanceDto> attendance =
                attendanceService.getTodayAttendanceForContractor(contractorId);
        return ResponseEntity.ok(attendance);
    }

    // ----------------------------------------------------------------------
    // TODAY'S ATTENDANCE - GENERAL + OPTIONAL FILTER
    // GET /api/contractor/attendance/today
    // Optional: ?contractorId=123 to filter
    // (This is kept for flexibility / backward compatibility)
    // ----------------------------------------------------------------------
    @GetMapping("/attendance/today")
    public ResponseEntity<List<TodayAttendanceDto>> getTodayAttendance(
            @RequestParam(name = "contractorId", required = false) Long contractorId) {

        List<TodayAttendanceDto> attendance;

        if (contractorId != null) {
            attendance = attendanceService.getTodayAttendanceForContractor(contractorId);
        } else {
            attendance = attendanceService.getTodayAttendance();
        }

        return ResponseEntity.ok(attendance);
    }

}
