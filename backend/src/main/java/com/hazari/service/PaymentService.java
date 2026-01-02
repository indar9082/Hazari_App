
// src/main/java/com/hazari/service/PaymentService.java - CORRECTED
package com.hazari.service;

import com.hazari.dto.PaymentSummaryDto;
import org.springframework.stereotype.Service;

@Service  // ADD THIS ANNOTATION
public class PaymentService {
    
    // REMOVE AttendanceRepository dependency - not needed for dummy data
    public PaymentSummaryDto getPaymentSummary(Long userId) {
        PaymentSummaryDto summary = new PaymentSummaryDto();
        summary.setTotalAmount(5000.0);
        summary.setDaysWorked(22);
        summary.setDailyRate(227.27);
        return summary;
    }
}
