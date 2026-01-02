package com.hazari.repository;

import com.hazari.entity.Leave;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface LeaveRepository extends JpaRepository<Leave, Long> {
    List<Leave> findByStatus(String status);
    List<Leave> findByContractorIdAndStatus(Long contractorId, String status);
    List<Leave> findByLabourId(Long labourId);
}
