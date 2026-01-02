package com.hazari.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "labour")
public class Labour {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    private String phone;
    private String aadhaarNumber;
    private Double dailyRate;

    // Link to Contractor
    private Long contractorId;

    private Long userId;

    private boolean isActive = true;

    private LocalDate hireDate;

    // Link Labour -> Login User
   

    // Not stored in DB (calculated when sending response)
    @Transient
    private long daysWorked;

    // ---------------- Getters & Setters ---------------- //
    
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }

    public String getAadhaarNumber() { return aadhaarNumber; }
    public void setAadhaarNumber(String aadhaarNumber) { this.aadhaarNumber = aadhaarNumber; }

    public Double getDailyRate() { return dailyRate; }
    public void setDailyRate(Double dailyRate) { this.dailyRate = dailyRate; }

    public Long getContractorId() { return contractorId; }
    public void setContractorId(Long contractorId) { this.contractorId = contractorId; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public LocalDate getHireDate() { return hireDate; }
    public void setHireDate(LocalDate hireDate) { this.hireDate = hireDate; }

    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }

    public long getDaysWorked() { return daysWorked; }
    public void setDaysWorked(long daysWorked) { this.daysWorked = daysWorked; }
}
