// AttendanceOutDto.java
package com.hazari.dto;

import lombok.Data;

@Data
public class AttendanceOutDto {
    private Long labourId;
    private String photoPath;
    private Double latitude;
    private Double longitude;
}
