// src/main/java/com/hazari/dto/RegisterRequest.java
package com.hazari.dto;

public class RegisterRequest {
    private String username;
    private String password;
    private String phone;
    private String role;
    
    public RegisterRequest() {}
    
    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getPhone() { return phone; }
    public void setPhone(String phone) { this.phone = phone; }
    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}
