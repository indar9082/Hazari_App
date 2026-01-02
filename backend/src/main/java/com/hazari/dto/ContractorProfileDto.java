package com.hazari.dto;

public class ContractorProfileDto {

    private Long id;
    private String name;
    private String phone;
    private String company;
    private boolean active;

    public ContractorProfileDto() {
    }

    public ContractorProfileDto(Long id, String name, String phone, String company, boolean active) {
        this.id = id;
        this.name = name;
        this.phone = phone;
        this.company = company;
        this.active = active;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getCompany() {
        return company;
    }

    public void setCompany(String company) {
        this.company = company;
    }

    public boolean isActive() {
        return active;
    }

    public void setActive(boolean active) {
        this.active = active;
    }
}
