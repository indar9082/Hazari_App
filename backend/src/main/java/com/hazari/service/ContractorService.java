package com.hazari.service;

import com.hazari.dto.ContractorProfileDto;
import com.hazari.entity.Contractor;
import com.hazari.entity.User;
import com.hazari.repository.ContractorRepository;
import com.hazari.repository.UserRepository;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public class ContractorService {

    private final ContractorRepository contractorRepository;
    private final UserRepository userRepository;

    public ContractorService(ContractorRepository contractorRepository,
                             UserRepository userRepository) {
        this.contractorRepository = contractorRepository;
        this.userRepository = userRepository;
    }

    /**
     * userId is coming from login response.
     * For old data, sometimes contractor.id == user.id
     * For new registrations, there may be only User and no Contractor row.
     *
     * So:
     * 1) Try Contractor by id (for existing seeded contractors).
     * 2) If not found, fallback to User and build a simple profile,
     *    so frontend does not crash.
     */
    public ContractorProfileDto getProfile(Long userId) {

        // 1) Try to find Contractor by same id (for older data)
        Optional<Contractor> contractorOpt = contractorRepository.findById(userId);

        if (contractorOpt.isPresent()) {
            Contractor contractor = contractorOpt.get();

            String name = contractor.getName();
            String phone = contractor.getPhone();
            // adjust getter if your field is different
            String company = contractor.getCompanyName();
            boolean active = contractor.isActive(); // or getIsActive()

            return new ContractorProfileDto(
                    contractor.getId(),
                    name,
                    phone,
                    company,
                    active
            );
        }

        // 2) Fallback: build profile from User table (newly registered contractor)
        Optional<User> userOpt = userRepository.findById(userId);
        if (userOpt.isPresent()) {
            User user = userOpt.get();

            String name = user.getUsername();       // or some display name
            String phone = user.getPhone();
            String company = "N/A";
            boolean active = true;

            return new ContractorProfileDto(
                    user.getId(),
                    name,
                    phone,
                    company,
                    active
            );
        }

        // 3) If there is neither Contractor nor User, return a generic profile
        return new ContractorProfileDto(
                userId,
                "Unknown Contractor",
                "",
                "N/A",
                false
        );
    }
}
