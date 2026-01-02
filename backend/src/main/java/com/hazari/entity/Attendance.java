package com.hazari.entity;

import jakarta.persistence.*;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "attendance")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Attendance {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // Labour ID (foreign key)
    @Column(name = "labour_id", nullable = false)
    private Long labourId;

    // Attendance Date
    @Column(nullable = false)
    private LocalDate date;

    // Check-in & Check-out timestamps
    private LocalDateTime timeIn;
    private LocalDateTime timeOut;

    // Photo paths
    private String inPhotoPath;
    private String outPhotoPath;

    // GPS coordinates
    private Double inLatitude;
    private Double inLongitude;

    private Double outLatitude;
    private Double outLongitude;

    // Stored or calculated attendance status
    private String status;

    // -----------------------------------
    // 🔹 Computed Fields (NOT stored in DB)
    // -----------------------------------

    @Transient
    public String getCheckInTime() {
        return timeIn != null ? timeIn.toLocalTime().toString() : null;
    }

    @Transient
    public String getCheckOutTime() {
        return timeOut != null ? timeOut.toLocalTime().toString() : null;
    }

    @Transient
    public String getAutoStatus() {
        if (timeIn == null && timeOut == null) return "ABSENT";
        if (timeIn != null && timeOut == null) return "PRESENT";
        return "PRESENT";
    }
}
