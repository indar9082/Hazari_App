// src/main/java/com/hazari/repository/LabourRepository.java
package com.hazari.repository;

import com.hazari.entity.Labour;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;
import java.util.Optional;

@Repository
public interface LabourRepository extends JpaRepository<Labour, Long> {
    // Find by phone number
     // OR even better if you store userId on Labour:
    Optional<Labour> findByUserId(Long userId);
    Optional<Labour> findByPhone(String phone);


    
    
   
    

    // Find all labours under a contractor (if contractorId field added)
    List<Labour> findByContractorId(Long contractorId);
    
    // Active labours (not on leave)
    List<Labour> findByIsActiveTrue();
}
