import json
from typing import List


def _json_normalize(value):
    if isinstance(value, float) and value.is_integer():
        return int(value)
    if isinstance(value, dict):
        return {k: _json_normalize(value[k]) for k in sorted(value)}
    if isinstance(value, list):
        return [_json_normalize(v) for v in value]
    return value


def compare_invoice_records(list_inv, detail_inv):
    """Return human-readable diff lines for fields that differ between list and detail."""
    keys = sorted(set(list_inv) | set(detail_inv))
    diffs = []  # type: List[str]
    for key in keys:
        a, b = list_inv.get(key), detail_inv.get(key)
        na, nb = _json_normalize(a), _json_normalize(b)
        if na != nb:
            diffs.append(
                'field "{}": list={} vs detail={} (normalized list={} vs detail={})'.format(
                    key,
                    json.dumps(a, ensure_ascii=False),
                    json.dumps(b, ensure_ascii=False),
                    repr(na),
                    repr(nb),
                )
            )
    return diffs


def compute_pending_unbilled_totals(invoices):
    """PENDING totalAmount; null -> 0; after-tax = total * 1.1"""
    total = 0.0
    for inv in invoices:
        if inv.get("status") != "PENDING":
            continue
        amt = inv.get("totalAmount")
        if amt is None:
            total += 0.0
        else:
            total += float(amt)
    return total, total * 1.1


def format_http_error_context(response):
    try:
        body = response.text[:2000]
    except Exception:  # pragma: no cover
        body = "<unreadable>"
    return "status={} body={!r}".format(response.status_code, body)
