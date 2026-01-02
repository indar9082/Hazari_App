package com.hazari.dto;

import lombok.Data;
import java.time.LocalDateTime;

@Data
public class AttendanceDto {
    private Long id;
    private Long labourId;
    private String photoPath;
    private double latitude;
    private double longitude;
    private LocalDateTime timeIn;
    private LocalDateTime timeOut;
    private String action; // "IN" or "OUT"
    private String reason; // For leave
    private double amount; // For payment
}
