package com.hazari.controller;

import com.hazari.dto.LoginRequest;
import com.hazari.dto.RegisterRequest;
import com.hazari.service.AuthService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import java.util.Map;
import com.hazari.dto.ForgotPasswordRequest;




@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*") // optional, but useful for Flutter
public class AuthController {

    private final AuthService authService;

    public AuthController(AuthService authService) {
        this.authService = authService;
    }

    // POST /api/auth/login
    // Returns: { "token": "...", "role": "CONTRACTOR", "userId": 1 }
    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    // POST /api/auth/register
   @PostMapping("/register")
public ResponseEntity<?> register(@RequestBody RegisterRequest request) {
    try {
        Map<String, Object> response = authService.register(request);
        // 201 Created
        return ResponseEntity.status(HttpStatus.CREATED).body(response);
    } catch (IllegalArgumentException ex) {
        // 400 Bad Request with error message
        return ResponseEntity.badRequest().body(ex.getMessage());
    } catch (Exception ex) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Registration error: " + ex.getMessage());
    }
}

 // ----------------------------------------------------------------------
// FORGOT PASSWORD  POST /api/auth/forgot-password
// ----------------------------------------------------------------------
@PostMapping("/forgot-password")
public ResponseEntity<?> forgotPassword(@RequestBody ForgotPasswordRequest request) {
    try {
        String message = authService.forgotPassword(request);
        return ResponseEntity.ok(message);
    } catch (IllegalArgumentException e) {
        return ResponseEntity.badRequest().body(e.getMessage());
    } catch (Exception e) {
        return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body("Error resetting password: " + e.getMessage());
    }
}

}
