package com.se183891.badminton_be.auth.service;

import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthException;
import com.google.firebase.auth.FirebaseToken;
import com.google.firebase.auth.UserRecord;
import com.se183891.badminton_be.common.exception.AppException;
import com.se183891.badminton_be.common.exception.ErrorCode;
import jakarta.annotation.PostConstruct;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.FileInputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.security.MessageDigest;
import java.util.HexFormat;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class FirebaseAuthService {

    private static final Logger log = LoggerFactory.getLogger(FirebaseAuthService.class);

    @Value("${app.firebase.service-account-path:}")
    private String serviceAccountPath;

    @Value("${app.firebase.mock-enabled-when-unconfigured:true}")
    private boolean mockEnabledWhenUnconfigured;

    private boolean realFirebaseInitialized = false;

    private final Map<String, SyncedFirebaseUser> mockFirebaseStoreByEmail = new ConcurrentHashMap<>();

    public record GoogleTokenClaims(
            String firebaseUid,
            String email,
            String fullName,
            String avatarUrl
    ) {
    }

    public record SyncedFirebaseUser(
            String firebaseUid,
            String email,
            String fullName,
            boolean emailVerified
    ) {
    }

    @PostConstruct
    public void init() {
        if (serviceAccountPath == null || serviceAccountPath.isBlank() || serviceAccountPath.contains("CHANGE_ME")) {
            log.info("Firebase service-account-path is not configured. Running FirebaseAuthService in local/dev mode (mockFallback={}).",
                    mockEnabledWhenUnconfigured);
            return;
        }

        Path path = Paths.get(serviceAccountPath.trim());
        if (!Files.exists(path)) {
            log.warn("Firebase service account file not found at {}. Running in local/dev mode (mockFallback={}).",
                    path, mockEnabledWhenUnconfigured);
            return;
        }

        try (FileInputStream stream = new FileInputStream(path.toFile())) {
            if (FirebaseApp.getApps().isEmpty()) {
                // Spring Boot nang httpclient5 len 5.6.x (tu giai nen gzip) khien transport mac dinh
                // cua firebase-admin bao "Not in GZIP format" khi tai public key -> dung NetHttpTransport.
                FirebaseOptions options = FirebaseOptions.builder()
                        .setCredentials(GoogleCredentials.fromStream(stream))
                        .setHttpTransport(new NetHttpTransport())
                        .build();
                FirebaseApp.initializeApp(options);
            }
            realFirebaseInitialized = true;
            log.info("Firebase Admin SDK initialized successfully from {}", path);
        } catch (Exception ex) {
            log.error("Failed to initialize Firebase Admin SDK from {}: {}", path, ex.getMessage());
        }
    }

    public String createVerifiedUserInFirebase(String email, String plainPassword, String fullName) {
        String normalizedEmail = email.trim().toLowerCase(Locale.ROOT);

        if (realFirebaseInitialized) {
            try {
                FirebaseAuth auth = FirebaseAuth.getInstance();
                try {
                    UserRecord existing = auth.getUserByEmail(normalizedEmail);
                    UserRecord.UpdateRequest update = new UserRecord.UpdateRequest(existing.getUid())
                            .setEmailVerified(true)
                            .setDisplayName(fullName);
                    if (plainPassword != null && !plainPassword.isBlank()) {
                        update.setPassword(plainPassword);
                    }
                    UserRecord updated = auth.updateUser(update);
                    return updated.getUid();
                } catch (FirebaseAuthException notFoundEx) {
                    UserRecord.CreateRequest create = new UserRecord.CreateRequest()
                            .setEmail(normalizedEmail)
                            .setEmailVerified(true)
                            .setDisplayName(fullName);
                    if (plainPassword != null && !plainPassword.isBlank()) {
                        create.setPassword(plainPassword);
                    }
                    UserRecord created = auth.createUser(create);
                    return created.getUid();
                }
            } catch (FirebaseAuthException ex) {
                log.error("Firebase createUser failed for {}: {}", normalizedEmail, ex.getMessage());
                throw new AppException(ErrorCode.FIREBASE_SYNC_FAILED);
            }
        }

        if (!mockEnabledWhenUnconfigured) {
            throw new AppException(ErrorCode.FIREBASE_SYNC_FAILED, "Chua cau hinh Firebase Service Account");
        }

        String deterministicUid = generateDeterministicUid(normalizedEmail);
        SyncedFirebaseUser synced = new SyncedFirebaseUser(deterministicUid, normalizedEmail, fullName, true);
        mockFirebaseStoreByEmail.put(normalizedEmail, synced);
        log.info("[FIREBASE AUTH SYNC] Created verified Firebase user: uid={}, email={}", deterministicUid, normalizedEmail);
        return deterministicUid;
    }

    public void updatePasswordInFirebase(String firebaseUid, String email, String newPlainPassword) {
        if (newPlainPassword == null || newPlainPassword.isBlank()) {
            return;
        }
        if (realFirebaseInitialized && firebaseUid != null && !firebaseUid.isBlank()) {
            try {
                UserRecord.UpdateRequest request = new UserRecord.UpdateRequest(firebaseUid)
                        .setPassword(newPlainPassword);
                FirebaseAuth.getInstance().updateUser(request);
            } catch (FirebaseAuthException ex) {
                log.warn("Could not update password in Firebase for uid={}: {}", firebaseUid, ex.getMessage());
            }
            return;
        }
        log.info("[FIREBASE AUTH SYNC] Updated password in Firebase for uid={}, email={}", firebaseUid, email);
    }

    public GoogleTokenClaims verifyGoogleIdToken(String idToken) {
        if (idToken == null || idToken.isBlank()) {
            throw new AppException(ErrorCode.FIREBASE_TOKEN_INVALID);
        }

        if (realFirebaseInitialized && !idToken.startsWith("mock-google:")) {
            try {
                FirebaseToken decoded = FirebaseAuth.getInstance().verifyIdToken(idToken.trim());
                String email = decoded.getEmail();
                if (email == null || email.isBlank()) {
                    throw new AppException(ErrorCode.FIREBASE_TOKEN_INVALID, "Tai khoan Google khong co email");
                }
                String name = decoded.getName() != null && !decoded.getName().isBlank()
                        ? decoded.getName()
                        : email.substring(0, email.indexOf('@'));
                return new GoogleTokenClaims(
                        decoded.getUid(),
                        email.trim().toLowerCase(Locale.ROOT),
                        name,
                        decoded.getPicture()
                );
            } catch (FirebaseAuthException ex) {
                log.warn("Firebase verifyIdToken failed: code={}, message={}", ex.getAuthErrorCode(), ex.getMessage());
                throw new AppException(ErrorCode.FIREBASE_TOKEN_INVALID);
            }
        }

        if (mockEnabledWhenUnconfigured && idToken.startsWith("mock-google:")) {
            // Format: mock-google:<email>:<fullName>
            String[] parts = idToken.split(":", 3);
            if (parts.length < 2 || !parts[1].contains("@")) {
                throw new AppException(ErrorCode.FIREBASE_TOKEN_INVALID);
            }
            String email = parts[1].trim().toLowerCase(Locale.ROOT);
            String fullName = (parts.length == 3 && !parts[2].isBlank())
                    ? parts[2].trim()
                    : email.substring(0, email.indexOf('@'));
            String uid = generateDeterministicUid(email);
            mockFirebaseStoreByEmail.put(email, new SyncedFirebaseUser(uid, email, fullName, true));
            return new GoogleTokenClaims(uid, email, fullName, null);
        }

        log.warn("Rejected Google token: Firebase Admin SDK not initialized (realFirebaseInitialized={})", realFirebaseInitialized);
        throw new AppException(ErrorCode.FIREBASE_TOKEN_INVALID);
    }

    public Optional<SyncedFirebaseUser> getSyncedMockUserByEmail(String email) {
        if (email == null) {
            return Optional.empty();
        }
        return Optional.ofNullable(mockFirebaseStoreByEmail.get(email.trim().toLowerCase(Locale.ROOT)));
    }

    private String generateDeterministicUid(String email) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(email.getBytes(StandardCharsets.UTF_8));
            return "fb-" + HexFormat.of().formatHex(hash).substring(0, 20);
        } catch (Exception ex) {
            return "fb-" + Math.abs(email.hashCode());
        }
    }
}
