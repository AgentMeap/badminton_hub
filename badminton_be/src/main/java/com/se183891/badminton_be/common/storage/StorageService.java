package com.se183891.badminton_be.common.storage;

import org.springframework.web.multipart.MultipartFile;

public interface StorageService {

    String storeFile(MultipartFile file, String subFolder);
}
