package com.hazari.service;

import com.hazari.dto.ForgotPasswordRequest;
import com.hazari.dto.LoginRequest;
import com.hazari.dto.RegisterRequest;
import com.hazari.entity.Labour;
import com.hazari.entity.User;
import com.hazari.repository.UserRepository;
import com.hazari.repository.LabourRepository;
import com.hazari.config.JwtUtil;

import java.util.HashMap;
import java.util.Map;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtUtil jwtUtil;
    private final AuthenticationManager authenticationManager;
    private final LabourRepository labourRepository;

    public AuthService(UserRepository userRepository,
                       PasswordEncoder passwordEncoder,
                       JwtUtil jwtUtil,
                       AuthenticationManager authenticationManager,
                       LabourRepository labourRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtUtil = jwtUtil;
        this.authenticationManager = authenticationManager;
        this.labourRepository = labourRepository;
    }

    public Map<String, Object> login(LoginRequest request) {
        Authentication auth = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(
                        request.getUsername(),
                        request.getPassword()
                )
        );

        User user = userRepository.findByUsername(request.getUsername())
                .orElseThrow();

        System.out.println("LOGIN user: id=" + user.getId()
                + ", username=" + user.getUsername()
                + ", phone=" + user.getPhone()
                + ", role=" + user.getRole());

        String token = jwtUtil.generateToken(user);

        Map<String, Object> response = new HashMap<>();
        response.put("token", token);
        response.put("role", user.getRole());
        response.put("userId", user.getId());

        // ⭐ For LABOUR users, ensure we always send labourId
        if ("LABOUR".equalsIgnoreCase(user.getRole())) {
            Labour labour = null;

            // 1) Try by userId (for new correct rows)
            labour = labourRepository.findByUserId(user.getId()).orElse(null);
            if (labour != null) {
                System.out.println("Found labour by userId: " + labour.getId());
            }

            // 2) Fallback: try by phone (for older data)
            if (labour == null && user.getPhone() != null) {
                labour = labourRepository.findByPhone(user.getPhone()).orElse(null);
                if (labour != null) {
                    System.out.println("Found labour by phone: " + labour.getId());
                }
            }

            // 3) If still null, auto-create a Labour row so app keeps working
            if (labour == null) {
                System.out.println("No labour found, creating new Labour row for user " + user.getId());
                labour = new Labour();
                labour.setName(user.getUsername());
                labour.setPhone(user.getUsername());
                labour.setContractorId(null); // or set a default / required contractor later
                labour.setAadhaarNumber(null);
                labour.setDailyRate(0.0);
                labour.setHireDate(java.time.LocalDate.now());
                labour.setActive(true);
                labour.setUserId(user.getId());

                labour = labourRepository.save(labour);
                System.out.println("Created labour with id=" + labour.getId());
            }

            response.put("labourId", labour.getId());
        }

        System.out.println("LOGIN response = " + response);
        return response;
    }

    // ----------------------------------------------------------------------
    // REGISTER: creates a User (CONTRACTOR or LABOUR)
    // ----------------------------------------------------------------------
    public Map<String, Object> register(RegisterRequest request) {
        // Basic validations
        if (request.getUsername() == null || request.getUsername().isBlank()) {
            throw new IllegalArgumentException("Username is required");
        }
        if (request.getPassword() == null || request.getPassword().isBlank()) {
            throw new IllegalArgumentException("Password is required");
        }
        if (request.getPhone() == null || request.getPhone().isBlank()) {
            throw new IllegalArgumentException("Phone is required");
        }
        if (request.getRole() == null || request.getRole().isBlank()) {
            throw new IllegalArgumentException("Role is required");
        }

        // Check duplicates
        if (userRepository.findByUsername(request.getUsername()).isPresent()) {
            throw new IllegalArgumentException("Username already exists");
        }
        if (userRepository.existsByPhone(request.getPhone())) {
            throw new IllegalArgumentException("Phone number already registered");
        }

        // Create & save user
        User user = new User();
        user.setUsername(request.getUsername());
        user.setPassword(passwordEncoder.encode(request.getPassword()));
        user.setPhone(request.getPhone());
        user.setRole(request.getRole()); // "LABOUR" or "CONTRACTOR"

        userRepository.save(user);

        // Response for Flutter
        Map<String, Object> response = new HashMap<>();
        response.put("message", "Registration successful");
        response.put("userId", user.getId());
        response.put("role", user.getRole());

        return response;
    }

   public String forgotPassword(ForgotPasswordRequest request) {

    if (request.getUsername() == null || request.getUsername().isBlank()) {
        throw new IllegalArgumentException("Username is required");
    }
    if (request.getPhone() == null || request.getPhone().isBlank()) {
        throw new IllegalArgumentException("Phone is required");
    }
    if (request.getNewPassword() == null || request.getNewPassword().isBlank()) {
        throw new IllegalArgumentException("New password is required");
    }
    if (request.getNewPassword().length() < 6) {
        throw new IllegalArgumentException("New password must be at least 6 characters");
    }

    User user = userRepository.findByUsername(request.getUsername())
            .orElseThrow(() -> new IllegalArgumentException("User not found"));

    if (!request.getPhone().equals(user.getPhone())) {
        throw new IllegalArgumentException("Phone does not match");
    }

    // ✅ Set custom new password from request
    String newRawPassword = request.getNewPassword();
    user.setPassword(passwordEncoder.encode(newRawPassword));
    userRepository.save(user);

    return "Password reset successful";
}

   

    
}
