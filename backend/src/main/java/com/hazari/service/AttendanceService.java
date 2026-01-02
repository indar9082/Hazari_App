package com.hazari.service;

import com.hazari.dto.AttendanceInDto;
import com.hazari.dto.AttendanceOutDto;
import com.hazari.dto.TodayAttendanceDto;
import com.hazari.entity.Attendance;
import com.hazari.entity.Labour;
import com.hazari.repository.AttendanceRepository;
import com.hazari.repository.LabourRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

@Service
public class AttendanceService {

    private final AttendanceRepository attendanceRepository;
    private final LabourRepository labourRepository;

    public AttendanceService(AttendanceRepository attendanceRepository,
                             LabourRepository labourRepository) {
        this.attendanceRepository = attendanceRepository;
        this.labourRepository = labourRepository;
    }

    // ====================================
    // ✅ CHECK-IN (with photo + location)
    // ====================================
    public Attendance checkIn(AttendanceInDto dto) {

        LocalDate today = LocalDate.now();

        // Check if already exists for today
        Attendance attendance = attendanceRepository
                .findByLabourIdAndDate(dto.getLabourId(), today)
                .orElseGet(Attendance::new);

        attendance.setLabourId(dto.getLabourId());
        attendance.setDate(today);
        attendance.setTimeIn(LocalDateTime.now());

        // From Flutter camera + GPS
        attendance.setInPhotoPath(dto.getPhotoPath());
        attendance.setInLatitude(dto.getLatitude());
        attendance.setInLongitude(dto.getLongitude());

        return attendanceRepository.save(attendance);
    }

    // ====================================
    // ✅ CHECK-OUT (with photo + location)
    // ====================================
    public Attendance checkOut(Long labourId, AttendanceOutDto dto) {

        LocalDate today = LocalDate.now();

        Attendance attendance = attendanceRepository
                .findByLabourIdAndDate(labourId, today)
                .orElseThrow(() -> new RuntimeException("No check-in found for today"));

        attendance.setTimeOut(LocalDateTime.now());

        // From Flutter camera + GPS
        attendance.setOutPhotoPath(dto.getPhotoPath());
        attendance.setOutLatitude(dto.getLatitude());
        attendance.setOutLongitude(dto.getLongitude());

        return attendanceRepository.save(attendance);
    }

    // ----------------------------------------------------------------------
    // TODAY'S ATTENDANCE - ALL LABOURS
    // ----------------------------------------------------------------------
    public List<TodayAttendanceDto> getTodayAttendance() {
        LocalDate today = LocalDate.now();
        List<Attendance> records = attendanceRepository.findByDate(today);

        List<TodayAttendanceDto> result = new ArrayList<>();
        Map<Long, String> labourNameCache = new HashMap<>();

        for (Attendance att : records) {
            Long labourId = att.getLabourId();
            if (labourId == null) {
                continue;
            }

            // Get labour name (cache to avoid many DB hits)
            String labourName = labourNameCache.get(labourId);
            if (labourName == null) {
                Optional<Labour> labourOpt = labourRepository.findById(labourId);
                labourName = labourOpt.map(Labour::getName)
                        .orElse("Labour #" + labourId);
                labourNameCache.put(labourId, labourName);
            }

            // Status: default to PRESENT unless explicitly set
            String status = "PRESENT";
            if (att.getStatus() != null && !att.getStatus().isEmpty()) {
                status = att.getStatus();
            }

            // Time strings — use timeIn/timeOut getters (matching Attendance entity)
            String checkIn = null;
            LocalDateTime timeIn = att.getTimeIn();
            if (timeIn != null) {
                checkIn = timeIn.toString();
            }

            String checkOut = null;
            LocalDateTime timeOut = att.getTimeOut();
            if (timeOut != null) {
                checkOut = timeOut.toString();
            }

            TodayAttendanceDto dto = new TodayAttendanceDto(
                    labourId,
                    labourName,
                    status,
                    checkIn,
                    checkOut
            );

            result.add(dto);
        }

        // Sort by labour name for nicer UI
        result.sort(Comparator.comparing(TodayAttendanceDto::getLabourName));

        return result;
    }

    // ----------------------------------------------------------------------
    // TODAY'S ATTENDANCE - ONLY ONE CONTRACTOR'S LABOURS
    // ----------------------------------------------------------------------
    public List<TodayAttendanceDto> getTodayAttendanceForContractor(Long contractorId) {
        LocalDate today = LocalDate.now();

        // 1) Get all labours for this contractor
        List<Labour> labours = labourRepository.findByContractorId(contractorId);
        if (labours == null || labours.isEmpty()) {
            return Collections.emptyList();
        }

        List<Long> labourIds = new ArrayList<>();
        for (Labour l : labours) {
            if (l.getId() != null) {
                labourIds.add(l.getId());
            }
        }

        if (labourIds.isEmpty()) {
            return Collections.emptyList();
        }

        // 2) Attendance only for these labours today
        List<Attendance> records = attendanceRepository.findByDateAndLabourIdIn(today, labourIds);

        List<TodayAttendanceDto> result = new ArrayList<>();
        Map<Long, String> labourNameCache = new HashMap<>();

        for (Attendance att : records) {
            Long labourId = att.getLabourId();
            if (labourId == null) {
                continue;
            }

            // Labour name (cache)
            String labourName = labourNameCache.get(labourId);
            if (labourName == null) {
                Optional<Labour> labourOpt = labourRepository.findById(labourId);
                labourName = labourOpt.map(Labour::getName)
                        .orElse("Labour #" + labourId);
                labourNameCache.put(labourId, labourName);
            }

            String status = "PRESENT";
            if (att.getStatus() != null && !att.getStatus().isEmpty()) {
                status = att.getStatus();
            }

            String checkIn = null;
            LocalDateTime timeIn = att.getTimeIn();
            if (timeIn != null) {
                checkIn = timeIn.toString();
            }

            String checkOut = null;
            LocalDateTime timeOut = att.getTimeOut();
            if (timeOut != null) {
                checkOut = timeOut.toString();
            }

            TodayAttendanceDto dto = new TodayAttendanceDto(
                    labourId,
                    labourName,
                    status,
                    checkIn,
                    checkOut
            );

            result.add(dto);
        }

        result.sort(Comparator.comparing(TodayAttendanceDto::getLabourName));
        return result;
    }
}
