import base64
import io
from urllib.parse import quote_plus

import qrcode


def generate_upi_qr(amount: float, payee_upi: str, payee_name: str, transaction_ref: str, description: str):
    upi_string = (
        f"upi://pay?"
        f"pa={quote_plus(payee_upi)}"
        f"&pn={quote_plus(payee_name)}"
        f"&am={amount:.2f}"
        f"&cu=INR"
        f"&tn={quote_plus(description)}"
        f"&tr={quote_plus(transaction_ref)}"
    )

    qr = qrcode.make(upi_string)
    buffer = io.BytesIO()
    qr.save(buffer, format='PNG')
    encoded = base64.b64encode(buffer.getvalue()).decode('utf-8')
    return f"data:image/png;base64,{encoded}", upi_string
