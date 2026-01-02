// src/main/java/com/hazari/entity/Contractor.java
package com.hazari.entity;

import jakarta.persistence.*;
import java.time.LocalDate;

@Entity
@Table(name = "contractors")
public class Contractor {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(nullable = false)
    private String name;
    
    @Column(unique = true, nullable = false)
    private String phone;
    
    @Column(unique = true)
    private String companyName;
    
    private String gstNumber;  // Indian GST
    private String address;
    
    private Double totalBudget;
    private Long projectId;
    
    private boolean isActive = true;
    private LocalDate contractStartDate;
    
    // Constructors
    public Contractor() {}
    
    // Getters & Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getGstNumber() { return gstNumber; }
    public void setGstNumber(String gstNumber) { this.gstNumber = gstNumber; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public Double getTotalBudget() { return totalBudget; }
    public void setTotalBudget(Double totalBudget) { this.totalBudget = totalBudget; }
    public Long getProjectId() { return projectId; }
    public void setProjectId(Long projectId) { this.projectId = projectId; }
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    public LocalDate getContractStartDate() { return contractStartDate; }
    public void setContractStartDate(LocalDate contractStartDate) { this.contractStartDate = contractStartDate; }
}
