package com.hazari.dto;

import lombok.Data;

@Data
public class AttendanceInDto {
    private Long labourId;
    private String photoPath;
    private double latitude;
    private double longitude;
}
