// src/main/java/com/hazari/repository/PaymentRepository.java
package com.hazari.repository;

import com.hazari.entity.Payment;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByUserIdOrderByPaymentDateDesc(Long userId);
}
