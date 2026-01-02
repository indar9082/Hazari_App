// src/main/java/com/hazari/dto/LeaveRequestDto.java
package com.hazari.dto;

import java.time.LocalDate;
import jakarta.annotation.Nullable;

public class LeaveRequestDto {
    @Nullable private Long userId;
    private LocalDate startDate;
    private LocalDate endDate;
    private String reason;
    
    // Constructors
    public LeaveRequestDto() {}
    
    // Getters and Setters
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public LocalDate getStartDate() { return startDate; }
    public void setStartDate(LocalDate startDate) { this.startDate = startDate; }
    public LocalDate getEndDate() { return endDate; }
    public void setEndDate(LocalDate endDate) { this.endDate = endDate; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
}
