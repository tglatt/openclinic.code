package be.mxs.common.util.system;

import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.util.Base64;
import java.util.EnumMap;
import java.util.Map;

import javax.imageio.ImageIO;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.EncodeHintType;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;

public class QrCodeUtil {
    private static final String BASE64_PREFIX = "data:image/png;base64,";
    private static final int DEFAULT_QR_CODE_WIDTH = 200;
    private static final int DEFAULT_QR_CODE_HEIGHT = 200;
    private static final int QR_CODE_WHITESPACE_MARGIN = 2;
    private static final String DEFAULT_IMAGE_FORMAT = "png";
    private static final String UTF_8_CHARSET = "UTF-8";
    
    public static BufferedImage toQrCode(final String input,
                                         final int width,
                                         final int height) {
        final QRCodeWriter barcodeWriter = new QRCodeWriter();
        try {
            final Map<EncodeHintType, Object> hints = new EnumMap<>(EncodeHintType.class);
            hints.put(EncodeHintType.CHARACTER_SET, UTF_8_CHARSET);
            hints.put(EncodeHintType.MARGIN, QR_CODE_WHITESPACE_MARGIN);
            final BitMatrix bitMatrix = barcodeWriter.encode(input, BarcodeFormat.QR_CODE, width, height, hints);
            return MatrixToImageWriter.toBufferedImage(bitMatrix);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    
    public static String toBase64QrCode(final String input,
                                        final int width,
                                        final int height) {
        try {
            final BufferedImage bufferedImage = toQrCode(input, width, height);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            ImageIO.write(bufferedImage, DEFAULT_IMAGE_FORMAT, outputStream);
            return BASE64_PREFIX + new String(Base64.getEncoder().encode(outputStream.toByteArray()));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
    public static String toBase64QrCode(final String input) {
        return toBase64QrCode(input, DEFAULT_QR_CODE_WIDTH, DEFAULT_QR_CODE_HEIGHT);
    }
    public static BufferedImage toQrCode(final String input) {
        return toQrCode(input, DEFAULT_QR_CODE_WIDTH, DEFAULT_QR_CODE_HEIGHT);
    }
}
