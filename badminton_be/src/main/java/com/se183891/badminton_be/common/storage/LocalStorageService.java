package com.se183891.badminton_be.common.storage;

import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.Set;
import java.util.UUID;

@Service
public class LocalStorageService implements StorageService {

    private static final long MAX_FILE_BYTES = 5L * 1024 * 1024;
    private static final Set<String> ALLOWED_EXTENSIONS = Set.of(".jpg", ".jpeg", ".png", ".pdf");

    @Value("${app.storage.upload-dir:uploads}")
    private String uploadDir;

    @Override
    public String storeFile(MultipartFile file, String subFolder) {
        if (file == null || file.isEmpty()) {
            throw new AppException(ErrorCode.FILE_EMPTY);
        }
        if (file.getSize() > MAX_FILE_BYTES) {
            throw new AppException(ErrorCode.FILE_TOO_LARGE);
        }

        String originalFilename = file.getOriginalFilename() != null ? file.getOriginalFilename() : "";
        int dotIndex = originalFilename.lastIndexOf('.');
        String ext = dotIndex >= 0
                ? originalFilename.substring(dotIndex).toLowerCase(Locale.ROOT)
                : "";
        if (!ALLOWED_EXTENSIONS.contains(ext)) {
            throw new AppException(ErrorCode.FILE_TYPE_NOT_ALLOWED);
        }

        String safeFolder = (subFolder == null || subFolder.isBlank()) ? "general" : subFolder.trim();
        String newFileName = UUID.randomUUID() + ext;

        try {
            Path targetDir = Paths.get(uploadDir, safeFolder).toAbsolutePath().normalize();
            Files.createDirectories(targetDir);
            Path targetFile = targetDir.resolve(newFileName);
            Files.copy(file.getInputStream(), targetFile, StandardCopyOption.REPLACE_EXISTING);
            return "/files/" + safeFolder + "/" + newFileName;
        } catch (IOException ex) {
            throw new AppException(ErrorCode.FILE_STORAGE_ERROR);
        }
    }
}
