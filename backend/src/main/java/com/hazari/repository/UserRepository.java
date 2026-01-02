// src/main/java/com/hazari/repository/UserRepository.java
package com.hazari.repository;

import com.hazari.entity.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
    Optional<User> findByUsername(String username);
    boolean existsByPhone(String phone);
}
