package com.hazari.service;

import com.hazari.entity.Leave;
import com.hazari.repository.LeaveRepository;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class LeaveService {

    private final LeaveRepository leaveRepository;

    public LeaveService(LeaveRepository leaveRepository) {
        this.leaveRepository = leaveRepository;
    }

    public Leave createLeaveRequest(Leave leave) {
        if (leave.getStatus() == null) {
            leave.setStatus("PENDING");
        }
        return leaveRepository.save(leave);
    }

    public List<Leave> getPendingLeaves() {
        return leaveRepository.findByStatus("PENDING");
    }

    public List<Leave> getPendingLeavesForContractor(Long contractorId) {
        return leaveRepository.findByContractorIdAndStatus(contractorId, "PENDING");
    }

    public Leave updateLeaveStatus(Long leaveId, String status) {
        Optional<Leave> opt = leaveRepository.findById(leaveId);
        if (opt.isPresent()) {
            Leave l = opt.get();
            l.setStatus(status);
            return leaveRepository.save(l);
        } else {
            throw new RuntimeException("Leave not found");
        }
    }

    public List<Leave> getLeavesByLabour(Long labourId) {
        return leaveRepository.findByLabourId(labourId);
    }
}
