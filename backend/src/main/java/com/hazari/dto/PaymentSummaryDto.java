// src/main/java/com/hazari/dto/PaymentSummaryDto.java
package com.hazari.dto;

public class PaymentSummaryDto {
    private Double totalAmount;
    private Integer daysWorked;
    private Double dailyRate;
    
    // Constructors
    public PaymentSummaryDto() {}
    
    // Getters and Setters
    public Double getTotalAmount() { return totalAmount; }
    public void setTotalAmount(Double totalAmount) { this.totalAmount = totalAmount; }
    public Integer getDaysWorked() { return daysWorked; }
    public void setDaysWorked(Integer daysWorked) { this.daysWorked = daysWorked; }
    public Double getDailyRate() { return dailyRate; }
    public void setDailyRate(Double dailyRate) { this.dailyRate = dailyRate; }
}
