package com.hazari.dto;

public class TodayAttendanceDto {

    private Long labourId;
    private String labourName;
    private String status;
    private String checkIn;
    private String checkOut;

    public TodayAttendanceDto() {
    }

    public TodayAttendanceDto(Long labourId, String labourName, String status, String checkIn, String checkOut) {
        this.labourId = labourId;
        this.labourName = labourName;
        this.status = status;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
    }

    public Long getLabourId() {
        return labourId;
    }

    public void setLabourId(Long labourId) {
        this.labourId = labourId;
    }

    public String getLabourName() {
        return labourName;
    }

    public void setLabourName(String labourName) {
        this.labourName = labourName;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(String checkIn) {
        this.checkIn = checkIn;
    }

    public String getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(String checkOut) {
        this.checkOut = checkOut;
    }
}
