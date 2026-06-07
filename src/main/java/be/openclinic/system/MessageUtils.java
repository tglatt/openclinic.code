package be.openclinic.system;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.Base64;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;

import org.apache.commons.io.IOUtils;
import org.apache.commons.lang3.StringUtils;

import static java.nio.charset.StandardCharsets.UTF_8;

public final class MessageUtils {

    private MessageUtils() {
        throw new UnsupportedOperationException("utility class");
    }

    public static String gzipCompressToBase64(final String content) throws IOException {
        if (StringUtils.isBlank(content)) {
            throw new IllegalArgumentException("content is either null or blank");
        }

        try (ByteArrayOutputStream out = new ByteArrayOutputStream(content.length())) {
            try (GZIPOutputStream gzip = new GZIPOutputStream(out)) {
                gzip.write(content.getBytes(UTF_8));
            }
            return Base64.getEncoder().encodeToString(out.toByteArray());
        }
    }

    public static String gzipDecompressFromBase64(final String content) throws IOException {
        if (StringUtils.isBlank(content)) {
            throw new IllegalArgumentException("content is either null or blank");
        }

        byte[] decode = Base64.getDecoder().decode(content.getBytes(UTF_8));
        try (ByteArrayInputStream bis = new ByteArrayInputStream(decode)) {
            try (GZIPInputStream gis = new GZIPInputStream(bis)) {
                return IOUtils.toString(gis, UTF_8);
            }
        }
    }
}