package com.hazari.repository;

import com.hazari.entity.Attendance;
import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

public interface AttendanceRepository extends JpaRepository<Attendance, Long> {

    Optional<Attendance> findByLabourIdAndDate(Long labourId, LocalDate date);

     List<Attendance> findByDate(LocalDate date);

List<Attendance> findByDateAndLabourIdIn(LocalDate date, List<Long> labourIds);

    // ✅ NEW: Count total days this labour has checked in
    long countByLabourIdAndTimeInIsNotNull(Long labourId);
}
