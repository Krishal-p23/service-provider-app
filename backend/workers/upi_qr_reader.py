from urllib.parse import parse_qs, urlparse

from PIL import Image


def is_valid_upi_id(upi_id: str) -> bool:
    if not upi_id or '@' not in upi_id:
        return False
    name, handle = upi_id.split('@', 1)
    if not name or not handle:
        return False
    if len(upi_id) < 5 or len(upi_id) > 100:
        return False
    return True


def extract_upi_from_qr(image_file) -> dict:
    try:
        image = Image.open(image_file).convert('RGB')
        qr_data = ''

        # Primary decoder: zxing-cpp (works well on screenshots and supports PIL images).
        try:
            import zxingcpp  # type: ignore[import-not-found]

            decoded = zxingcpp.read_barcodes(image)
            if decoded:
                first = decoded[0]
                qr_data = (getattr(first, 'text', '') or '').strip()
        except Exception:
            qr_data = ''

        # Prefer OpenCV when available for robust QR decoding.
        try:
            import cv2  # type: ignore[import-not-found]
            import numpy as np  # type: ignore[import-not-found]

            np_img = np.array(image)
            detector = cv2.QRCodeDetector()

            def _decode_with_opencv(candidate_img):
                data, _, _ = detector.detectAndDecode(candidate_img)
                if data:
                    return data
                decoded_ok, decoded_list, _, _ = detector.detectAndDecodeMulti(candidate_img)
                if decoded_ok and decoded_list:
                    for item in decoded_list:
                        if item:
                            return item
                return ''

            # Try original and a few processed variants because wallet screenshots
            # can be blurry/compressed after gallery export.
            variants = [np_img]
            gray = cv2.cvtColor(np_img, cv2.COLOR_RGB2GRAY)
            variants.append(gray)
            variants.append(cv2.GaussianBlur(gray, (3, 3), 0))
            variants.append(cv2.adaptiveThreshold(gray, 255, cv2.ADAPTIVE_THRESH_GAUSSIAN_C, cv2.THRESH_BINARY, 31, 2))
            variants.append(cv2.resize(np_img, None, fx=1.8, fy=1.8, interpolation=cv2.INTER_CUBIC))

            for candidate in variants:
                qr_data = _decode_with_opencv(candidate)
                if qr_data:
                    break
        except Exception:
            qr_data = qr_data or ''

        # Fallback decoder when pyzbar is installed.
        if not qr_data:
            try:
                from pyzbar.pyzbar import decode  # type: ignore[import-not-found]

                decoded = decode(image)
                if decoded:
                    qr_data = decoded[0].data.decode('utf-8', errors='ignore')
            except Exception:
                qr_data = ''

        if not qr_data:
            return {'success': False, 'error': 'No QR code found in image'}

        qr_data = qr_data.strip()
        if not qr_data.lower().startswith('upi://'):
            return {'success': False, 'error': 'Not a valid UPI QR code'}

        parsed = urlparse(qr_data)
        params = parse_qs(parsed.query)

        upi_id = (params.get('pa', [None])[0] or '').strip()
        name = (params.get('pn', [None])[0] or '').strip()

        if not upi_id:
            return {'success': False, 'error': 'UPI ID not found in QR'}

        if not is_valid_upi_id(upi_id):
            return {'success': False, 'error': 'Invalid UPI ID format in QR'}

        return {
            'success': True,
            'upi_id': upi_id,
            'name': name,
            'raw': qr_data,
        }
    except Exception as exc:
        return {'success': False, 'error': str(exc)}
