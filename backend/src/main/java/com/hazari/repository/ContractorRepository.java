// src/main/java/com/hazari/repository/ContractorRepository.java
package com.hazari.repository;

import com.hazari.entity.Contractor;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface ContractorRepository extends JpaRepository<Contractor, Long> {
    // Find by phone number
    Optional<Contractor> findByPhone(String phone);
    
    // Find contractor's labours (if labour has contractorId)
    // Note: This would be in LabourRepository typically
    List<Contractor> findByCompanyNameContainingIgnoreCase(String companyName);
    
    // Active contractors
    List<Contractor> findByIsActiveTrue();
}
