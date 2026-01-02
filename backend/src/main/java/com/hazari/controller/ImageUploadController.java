// src/main/java/com/hazari/controller/ImageUploadController.java
package com.hazari.controller;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;

@RestController
@RequestMapping("/api/upload")
@CrossOrigin(origins = "*")
public class ImageUploadController {
    
    @Value("${file.upload-dir:./uploads}")
    private String uploadDir;
    
    @PostMapping("/image")
    public ResponseEntity<String> uploadImage(@RequestParam("image") MultipartFile file) {
        try {
            // Create uploads directory if not exists
            Path uploadPath = Paths.get(uploadDir);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }
            
            // Generate unique filename
            String fileName = UUID.randomUUID() + "_" + file.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            
            // Save file
            Files.copy(file.getInputStream(), filePath);
            
            // Return public URL
            String publicUrl = "/uploads/" + fileName;
            return ResponseEntity.ok(publicUrl);
            
        } catch (IOException e) {
            return ResponseEntity.internalServerError().body("Upload failed");
        }
    }
}
